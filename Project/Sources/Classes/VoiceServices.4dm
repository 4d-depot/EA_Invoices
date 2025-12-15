// VoiceServices class
// Handles Speech-to-Text (STT) using OpenAI Whisper and Text-to-Speech (TTS) using OpenAI TTS API

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
	//MARK: Text-to-Speech (TTS) using OpenAI API

Function generateSpeech($text : Text; $options : Object) : Blob
	// Generate speech audio from text using OpenAI TTS API
	// $options can contain: model, voice, speed, response_format
	// Returns audio blob (empty if error)
	
	var $apiKey : Text
	var $request : 4D:C1709.HTTPRequest
	var $httpOptions : Object
	var $body : Object
	var $audioBlob : Blob
	
	$apiKey:=This:C1470.getAPIKey()
	If ($apiKey="")
		return $audioBlob  // Return empty blob
	End if 
	
	// Default options
	If ($options=Null:C1517)
		$options:={}
	End if 
	
	// Build request body with defaults
	// Available models: "tts-1" (fast, standard) or "tts-1-hd" (slower, higher quality)
	// Available voices: alloy, echo, fable, onyx, nova, shimmer
	// Speed: 0.25 to 4.0 (default 1.0)
	// Response format: mp3, opus, aac, flac, wav, pcm
	$body:=New object:C1471(\
		"model"; ($options.model) ? $options.model : "tts-1"; \
		"input"; $text; \
		"voice"; ($options.voice) ? $options.voice : "nova"; \
		"response_format"; ($options.response_format) ? $options.response_format : "mp3")
	
	If ($options.speed#Null:C1517)
		$body.speed:=$options.speed
	End if 
	
	$httpOptions:=New object:C1471
	$httpOptions.method:="POST"
	$httpOptions.headers:=New object:C1471
	$httpOptions.headers["Authorization"]:="Bearer "+$apiKey
	$httpOptions.headers["Content-Type"]:="application/json"
	$httpOptions.body:=JSON Stringify:C1217($body)
	$httpOptions.timeout:=30
	
	$request:=4D:C1709.HTTPRequest.new("https://api.openai.com/v1/audio/speech"; $httpOptions)
	$request.wait()
	
	If ($request.response.status=200)
		$audioBlob:=$request.response.body
	End if 
	
	return $audioBlob

Function getMimeTypeForFormat($format : Text) : Text
	// Returns the MIME type for a given audio format
	Case of 
		: ($format="mp3")
			return "audio/mpeg"
		: ($format="opus")
			return "audio/opus"
		: ($format="aac")
			return "audio/aac"
		: ($format="flac")
			return "audio/flac"
		: ($format="wav")
			return "audio/wav"
		: ($format="pcm")
			return "audio/pcm"
		Else 
			return "audio/mpeg"
	End case 

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

Function cleanTextForSpeech($text : Text) : Text
	// Clean text for better TTS output
	// Removes HTML, markdown formatting, and extracts <spoken> content
	
	var $result : Text
	var $start; $end : Integer
	
	$result:=$text
	
	// === Extract content from <spoken> tags (generated by the AI for TTS) ===
	While (Position:C15("<spoken>"; $result)>0)
		$start:=Position:C15("<spoken>"; $result)
		$end:=Position:C15("</spoken>"; $result)
		If ($end>$start)
			var $spokenContent : Text
			$spokenContent:=Substring:C12($result; $start+8; $end-$start-8)
			$result:=Substring:C12($result; 1; $start-1)+$spokenContent+Substring:C12($result; $end+9)
		Else 
			$result:=Replace string:C233($result; "<spoken>"; ""; 1)
		End if 
	End while 
	
	// === Remove HTML tables ===
	While (Position:C15("<table"; $result)>0)
		$start:=Position:C15("<table"; $result)
		$end:=Position:C15("</table>"; $result)
		If ($end>$start)
			$result:=Substring:C12($result; 1; $start-1)+Substring:C12($result; $end+8)
		Else 
			$result:=Replace string:C233($result; "<table"; ""; 1)
		End if 
	End while 
	
	// === Remove charts/canvas ===
	While (Position:C15("<canvas"; $result)>0)
		$start:=Position:C15("<canvas"; $result)
		$end:=Position:C15("</canvas>"; $result)
		If ($end>$start)
			$result:=Substring:C12($result; 1; $start-1)+Substring:C12($result; $end+9)
		Else 
			$result:=Replace string:C233($result; "<canvas"; ""; 1)
		End if 
	End while 
	
	// === Remove <chart> tags ===
	While (Position:C15("<chart>"; $result)>0)
		$start:=Position:C15("<chart>"; $result)
		$end:=Position:C15("</chart>"; $result)
		If ($end>$start)
			$result:=Substring:C12($result; 1; $start-1)+Substring:C12($result; $end+8)
		Else 
			$result:=Replace string:C233($result; "<chart>"; ""; 1)
		End if 
	End while 
	
	// === Remove any remaining HTML tags ===
	While (Position:C15("<"; $result)>0)
		$start:=Position:C15("<"; $result)
		$end:=Position:C15(">"; Substring:C12($result; $start))
		If ($end>0)
			$result:=Substring:C12($result; 1; $start-1)+Substring:C12($result; $start+$end)
		Else 
			$result:=Replace string:C233($result; "<"; ""; 1)
		End if 
	End while 
	
	// === Remove code blocks ===
	While (Position:C15("```"; $result)>0)
		$start:=Position:C15("```"; $result)
		$end:=Position:C15("```"; Substring:C12($result; $start+3))
		If ($end>0)
			$result:=Substring:C12($result; 1; $start-1)+Substring:C12($result; $start+3+$end+2)
		Else 
			$result:=Replace string:C233($result; "```"; ""; 1)
		End if 
	End while 
	
	// Remove inline code
	$result:=Replace string:C233($result; "`"; "")
	
	// Remove markdown formatting
	$result:=Replace string:C233($result; "**"; "")
	$result:=Replace string:C233($result; "__"; "")
	$result:=Replace string:C233($result; "*"; "")
	$result:=Replace string:C233($result; "_"; " ")
	$result:=Replace string:C233($result; "### "; "")
	$result:=Replace string:C233($result; "## "; "")
	$result:=Replace string:C233($result; "# "; "")
	
	// Remove markdown links [text](url) -> text
	While (Position:C15("]("; $result)>0)
		var $linkStart; $linkEnd; $urlEnd : Integer
		$linkStart:=Position:C15("["; $result)
		$linkEnd:=Position:C15("]("; $result)
		$urlEnd:=Position:C15(")"; Substring:C12($result; $linkEnd))
		If (($linkStart>0) & ($linkEnd>$linkStart) & ($urlEnd>0))
			var $linkText : Text
			$linkText:=Substring:C12($result; $linkStart+1; $linkEnd-$linkStart-1)
			$result:=Substring:C12($result; 1; $linkStart-1)+$linkText+Substring:C12($result; $linkEnd+$urlEnd)
		Else 
			$result:=Replace string:C233($result; "]("; " "; 1)
		End if 
	End while 
	
	// Remove bullet points
	$result:=Replace string:C233($result; "\r\n- "; ". ")
	$result:=Replace string:C233($result; "\n- "; ". ")
	$result:=Replace string:C233($result; "\r- "; ". ")
	
	// Clean up HTML entities
	$result:=Replace string:C233($result; "&nbsp;"; " ")
	$result:=Replace string:C233($result; "&amp;"; " and ")
	$result:=Replace string:C233($result; "&lt;"; "")
	$result:=Replace string:C233($result; "&gt;"; "")
	$result:=Replace string:C233($result; "&quot;"; "")
	
	// Clean up multiple spaces and newlines
	While (Position:C15("  "; $result)>0)
		$result:=Replace string:C233($result; "  "; " ")
	End while 
	While (Position:C15("\r\n\r\n\r\n"; $result)>0)
		$result:=Replace string:C233($result; "\r\n\r\n\r\n"; "\r\n\r\n")
	End while 
	While (Position:C15("\n\n\n"; $result)>0)
		$result:=Replace string:C233($result; "\n\n\n"; "\n\n")
	End while 
	
	return $result
