//%attributes = {"invisible":false,"shared":false,"preemptive":"capable"}
// OB_StreamError
// Helper method for HTTPRequest streaming - handles onError callback
// $1: context object with onComplete callback, formWindow
// $2: HTTPRequest object

#DECLARE($ctx : Object; $request : Object)

var $errorText : Text

$errorText:="Stream error"

If ($request.errors#Null:C1517)
	If ($request.errors.length>0)
		$errorText:=$request.errors[0].message
	End if 
End if 

$ctx.onComplete.call(Null:C1517; False:C215; $errorText; $ctx.formWindow)
