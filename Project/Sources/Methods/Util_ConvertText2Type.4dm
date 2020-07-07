//%attributes = {}
  //This method will return the value type from the basic type (Text, Num, Date, etc...) 

$valueText:=$1

$valueType:=Is text:K8:3

Case of 
	: ($valueText="Col")
		$valueType:=Is collection:K8:32
		
	: ($valueText="Bool")
		$valueType:=Is boolean:K8:9
		
	: ($valueText="Date")
		$valueType:=Is date:K8:7
		
	: ($valueText="Text")
		$valueType:=Is text:K8:3
		
	: ($valueText="Num")
		$valueType:=Is real:K8:4  //There is no way to know it shoud be 'Is longint'
		
End case 

$0:=$valueType

