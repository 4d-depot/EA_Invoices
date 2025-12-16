property webAreaInitialized : Boolean
property prompt : Text
property voiceConversationMode : Boolean
property textToSpeechMode : Boolean
property isRecording : Boolean
property voiceServices : Object
// Pipelined TTS properties
property ttsStreamingActive : Boolean  // True when we're doing incremental TTS during text streaming
property ttsSpokenText : Text  // Text that has already been sent to TTS
property ttsLastContent : Text  // Last full content seen (to detect new text)
property ttsPendingRequests : Integer  // Number of TTS requests in flight

Class constructor()
	cs:C1710.AI_ChatWithTools.me.resetContext()
	This:C1470.webAreaInitialized:=False:C215
	This:C1470.voiceConversationMode:=False:C215
	This:C1470.textToSpeechMode:=False:C215
	This:C1470.isRecording:=False:C215
	This:C1470.voiceServices:=cs:C1710.VoiceServices.new()
	This:C1470._resetTTSStreamingState()
	
	//MARK: -
	//MARK: Form & form objects event handlers
	
Function ensureWebAreaInitialized()
	// Initialize web area if not done yet
	If (Not:C34(This:C1470.webAreaInitialized))
		var $templateFilename : Text
		var $templatePath : Text
		$templateFilename:=cs:C1710.ChatHTMLRenderer.me.getInitialHTML()
		$templatePath:=Get 4D folder:C485(Current resources folder:K5:16)+$templateFilename
		WA OPEN URL:C1020(*; "Web Area"; $templatePath)
		This:C1470.webAreaInitialized:=True:C214
		// Wait a moment for the page to load
		DELAY PROCESS:C323(Current process:C322; 30)
	End if 
	
	
Function formEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Load:K2:1)
			WA SET PREFERENCE:C1041(*; "Web Area"; WA enable contextual menu:K62:6; True:C214)
			WA SET PREFERENCE:C1041(*; "Web Area"; WA enable Web inspector:K62:7; True:C214)
	End case 
	
	
Function btnNewChatEventHandler($formEventCode : Integer)
	cs:C1710.AI_ChatWithTools.me.resetContext()
	//This.people:=Null
	This:C1470.webAreaInitialized:=False:C215
	This:C1470.voiceConversationMode:=False:C215
	This:C1470.isRecording:=False:C215
	This:C1470._resetTTSStreamingState()
	OBJECT SET TITLE:C194(*; "btnMicrophone"; "🎙️")
	
	var $templateFilename : Text
	var $templatePath : Text
	$templateFilename:=cs:C1710.ChatHTMLRenderer.me.getInitialHTML()
	$templatePath:=Get 4D folder:C485(Current resources folder:K5:16)+$templateFilename
	OBJECT SET SUBFORM:C1138(*; "personDetails"; "selectAPerson")
	WA OPEN URL:C1020(*; "Web Area"; $templatePath)
	
	
Function btnAskMeEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Clicked:K2:4)
			This:C1470.submitPrompt(Form:C1466.prompt)
	End case 
	
	
	
Function btnMicrophoneEventHandler($formEventCode : Integer)
	var $result : Text
	
	Case of 
		: ($formEventCode=On Clicked:K2:4)
			// Initialize web area if not done yet
			This:C1470.ensureWebAreaInitialized()
			
			// If already recording, stop it and disable voice conversation mode
			If (This:C1470.isRecording)
				WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "Web Area"; "stopRecording"; $result)
				This:C1470.voiceConversationMode:=False:C215
			Else 
				// Enable voice conversation mode and start recording
				This:C1470.voiceConversationMode:=True:C214
				This:C1470.textToSpeechMode:=True:C214  // Also enable TTS for full conversation
				OBJECT SET TITLE:C194(*; "btnTextToSpeech"; "🔊")
				WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "Web Area"; "startRecording"; $result)
			End if 
	End case 
	
Function btnTextToSpeechEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Clicked:K2:4)
			// Toggle the text-to-speech mode
			This:C1470.textToSpeechMode:=Not:C34(This:C1470.textToSpeechMode)
			
			// Update button icon to reflect state
			If (This:C1470.textToSpeechMode)
				OBJECT SET TITLE:C194(*; "btnTextToSpeech"; "🔊")  // Active: loud speaker with waves
			Else 
				OBJECT SET TITLE:C194(*; "btnTextToSpeech"; "🔇❌")  // Inactive: muted speaker + red X
			End if 
	End case 
	
