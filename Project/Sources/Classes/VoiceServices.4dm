// VoiceServices class
// Handles Speech-to-Text (STT) using OpenAI Whisper and Text-to-Speech (TTS) using OpenAI TTS API

// TTS defaults
property kDefaultModel : Text:="gpt-4o-mini-tts"
property kDefaultVoice : Text:="nova"
property kDefaultFormat : Text:="pcm"

Class constructor()
	
	//MARK: -
	//MARK: Configuration

Function getAPIKey() : Text
	var $configFile : 4D:C1709.File
	var $config : Object
	
	$configFile:=File:C1566("/RESOURCES/AIprovider.json")
	If ($configFile.exists)
		$config:=JSON Parse:C1218($configFile.getText())
		return $config.reasoning.key
	End if 
	
	return ""

	//MARK: -
	//MARK: Text-to-Speech Streaming (using OpenAI TTS API with chunked transfer)

Function _buildTTSBody($text : Text; $options : Object) : Object
	// Build the request body for TTS API
	var $body : Object
	
	If ($options=Null:C1517)
		$options:={}
	End if 
	
	$body:=New object:C1471(\
		"model"; ($options.model) ? $options.model : This:C1470.kDefaultModel; \
		"input"; $text; \
		"voice"; ($options.voice) ? $options.voice : This:C1470.kDefaultVoice; \
		"response_format"; ($options.response_format) ? $options.response_format : This:C1470.kDefaultFormat)
	
	If ($options.speed#Null:C1517)
		$body.speed:=$options.speed
	End if 
	
	If ($options.instructions#Null:C1517)
		$body.instructions:=$options.instructions
	End if 
	
	return $body

Function generateSpeechStreaming($text : Text; $options : Object; $onChunk : 4D:C1709.Function; $onComplete : 4D:C1709.Function; $formWindow : Integer; $requestId : Integer:=0)
	// Generate speech audio with streaming - calls $onChunk for each data chunk
	// $options can contain: model, voice, speed, response_format, instructions
	// $onChunk receives: ($chunkBlob : Blob; $chunkIndex : Integer; $formWindow : Integer[; $requestId : Integer])
	// $onComplete receives: ($success : Boolean; $error : Text; $formWindow : Integer[; $requestId : Integer])
	// For streaming, use PCM or WAV format for lowest latency
	// $requestId is optional (default 0) - when provided, callbacks include it for ordering multiple requests
	
	var $apiKey : Text
	var $body : Object
	var $requestOptions : cs:C1710.TTSRequestHandler
	
	$apiKey:=This:C1470.getAPIKey()
	If ($apiKey="")
		If ($onComplete#Null:C1517)
			If ($requestId#0)
				$onComplete.call(Null:C1517; False:C215; "API key not configured"; $formWindow; $requestId)
			Else 
				$onComplete.call(Null:C1517; False:C215; "API key not configured"; $formWindow)
			End if 
		End if 
		return 
	End if 
	
	// Build request body using helper
	$body:=This:C1470._buildTTSBody($text; $options)
	
	// Create the request options class instance
	// This class contains all HTTP options AND the callback methods (onData, onError, onTerminate)
	$requestOptions:=cs:C1710.TTSRequestHandler.new($apiKey; $body; $onChunk; $onComplete; $formWindow; $requestId)
	
	// Start the request - the class instance IS the options parameter
	var $request : 4D:C1709.HTTPRequest
	$request:=4D:C1709.HTTPRequest.new($requestOptions.kTTSEndpoint; $requestOptions)
	// Note: We don't call wait() - the callbacks handle everything asynchronously

	//MARK: -
	//MARK: Speech-to-Text (STT) using OpenAI Whisper API

Function transcribe($base64Audio : Text) : Object
	// Transcribe audio to text using OpenAI Whisper API
	// $base64Audio: base64 encoded audio data
	// Returns object with {transcript: "", error: ""}
	
	var $apiKey : Text
	var $audioBlob : Blob
	var $response : Object
	var $result : Object
	var $request : 4D:C1709.HTTPRequest
	var $options : Object
	var $boundary : Text
	var $body : Blob
	
	// Initialize result object
	$result:={transcript: ""; error: ""}
	
	$apiKey:=This:C1470.getAPIKey()
	If ($apiKey="")
		$result.error:="Voice transcription is not available. OpenAI API key not configured."
		return $result
	End if 
	
	// Decode base64 to blob
	BASE64 DECODE:C896($base64Audio; $audioBlob)
	
	// Build multipart form data
	$boundary:="----4DBoundary"+String:C10(Random:C100)
	
	var $bodyText : Text
	$bodyText:="--"+$boundary+"\r\n"
	$bodyText+="Content-Disposition: form-data; name=\"file\"; filename=\"audio.webm\"\r\n"
	$bodyText+="Content-Type: audio/webm\r\n\r\n"
	
	var $headerBlob; $footerBlob : Blob
	CONVERT FROM TEXT:C1011($bodyText; "UTF-8"; $headerBlob)
	
	var $footerText : Text
	$footerText:="\r\n--"+$boundary+"\r\n"
	$footerText+="Content-Disposition: form-data; name=\"model\"\r\n\r\n"
	$footerText+="whisper-1\r\n"
	$footerText+="--"+$boundary+"--\r\n"
	CONVERT FROM TEXT:C1011($footerText; "UTF-8"; $footerBlob)
	
	// Combine blobs
	COPY BLOB:C558($headerBlob; $body; 0; 0; BLOB size:C605($headerBlob))
	COPY BLOB:C558($audioBlob; $body; 0; BLOB size:C605($body); BLOB size:C605($audioBlob))
	COPY BLOB:C558($footerBlob; $body; 0; BLOB size:C605($body); BLOB size:C605($footerBlob))
	
	// Make HTTP request to Whisper API
	$options:=New object:C1471
	$options.method:="POST"
	$options.headers:=New object:C1471
	$options.headers["Authorization"]:="Bearer "+$apiKey
	$options.headers["Content-Type"]:="multipart/form-data; boundary="+$boundary
	$options.body:=$body
	$options.timeout:=60
	
	$request:=4D:C1709.HTTPRequest.new("https://api.openai.com/v1/audio/transcriptions"; $options)
	$request.wait()
	
	If ($request.response.status=200)
		$response:=$request.response.body
		If (Value type:C1509($response)=Is object:K8:27)
			$result.transcript:=String:C10($response.text)
		End if 
	Else 
		// Handle API errors
		$result.error:=This:C1470._getTranscriptionError($request.response.status)
	End if 
	
	return $result

Function _getTranscriptionError($statusCode : Integer) : Text
	Case of 
		: ($statusCode=401)
			return "Voice transcription failed: Invalid API key."
		: ($statusCode=429)
			return "Voice transcription failed: Rate limit exceeded. Please try again later."
		: ($statusCode=500) | ($statusCode=503)
			return "Voice transcription failed: OpenAI service temporarily unavailable."
		Else 
			return "Voice transcription failed (Error "+String:C10($statusCode)+"). Please check your OpenAI API configuration."
	End case 

	//MARK: -
	//MARK: Text cleaning for TTS

Function sendAudioChunkToWebArea($chunkBlob : Blob; $chunkIndex : Integer; $formWindow : Integer)
	// Send an audio chunk to the web area for playback
	// Called by OB_AudioChunk helper method
	var $base64Chunk : Text
	var $result : Text
	
	// Convert chunk to base64
	BASE64 ENCODE:C895($chunkBlob; $base64Chunk)
	// Remove line breaks
	$base64Chunk:=Replace string:C233(Replace string:C233($base64Chunk; "\r"; ""); "\n"; "")
	
	// Send chunk to JavaScript using CALL FORM (since we're in a callback context)
	CALL FORM:C1391($formWindow; Formula:C1597(WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "Web Area"; "addAudioChunk"; $1; $2)); ->$result; $base64Chunk)

Function handleAudioStreamComplete($success : Boolean; $error : Text; $formWindow : Integer)
	// Handle audio stream completion
	// Called by OB_AudioComplete helper method
	var $result : Text
	
	If ($success)
		// Signal end of stream to JavaScript
		CALL FORM:C1391($formWindow; Formula:C1597(WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "Web Area"; "endAudioStream"; $1)); ->$result)
	Else 
		// Error occurred - stop stream and show error
		CALL FORM:C1391($formWindow; Formula:C1597(WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "Web Area"; "stopAudioStream"; $1)); ->$result)
		// Note: handleTTSStatus will be called via JavaScript callback
	End if 

Function cleanTextForSpeech($text : Text) : Text
	// Extract ONLY content from <spoken> tags for TTS
	// All other content (tables, charts, HTML, etc.) is ignored
	
	var $result : Text
	var $start; $end : Integer
	var $spokenContent : Text
	
	$result:=""
	
	// Extract ALL <spoken> tag contents and concatenate them
	var $workText : Text
	$workText:=$text
	
	While (Position:C15("<spoken>"; $workText)>0)
		$start:=Position:C15("<spoken>"; $workText)
		$end:=Position:C15("</spoken>"; $workText)
		If ($end>$start)
			// Extract content between tags
			$spokenContent:=Substring:C12($workText; $start+8; $end-$start-8)
			// Add to result with space separator
			If (Length:C16($result)>0)
				$result:=$result+" "+$spokenContent
			Else 
				$result:=$spokenContent
			End if 
			// Move past this tag for next iteration
			$workText:=Substring:C12($workText; $end+9)
		Else 
			// Unclosed tag, stop processing
			$workText:=""
		End if 
	End while 
	
	// If no <spoken> tags found, return empty (nothing to speak)
	// This ensures we only speak what the AI explicitly marked for TTS
	
	// Clean up the extracted spoken content
	If (Length:C16($result)>0)
		// Remove any stray HTML tags that might be inside spoken content
		While (Position:C15("<"; $result)>0)
			$start:=Position:C15("<"; $result)
			$end:=Position:C15(">"; Substring:C12($result; $start))
			If ($end>0)
				$result:=Substring:C12($result; 1; $start-1)+Substring:C12($result; $start+$end)
			Else 
				$result:=Replace string:C233($result; "<"; ""; 1)
			End if 
		End while 
		
		// Clean up HTML entities
		$result:=Replace string:C233($result; "&nbsp;"; " ")
		$result:=Replace string:C233($result; "&amp;"; " and ")
		$result:=Replace string:C233($result; "&lt;"; "")
		$result:=Replace string:C233($result; "&gt;"; "")
		$result:=Replace string:C233($result; "&quot;"; "\"")
		
		// Clean up multiple spaces
		While (Position:C15("  "; $result)>0)
			$result:=Replace string:C233($result; "  "; " ")
		End while 
	End if 
	
	return $result

