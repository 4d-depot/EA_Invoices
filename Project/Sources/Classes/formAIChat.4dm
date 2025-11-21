property webAreaInitialized : Boolean
property prompt : Text

Class constructor()
	cs:C1710.AI_ChatWithTools.me.resetContext()
	This:C1470.webAreaInitialized:=False:C215
	
	//MARK: -
	//MARK: Form & form objects event handlers
	
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
			//Form.people:=Null
			OBJECT SET VISIBLE:C603(*; "btn@"; False:C215)
			cs:C1710.AI_ChatWithTools.me.askMe(Form:C1466.prompt; This:C1470)
			This:C1470.prompt:=""
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
			End case 
	End case 
	
	
	
	//MARK: -
	//MARK: Form actions callback functions
	
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
			If (Not:C34(This:C1470.webAreaInitialized))
				var $templateFilename : Text
				var $templatePath : Text
				$templateFilename:=cs:C1710.ChatHTMLRenderer.me.getInitialHTML()
				$templatePath:=Get 4D folder:C485(Current resources folder:K5:16)+$templateFilename
				WA OPEN URL:C1020(*; "Web Area"; $templatePath)
				This:C1470.webAreaInitialized:=True:C214
			End if 
			
			// Update content via JavaScript without page reload
			cs:C1710.ChatHTMLRenderer.me.updateWebAreaWithJS("Web Area"; $input.messages)
		End if 
		
	End if 
	
	//MARK: -
	//MARK: Other functions
	
	
	