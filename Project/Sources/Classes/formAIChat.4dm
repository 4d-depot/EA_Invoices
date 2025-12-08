property webAreaInitialized : Boolean
property prompt : Text

Class constructor()
	cs:C1710.AI_ChatWithTools.me.resetContext()
	This:C1470.webAreaInitialized:=False:C215
	
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
			
			// Toggle audio recording via JavaScript in the Web Area
			WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "Web Area"; "toggleAudioRecording"; $result)
	End case 
	
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
		OBJECT SET VISIBLE:C603(*; "btn@"; False:C215)
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
			End case 
	End case 
	
	
	//MARK: -
	//MARK: Chat callback functions
	
Function terminateChat()
	If (Current form name:C1298="menu")
		EXECUTE METHOD IN SUBFORM:C1085("Subform"; Formula:C1597(Form:C1466.terminateChat($1; $2)); *; $timing; $peopleFound)
	Else 
		OBJECT SET VISIBLE:C603(*; "btn@"; True:C214)
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
		// Transcribe using Whisper API
		$result:=This:C1470.transcribeWithWhisper($base64Data)
		
		If ($result.error#"")
			// Show error to user
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
	CALL FORM:C1391(Current form window:C827; Formula:C1597(OBJECT SET TITLE:C194(*; "btnMicrophone"; "🎤")))
	
Function transcribeWithWhisper($base64Audio : Text) : Object
	var $apiKey : Text
	var $audioBlob : Blob
	var $response : Object
	var $result : Object
	var $request : 4D:C1709.HTTPRequest
	var $options : Object
	var $boundary : Text
	var $body : Blob
	var $configFile : 4D:C1709.File
	var $config : Object
	
	// Initialize result object
	$result:={transcript: ""; error: ""}
	
	// Get API key from AIprovider.json
	$configFile:=File:C1566("/RESOURCES/AIprovider.json")
	If ($configFile.exists)
		$config:=JSON Parse:C1218($configFile.getText())
		$apiKey:=$config.reasoning.key
	End if 
	
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
		Case of 
			: ($request.response.status=401)
				$result.error:="Voice transcription failed: Invalid API key."
			: ($request.response.status=429)
				$result.error:="Voice transcription failed: Rate limit exceeded. Please try again later."
			: ($request.response.status=500) | ($request.response.status=503)
				$result.error:="Voice transcription failed: OpenAI service temporarily unavailable."
			Else 
				$result.error:="Voice transcription failed (Error "+String:C10($request.response.status)+"). Please check your OpenAI API configuration."
		End case 
	End if 
	
	return $result
	
Function handleSpeechStatus($url : Text)
	var $status : Text
	
	// Extract status from URL: myapp://speechstatus?status=recording|processing|stopped|error
	$status:=Split string:C1554(Split string:C1554($url; "status=")[1]; "&")[0]
	
	Case of 
		: ($status="recording")
			OBJECT SET TITLE:C194(*; "btnMicrophone"; "🔴")
		: ($status="processing")
			OBJECT SET TITLE:C194(*; "btnMicrophone"; "⏳")
		: ($status="stopped")
			OBJECT SET TITLE:C194(*; "btnMicrophone"; "🎤")
		: ($status="error")
			OBJECT SET TITLE:C194(*; "btnMicrophone"; "🎤")
			ALERT:C41("Microphone access denied. Please allow microphone access in System Settings.")
	End case 
	
	