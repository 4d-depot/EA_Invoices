property webAreaInitialized : Boolean
property prompt : Text
property voiceConversationMode : Boolean
property textToSpeechMode : Boolean
property isRecording : Boolean
property voiceServices : Object

Class constructor()
	cs:C1710.AI_ChatWithTools.me.resetContext()
	This:C1470.webAreaInitialized:=False:C215
	This:C1470.voiceConversationMode:=False:C215
	This:C1470.textToSpeechMode:=False:C215
	This:C1470.isRecording:=False:C215
	This:C1470.voiceServices:=cs:C1710.VoiceServices.new()
	
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
		// If text-to-speech mode is enabled, speak the last assistant message
		If (This:C1470.textToSpeechMode)
			var $messages : Collection
			$messages:=cs:C1710.AI_ChatWithTools.me.messages()
			If ($messages#Null:C1517) & ($messages.length>0)
				var $lastMessage : Object
				$lastMessage:=$messages[$messages.length-1]
				If ($lastMessage.role="assistant") & ($lastMessage.content#Null:C1517) & ($lastMessage.content#"")
					// Update status to show TTS is converting
					OBJECT SET TITLE:C194(*; "statusIndicator"; "🔄 Converting to speech...")
					// Delay to let UI refresh before blocking TTS call
					DELAY PROCESS:C323(Current process:C322; 15)
					This:C1470.speakText($lastMessage.content)
					// Note: if voice conversation mode is also enabled, recording will start 
					// when TTS ends (handled in handleTTSStatus)
					return 
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
			// Show microphone icon only if voice conversation mode is off
			If (This:C1470.voiceConversationMode)
				OBJECT SET TITLE:C194(*; "btnMicrophone"; "🎙️")
			Else 
				OBJECT SET TITLE:C194(*; "btnMicrophone"; "🎙️")
			End if 
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
	// Speak text using VoiceServices TTS
	var $cleanText : Text
	var $audioBlob : Blob
	var $base64Audio : Text
	var $result : Text
	var $ttsOptions : Object
	
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
	
	// Configure TTS options
	// Available models: "tts-1" (fast) or "tts-1-hd" (higher quality)
	// Available voices: alloy, echo, fable, onyx, nova, shimmer
	// Speed: 0.25 to 4.0 (default 1.0)
	$ttsOptions:={model: "gpt-4o-mini-tts"; voice: "nova"; speed: 1; response_format: "opus"}
	
	// Call VoiceServices TTS API
	$audioBlob:=This:C1470.voiceServices.generateSpeech($cleanText; $ttsOptions)
	
	If (BLOB size:C605($audioBlob)>0)
		// Update status to show TTS is speaking
		OBJECT SET TITLE:C194(*; "statusIndicator"; "🔊 Speaking...")
		// Convert audio blob to base64 and play via JavaScript
		BASE64 ENCODE:C895($audioBlob; $base64Audio)
		// Remove line breaks from base64 encoding for JavaScript compatibility
		$base64Audio:=Replace string:C233(Replace string:C233($base64Audio; "\r"; ""); "\n"; "")
		WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "Web Area"; "playAudioBase64"; $result; $base64Audio; This:C1470.voiceServices.getMimeTypeForFormat($ttsOptions.response_format))
	Else 
		// Audio generation failed - show toolbar and start recording if needed
		This:C1470.showToolbar()
		If (This:C1470.voiceConversationMode)
			This:C1470.startVoiceRecording()
		End if 
	End if 

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
	