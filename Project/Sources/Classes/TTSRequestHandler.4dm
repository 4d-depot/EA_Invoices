// TTSRequestHandler class
// Handles HTTPRequest options and callbacks for Text-to-Speech streaming
// This class is passed directly to 4D.HTTPRequest.new() as the options parameter

// Constants
property kDefaultTimeout : Integer:=60
property kTTSEndpoint : Text:="https://api.openai.com/v1/audio/speech"

// HTTPRequest options properties
property method : Text
property headers : Object
property body : Text
property timeout : Integer
property dataType : Text

// Internal state
property chunkIndex : Integer
property _onChunk : 4D:C1709.Function
property _onComplete : 4D:C1709.Function
property _formWindow : Integer
property _requestId : Integer

Class constructor($apiKey : Text; $body : Object; $chunkCallback : 4D:C1709.Function; $completeCallback : 4D:C1709.Function; $formWindow : Integer; $requestId : Integer)
	
	// HTTPRequest options properties
	This:C1470.method:="POST"
	This:C1470.headers:=New object:C1471("Authorization"; "Bearer "+$apiKey; "Content-Type"; "application/json")
	This:C1470.body:=JSON Stringify:C1217($body)
	This:C1470.timeout:=This:C1470.kDefaultTimeout
	This:C1470.dataType:="blob"
	
	// Internal state for tracking chunks
	This:C1470.chunkIndex:=0
	
	// Callbacks to invoke
	This:C1470._onChunk:=$chunkCallback
	This:C1470._onComplete:=$completeCallback
	This:C1470._formWindow:=$formWindow
	This:C1470._requestId:=$requestId
	
	//MARK: -
	//MARK: Helper methods for callback invocation

Function _invokeChunkCallback($chunk : Blob; $index : Integer)
	// Invoke chunk callback with or without requestId based on whether it was provided
	If (This:C1470._requestId#0)
		This:C1470._onChunk.call(Null:C1517; $chunk; $index; This:C1470._formWindow; This:C1470._requestId)
	Else 
		This:C1470._onChunk.call(Null:C1517; $chunk; $index; This:C1470._formWindow)
	End if 

Function _invokeCompleteCallback($success : Boolean; $error : Text)
	// Invoke complete callback with or without requestId based on whether it was provided
	If (This:C1470._requestId#0)
		This:C1470._onComplete.call(Null:C1517; $success; $error; This:C1470._formWindow; This:C1470._requestId)
	Else 
		This:C1470._onComplete.call(Null:C1517; $success; $error; This:C1470._formWindow)
	End if 
	
	//MARK: -
	//MARK: HTTPRequest callbacks

Function onData($request : 4D:C1709.HTTPRequest; $event : Object)
	// Called when data chunks arrive from the TTS API
	// $event.data contains the NEW chunk data (not cumulative)
	
	var $newChunk : Blob
	var $newSize : Integer
	
	If ($event.data#Null:C1517)
		$newChunk:=$event.data
		$newSize:=BLOB size:C605($newChunk)
		
		If ($newSize>0)
			This:C1470.chunkIndex:=This:C1470.chunkIndex+1
			This:C1470._invokeChunkCallback($newChunk; This:C1470.chunkIndex)
		End if 
	End if 

Function onError($request : 4D:C1709.HTTPRequest; $event : Object)
	// Called when an error occurs during the request
	var $errorText : Text:="Stream error"
	
	If ($request.errors#Null:C1517)
		If ($request.errors.length>0)
			$errorText:=$request.errors[0].message
		End if 
	End if 
	
	This:C1470._invokeCompleteCallback(False:C215; $errorText)

Function onTerminate($request : 4D:C1709.HTTPRequest; $event : Object)
	// Called when the request terminates (successfully or not)
	var $status : Integer:=$request.response.status
	
	If ($status=200)
		This:C1470._invokeCompleteCallback(True:C214; "")
	Else 
		This:C1470._invokeCompleteCallback(False:C215; "HTTP "+String:C10($status))
	End if 