Function startVoiceRecording()
	// Start voice recording (used for continuous conversation mode)
	var $result : Text
	
	This:C1470.ensureWebAreaInitialized()
	
	// Small delay to let the UI settle before starting new recording
	DELAY PROCESS:C323(Current process:C322; 30)
	
	// Start recording via JavaScript
	WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "Web Area"; "startRecording"; $result)
	
Function btnCopyEventHandler($formEventCode : Integer)
	var $messages : Collection
	
	Case of 
		: ($formEventCode=On Clicked:K2:4)
			$messages:=cs:C1710.AI_ChatWithTools.me.messages()
			If ($messages#Null:C1517)
				SET TEXT TO PASTEBOARD:C523(JSON Stringify:C1217($messages; *))
			End if 
	End case 
	
	
Function inputEventHandler($formEventCode : Integer)
	var $currentText : Text
	
	Case of 
		: ($formEventCode=On Before Keystroke:K2:6)
			If ((Character code:C91(Keystroke:C390)=Carriage return:K15:38) && (Macintosh command down:C546 || Macintosh control down:C544 || Macintosh option down:C545 || Windows Alt down:C563 || Windows Ctrl down:C562))
				// Get the current text being edited (before keystroke is processed)
				$currentText:=Get edited text:C655
				FILTER KEYSTROKE:C389("")  // Cancel the carriage return keystroke
				This:C1470.submitPrompt($currentText)
			End if 
	End case 
	
Function submitPrompt($prompt : Text)
	If (($prompt#Null:C1517) & ($prompt#""))
		// Hide toolbar and show status indicator
		OBJECT SET VISIBLE:C603(*; "btn@"; False:C215)
		OBJECT SET VISIBLE:C603(*; "statusIndicator"; True:C214)
		OBJECT SET TITLE:C194(*; "statusIndicator"; "⏳ Generating response...")
		cs:C1710.AI_ChatWithTools.me.askMe($prompt; This:C1470)
		Form:C1466.prompt:=""
	End if 
	
Function queryObjectFromUrl($url : Text)
	var $urlQueryString : Text
	var $parsedQueryString; $splittedPair; $entitiesStrings : Collection
	var $pair; $pkName; $pkType; $entityID : Text
	var $queryObject; $dataClass; $pkInfo; $pkAttribute : Object
	
	$queryObject:={}
	$urlQueryString:=Split string:C1554($url; "?")[1]
	$parsedQueryString:=Split string:C1554($urlQueryString; "&")
	
	For each ($pair; $parsedQueryString)
		$splittedPair:=Split string:C1554($pair; "=")
		$queryObject[$splittedPair[0]]:=$splittedPair[1]
	End for each 
	
	If (Not:C34(OB Is defined:C1231($queryObject; "form")))
		return Null:C1517
	End if 
	
	
	If (OB Is defined:C1231($queryObject; "dataClass") && OB Is defined:C1231($queryObject; "entities"))
		// Split the entities string
		$entitiesStrings:=Split string:C1554($queryObject.entities; ",")
		
		// Get the primary key info from the dataclass
		$dataClass:=ds:C1482[$queryObject.dataClass]
		$pkInfo:=$dataClass.getInfo()
		$pkName:=$pkInfo.primaryKey
		$pkAttribute:=$dataClass[$pkName]
		$pkType:=$pkAttribute.type
		
		// Convert entity IDs to the appropriate type based on the primary key type
		Case of 
			: ($pkType="number")
				// Convert strings to numbers
				$queryObject.entitiesCollection:=[]
				For each ($entityID; $entitiesStrings)
					$queryObject.entitiesCollection.push(Num:C11($entityID))
				End for each 
			: ($pkType="string")
				// Use the string collection directly
				$queryObject.entitiesCollection:=$entitiesStrings
			Else 
				// Primary key must be either number or string
				ASSERT:C1129(False:C215; "Primary key type must be 'number' or 'string', got: "+$pkType)
		End case 
	End if 
	
	return $queryObject
	
	
	
Function webAreaEventHandler($formEventCode : Integer)
	var $formToOpen : Text
	var $entitySelectionToShow : 4D:C1709.EntitySelection
	var $queryObject : Object
	
	Case of 
		: ($formEventCode=On Load:K2:1)
			ARRAY TEXT:C222($filters; 0)
			ARRAY BOOLEAN:C223($allowDeny; 0)
			
			APPEND TO ARRAY:C911($filters; "myapp://*")  // Intercept all URLs starting with myapp://
			APPEND TO ARRAY:C911($AllowDeny; False:C215)  //Allow
			
			WA SET URL FILTERS:C1030(*; "Web Area"; $filters; $allowDeny)
			
		: ($formEventCode=On URL Filtering:K2:49)
			$url:=WA Get last filtered URL:C1035(*; "Web Area")
			
			// Parse the URL to determine what to do
			Case of 
				: ($url="myapp://openform?@")
					$queryObject:=This:C1470.queryObjectFromUrl($url)
					If ($queryObject=Null:C1517)
						return 
					End if 
					
					If ($queryObject.entitiesCollection.length>0)
						$entitySelectionToShow:=ds:C1482[$queryObject.dataClass].query("ID in :1"; $queryObject.entitiesCollection)
						CALL WORKER:C1389("Generic"; "W_Generic"; $queryObject.form; True:C214; $entitySelectionToShow)
					Else 
						CALL WORKER:C1389("Generic"; "W_Generic"; $queryObject.form; False:C215)
					End if 
					
				: ($url="myapp://audiodata?@")
					// Handle audio data for Whisper transcription
					This:C1470.handleAudioData($url)
					
				: ($url="myapp://speechstatus?@")
					// Handle speech recognition status updates
					This:C1470.handleSpeechStatus($url)
					
				: ($url="myapp://ttsstatus?@")
					// Handle text-to-speech status updates
					This:C1470.handleTTSStatus($url)
			End case 
	End case 
	
	
	//MARK: -
	//MARK: Chat callback functions
	
Function terminateChat()
	If (Current form name:C1298="menu")
		EXECUTE METHOD IN SUBFORM:C1085("Subform"; Formula:C1597(Form:C1466.terminateChat($1; $2)); *; $timing; $peopleFound)
	Else 
		// If text-to-speech mode is enabled, handle TTS
		If (This:C1470.textToSpeechMode)
			var $messages : Collection
			$messages:=cs:C1710.AI_ChatWithTools.me.messages()
			If ($messages#Null:C1517) & ($messages.length>0)
				var $lastMessage : Object
				$lastMessage:=$messages[$messages.length-1]
				If ($lastMessage.role="assistant") & ($lastMessage.content#Null:C1517) & ($lastMessage.content#"")
					// If we were doing pipelined TTS, speak any remaining text
					If (This:C1470.ttsStreamingActive)
						This:C1470._finishStreamingTTS($lastMessage.content)
						// Note: voice recording will start when all TTS finishes (handled in handleTTSStatus)
						return 
					Else 
						// Non-pipelined: speak the full message (fallback)
						OBJECT SET TITLE:C194(*; "statusIndicator"; "🔄 Converting to speech...")
						DELAY PROCESS:C323(Current process:C322; 15)
						This:C1470.speakText($lastMessage.content)
						return 
					End if 
				End if 
			End if 
		End if 
		
		// No TTS - show toolbar immediately
		This:C1470.showToolbar()
		
		// If voice conversation mode is enabled (and TTS not speaking), restart recording
		If (This:C1470.voiceConversationMode)
			This:C1470.startVoiceRecording()
		End if 
	End if 
	
Function progressChat($input : Object)
	If (Current form name:C1298="menu")
		EXECUTE METHOD IN SUBFORM:C1085("Subform"; Formula:C1597(Form:C1466.progressChat($1)); *; $input)
	Else 
		
		If (Not:C34(Undefined:C82($input.messages)))
			// Initialize web area with template HTML file on first use
			This:C1470.ensureWebAreaInitialized()
			
			// Update content via JavaScript without page reload
			cs:C1710.ChatHTMLRenderer.me.updateWebAreaWithJS("Web Area"; $input.messages)
			
			// Pipelined TTS: speak text incrementally as it streams
			If (This:C1470.textToSpeechMode)
				This:C1470._processStreamingTTS($input.messages)
			End if 
		End if 
		
	End if 
	
	//MARK: -
	//MARK: Speech recognition functions (using Whisper API)
	
Function handleAudioData($url : Text)
	// Handle audio data from JavaScript recording
	// URL format: myapp://audiodata?data=base64_audio_data
	var $base64Data : Text
	var $result : Object
	
	$base64Data:=Split string:C1554($url; "data=")[1]
	
	If ($base64Data#"")
		// Transcribe using VoiceServices
		$result:=This:C1470.voiceServices.transcribe($base64Data)
		
		If ($result.error#"")
			// Show error to user and disable voice conversation mode
			This:C1470.voiceConversationMode:=False:C215
			OBJECT SET TITLE:C194(*; "btnMicrophone"; "🎙️")
			ALERT:C41($result.error)
		Else 
			If ($result.transcript#"")
				// Append to existing prompt or set as new prompt
				If ((Form:C1466.prompt=Null:C1517) | (Form:C1466.prompt=""))
					Form:C1466.prompt:=$result.transcript
				Else 
					Form:C1466.prompt:=String:C10(Form:C1466.prompt)+" "+$result.transcript
				End if 
				// Auto-submit the voice prompt
				This:C1470.submitPrompt(Form:C1466.prompt)
			End if 
		End if 
	End if 
	
	// Reset button state using CALL FORM to ensure UI update happens
	CALL FORM:C1391(Current form window:C827; Formula:C1597(OBJECT SET TITLE:C194(*; "btnMicrophone"; "🎙️")))
	
Function handleSpeechStatus($url : Text)
	var $status : Text
	
	// Extract status from URL: myapp://speechstatus?status=recording|processing|stopped|error|silence
	$status:=Split string:C1554(Split string:C1554($url; "status=")[1]; "&")[0]
	
	Case of 
		: ($status="recording")
			This:C1470.isRecording:=True:C214
			OBJECT SET TITLE:C194(*; "btnMicrophone"; "🔴")
		: ($status="processing")
			This:C1470.isRecording:=False:C215
			OBJECT SET TITLE:C194(*; "btnMicrophone"; "⏳")
		: ($status="stopped")
			This:C1470.isRecording:=False:C215
			OBJECT SET TITLE:C194(*; "btnMicrophone"; "🎙️")
		: ($status="silence")
			// Recording contained no speech - disable voice conversation mode
			This:C1470.isRecording:=False:C215
			This:C1470.voiceConversationMode:=False:C215
			OBJECT SET TITLE:C194(*; "btnMicrophone"; "🎙️")
		: ($status="error")
			This:C1470.isRecording:=False:C215
			This:C1470.voiceConversationMode:=False:C215
			OBJECT SET TITLE:C194(*; "btnMicrophone"; "🎙️")
			ALERT:C41("Microphone access denied. Please allow microphone access in System Settings.")
	End case 
	

	//MARK: -
	//MARK: Text-to-Speech functions (using OpenAI TTS API)

Function speakText($text : Text)
	// Speak text using VoiceServices TTS with streaming for faster response
	var $cleanText : Text
	var $result : Text
	var $ttsOptions : Object
	var $formWindow : Integer
	
	This:C1470.ensureWebAreaInitialized()
	
	// Clean the text - remove markdown formatting for better speech
	$cleanText:=This:C1470.voiceServices.cleanTextForSpeech($text)
	
	// Skip if there's nothing to speak
	If (Length:C16($cleanText)<10)
		// Nothing to speak - show toolbar and start recording if needed
		This:C1470.showToolbar()
		If (This:C1470.voiceConversationMode)
			This:C1470.startVoiceRecording()
		End if 
		return 
	End if 
	
	// Limit text length (OpenAI TTS has a 4096 character limit)
	If (Length:C16($cleanText)>4000)
		$cleanText:=Substring:C12($cleanText; 1; 4000)
	End if 
	
	// Configure TTS options for streaming
	// Use PCM format for lowest latency streaming
	// gpt-4o-mini-tts supports instructions for voice customization
	$ttsOptions:={model: "gpt-4o-mini-tts"; voice: "nova"; speed: 1; response_format: "pcm"}
	
	// Update status
	OBJECT SET TITLE:C194(*; "statusIndicator"; "🔊 Speaking...")
	
	// Initialize JavaScript audio stream
	WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "Web Area"; "initAudioStream"; $result)
	
	// Store form window for callbacks
	$formWindow:=Current form window:C827
	
	// Start streaming TTS - audio chunks will be sent to JavaScript as they arrive
	// The callbacks will receive: ($blob, $index, $formWindow) for onChunk
	// and ($success, $error, $formWindow) for onComplete
	This:C1470.voiceServices.generateSpeechStreaming($cleanText; $ttsOptions; \
		Formula:C1597(OB_AudioChunk($1; $2; $3)); \
		Formula:C1597(OB_AudioComplete($1; $2; $3)); \
		$formWindow)

Function handleTTSStatus($url : Text)
	var $status : Text
	
	// Extract status from URL: myapp://ttsstatus?status=speaking|ended|error
	$status:=Split string:C1554(Split string:C1554($url; "status=")[1]; "&")[0]
	
	Case of 
		: ($status="speaking")
			// TTS is speaking - update status
			OBJECT SET TITLE:C194(*; "statusIndicator"; "🔊 Speaking...")
			
		: ($status="ended")
			// TTS finished - show toolbar
			This:C1470.showToolbar()
			// If voice conversation mode is enabled, start recording
			If (This:C1470.voiceConversationMode)
				This:C1470.startVoiceRecording()
			End if 
			
		: ($status="error")
			// TTS error - show toolbar and start recording if needed
			This:C1470.showToolbar()
			If (This:C1470.voiceConversationMode)
				This:C1470.startVoiceRecording()
			End if 
	End case 

Function showToolbar()
	// Hide status indicator and show normal toolbar buttons
	OBJECT SET VISIBLE:C603(*; "statusIndicator"; False:C215)
	OBJECT SET VISIBLE:C603(*; "btn@"; True:C214)
	
	//MARK: -
	//MARK: Pipelined TTS functions (speak while text is still streaming)

Function _resetTTSStreamingState()
	// Reset all pipelined TTS state
	This:C1470.ttsStreamingActive:=False:C215
	This:C1470.ttsSpokenText:=""
	This:C1470.ttsLastContent:=""
	This:C1470.ttsPendingRequests:=0

Function _processStreamingTTS($messages : Collection)
	// Process streaming text and send complete sentences to TTS
	// Called from progressChat as text streams in
	
	var $lastMessage : Object
	var $content : Text
	var $newText : Text
	var $speakableText : Text
	
	If ($messages=Null:C1517) | ($messages.length=0)
		return 
	End if 
	
	// Get the last assistant message
	$lastMessage:=$messages[$messages.length-1]
	If ($lastMessage.role#"assistant") | ($lastMessage.content=Null:C1517)
		return 
	End if 
	
	$content:=String:C10($lastMessage.content)
	
	// Check if content has changed
	If ($content=This:C1470.ttsLastContent)
		return 
	End if 
	This:C1470.ttsLastContent:=$content
	
	// Extract speakable content from <spoken> tags
	// We process PARTIAL spoken content for streaming - don't wait for closing tag
	var $cleanContent : Text
	var $spokenStart : Integer
	var $spokenEnd : Integer
	var $partialSpoken : Text
	
	$cleanContent:=""
	$partialSpoken:=""
	
	// Find all complete <spoken>...</spoken> blocks
	var $workText : Text
	$workText:=$content
	
	While (Position:C15("<spoken>"; $workText)>0)
		$spokenStart:=Position:C15("<spoken>"; $workText)
		$spokenEnd:=Position:C15("</spoken>"; $workText)
		
		If ($spokenEnd>$spokenStart)
			// Complete block - extract it
			$cleanContent:=$cleanContent+Substring:C12($workText; $spokenStart+8; $spokenEnd-$spokenStart-8)+" "
			$workText:=Substring:C12($workText; $spokenEnd+9)
		Else 
			// Unclosed <spoken> tag - extract partial content for streaming
			$partialSpoken:=Substring:C12($workText; $spokenStart+8)
			$workText:=""  // Exit loop
		End if 
	End while 
	
	// Add partial spoken content (up to last complete sentence)
	If (Length:C16($partialSpoken)>0)
		// Extract only complete sentences from partial content
		var $partialSentences : Text
		$partialSentences:=This:C1470._extractCompleteSentences($partialSpoken)
		If (Length:C16($partialSentences)>0)
			$cleanContent:=$cleanContent+$partialSentences
		End if 
	End if 
	
	// Trim the result
	$cleanContent:=Trim:C1853($cleanContent)
	
	// Skip if no speakable content yet
	If (Length:C16($cleanContent)<10)
		return 
	End if 
	
	// Calculate new text based on length already spoken, not string matching
	// This avoids issues when cleanContent changes due to HTML processing
	var $spokenLength : Integer
	$spokenLength:=Length:C16(This:C1470.ttsSpokenText)
	
	If ($spokenLength>0)
		// Only take text after what we've already spoken
		If (Length:C16($cleanContent)>$spokenLength)
			$newText:=Substring:C12($cleanContent; $spokenLength+1)
		Else 
			// Content is shorter than or equal to what we've spoken - no new text
			return 
		End if 
	Else 
		$newText:=$cleanContent
	End if 
	
	// Extract complete sentences from new text
	$speakableText:=This:C1470._extractCompleteSentences($newText)
	
	If (Length:C16($speakableText)>0)
		// Decide if we should start speaking
		var $shouldSpeak : Boolean
		$shouldSpeak:=False:C215
		
		If (Not:C34(This:C1470.ttsStreamingActive))
			// First time: start speaking with just 1 complete sentence or 50 chars
			var $sentenceCount : Integer
			$sentenceCount:=This:C1470._countSentences($speakableText)
			If (($sentenceCount>=1) | (Length:C16($speakableText)>50))
				$shouldSpeak:=True:C214
				This:C1470.ttsStreamingActive:=True:C214
				This:C1470._initTTSQueue()
			End if 
		Else 
			// Already streaming: speak any complete sentence
			$shouldSpeak:=True:C214
		End if 
		
		If ($shouldSpeak)
			// Update spoken text tracker by length
			This:C1470.ttsSpokenText:=This:C1470.ttsSpokenText+$speakableText
			// Queue this text for TTS
			This:C1470._queueTTSText($speakableText)
		End if 
	End if 

Function _finishStreamingTTS($fullContent : Text)
	// Called at end of streaming to speak any remaining text
	
	var $cleanContent : Text
	var $remainingText : Text
	var $spokenLength : Integer
	
	$cleanContent:=This:C1470.voiceServices.cleanTextForSpeech($fullContent)
	
	// Get any text not yet spoken (use length-based tracking to match _processStreamingTTS)
	$spokenLength:=Length:C16(This:C1470.ttsSpokenText)
	
	If ($spokenLength>0)
		If (Length:C16($cleanContent)>$spokenLength)
			$remainingText:=Substring:C12($cleanContent; $spokenLength+1)
		Else 
			// All text already spoken
			$remainingText:=""
		End if 
	Else 
		$remainingText:=$cleanContent
	End if 
	
	// Trim whitespace
	$remainingText:=Trim:C1853($remainingText)
	
	If (Length:C16($remainingText)>0)
		If (Not:C34(This:C1470.ttsStreamingActive))
			// Never started streaming, speak full content
			This:C1470.ttsStreamingActive:=True:C214
			This:C1470._initTTSQueue()
			This:C1470._queueTTSText($cleanContent)
		Else 
			// Queue remaining text
			This:C1470._queueTTSText($remainingText)
		End if 
	End if 
	
	// Signal end of text stream to JavaScript
	This:C1470._finalizeTTSQueue()
	
	// Reset state for next conversation turn
	This:C1470._resetTTSStreamingState()

Function _extractCompleteSentences($text : Text) : Text
	// Extract complete sentences (ending with . ! ? or newline) from text
	// Returns the complete sentences, leaves partial sentence for later
	// Avoids splitting on abbreviations like "e.g.", "i.e.", etc.
	
	var $result : Text
	var $lastSentenceEnd : Integer
	var $i : Integer
	var $char : Text
	var $prevChar : Text
	var $nextChar : Text
	var $len : Integer
	
	$result:=""
	$lastSentenceEnd:=0
	$len:=Length:C16($text)
	
	For ($i; 1; $len)
		$char:=Substring:C12($text; $i; 1)
		
		// Check for sentence endings
		If (($char="!") | ($char="?") | ($char="\n") | ($char="\r"))
			// These are always sentence endings
			// Include trailing spaces after punctuation
			While (($i<$len) & (Substring:C12($text; $i+1; 1)=" "))
				$i:=$i+1
			End while 
			$lastSentenceEnd:=$i
			
		Else 
			If ($char=".")
				// Period - check if it's likely a sentence end or an abbreviation
				// Get surrounding characters
				$prevChar:=""
				$nextChar:=""
				If ($i>1)
					$prevChar:=Substring:C12($text; $i-1; 1)
				End if 
				If ($i<$len)
					$nextChar:=Substring:C12($text; $i+1; 1)
				End if 
				
				// Skip if this looks like an abbreviation:
				// - Single letter before period (e.g., "e.", "i.")
				// - Period followed by lowercase letter (e.g., "e.g")
				var $isAbbreviation : Boolean
				$isAbbreviation:=False:C215
				
				// Single letter abbreviation (like "e." in "e.g.")
				If (($i>=2) & (($i=2) | (Substring:C12($text; $i-2; 1)=" ") | (Substring:C12($text; $i-2; 1)=".")))
					If (($prevChar>="a") & ($prevChar<="z")) | (($prevChar>="A") & ($prevChar<="Z"))
						$isAbbreviation:=True:C214
					End if 
				End if 
				
				// Period followed by lowercase (continuation of abbreviation)
				If (($nextChar>="a") & ($nextChar<="z"))
					$isAbbreviation:=True:C214
				End if 
				
				If (Not:C34($isAbbreviation))
					// Include trailing spaces after punctuation
					While (($i<$len) & (Substring:C12($text; $i+1; 1)=" "))
						$i:=$i+1
					End while 
					$lastSentenceEnd:=$i
				End if 
			End if 
		End if 
	End for 
	
	// Only return if we have a meaningful amount of text (at least 10 chars)
	If (($lastSentenceEnd>0) & ($lastSentenceEnd>=10))
		$result:=Substring:C12($text; 1; $lastSentenceEnd)
	End if 
	
	return $result

Function _countSentences($text : Text) : Integer
	// Count the number of sentences in text
	var $count : Integer
	var $i : Integer
	var $char : Text
	
	$count:=0
	For ($i; 1; Length:C16($text))
		$char:=Substring:C12($text; $i; 1)
		If (($char=".") | ($char="!") | ($char="?"))
			$count:=$count+1
		End if 
	End for 
	
	return $count

Function _initTTSQueue()
	// Initialize the JavaScript TTS queue for pipelined playback
	var $result : Text
	This:C1470.ensureWebAreaInitialized()
	This:C1470.ttsPendingRequests:=0
	OBJECT SET TITLE:C194(*; "statusIndicator"; "🔊 Speaking...")
	WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "Web Area"; "initTTSQueue"; $result)

Function _queueTTSText($text : Text)
	// Queue text for TTS - will be converted to speech and played in order
	var $cleanText : Text
	var $ttsOptions : Object
	var $formWindow : Integer
	var $requestId : Integer
	var $result : Text
	
	$cleanText:=Trim:C1853($text)
	
	If (Length:C16($cleanText)<5)
		return  // Skip very short text
	End if 
	
	// Skip text that looks like HTML attributes (safety net)
	If ((Position:C15("=\""; $cleanText)>0) | (Position:C15("href="; $cleanText)>0) | (Position:C15("border="; $cleanText)>0) | (Position:C15("cellpadding"; $cleanText)>0) | (Position:C15("cellspacing"; $cleanText)>0))
		return 
	End if
	
	// Limit individual chunk length
	If (Length:C16($cleanText)>4000)
		$cleanText:=Substring:C12($cleanText; 1; 4000)
	End if 
	
	// Configure TTS options
	$ttsOptions:={model: "gpt-4o-mini-tts"; voice: "nova"; speed: 1; response_format: "pcm"}
	
	$formWindow:=Current form window:C827
	
	// Get a unique request ID and register it with JavaScript
	This:C1470.ttsPendingRequests:=This:C1470.ttsPendingRequests+1
	$requestId:=This:C1470.ttsPendingRequests
	
	// Tell JavaScript to expect this request ID
	WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "Web Area"; "registerTTSRequest"; $result; $requestId)
	
	// Start streaming TTS for this chunk, passing the request ID
	This:C1470.voiceServices.generateSpeechStreamingWithId($cleanText; $ttsOptions; $requestId; \
		Formula:C1597(OB_AudioChunkQueued($1; $2; $3; $4)); \
		Formula:C1597(OB_AudioCompleteQueued($1; $2; $3; $4)); \
		$formWindow)

Function _finalizeTTSQueue()
	// Signal to JavaScript that no more TTS requests are coming
	var $result : Text
	WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "Web Area"; "finalizeTTSQueue"; $result)
