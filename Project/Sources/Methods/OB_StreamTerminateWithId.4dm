//%attributes = {"invisible":false,"shared":false,"preemptive":"capable"}
// OB_StreamTerminateWithId
// Helper method for HTTPRequest streaming with request ID - handles onTerminate callback
// $1: context object with requestId, onComplete callback, formWindow
// $2: HTTPRequest object

#DECLARE($ctx : Object; $request : Object)

var $status : Integer

$status:=$request.response.status

If ($status=200)
	$ctx.onComplete.call(Null:C1517; True:C214; ""; $ctx.formWindow; $ctx.requestId)
Else 
	$ctx.onComplete.call(Null:C1517; False:C215; "HTTP "+String:C10($status); $ctx.formWindow; $ctx.requestId)
End if 
