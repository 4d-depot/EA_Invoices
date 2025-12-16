//%attributes = {"invisible":false,"shared":false,"preemptive":"capable"}
// OB_StreamTerminate
// Helper method for HTTPRequest streaming - handles onTerminate callback
// $1: context object with onComplete callback, formWindow
// $2: HTTPRequest object

#DECLARE($ctx : Object; $request : Object)

var $status : Integer

$status:=$request.response.status

If ($status=200)
	$ctx.onComplete.call(Null:C1517; True:C214; ""; $ctx.formWindow)
Else 
	$ctx.onComplete.call(Null:C1517; False:C215; "HTTP "+String:C10($status); $ctx.formWindow)
End if 
