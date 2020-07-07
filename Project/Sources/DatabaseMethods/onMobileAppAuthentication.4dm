C_OBJECT:C1216($0;$response)
C_OBJECT:C1216($1;$request)

$request:=$1  // Informations provided by mobile application
$response:=New object:C1471  // Informations returned to mobile application

  // Check user email
If ($request.email=Null:C1517)
	  // No email means Guest mode - Allow connection
	$response.success:=True:C214
Else 
	  // Authenticated mode - Allow or not the connection according to email or other device property
	$response.success:=True:C214
End if 

  // Optional message to display on mobile App.
If ($response.success)
	$response.statusText:="You are successfully authenticated"
Else 
	$response.statusText:="Sorry, you are not authorized to use this application."
End if 

$0:=$response