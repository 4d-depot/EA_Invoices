//%attributes = {}
  //This method will return the basic type from the value type

$valueType:=$1

$result:="Text"
Case of 
	: ($valueType=Is BLOB:K8:12)
	: ($valueType=Is null:K8:31)
	: ($valueType=Is object:K8:27)
	: ($valueType=Is picture:K8:10)
	: ($valueType=Is pointer:K8:14)
	: ($valueType=Is undefined:K8:13)
	: ($valueType=Object array:K8:28)
	: ($valueType=Is collection:K8:32)
		$result:="Col"
	: ($valueType=Is boolean:K8:9)
		$result:="Bool"
	: ($valueType=Is date:K8:7)
		$result:="Date"
	: ($valueType=Is longint:K8:6)
		$result:="Num"
	: ($valueType=Is text:K8:3)
		$result:="Text"
	: ($valueType=Is real:K8:4)
		$result:="Num"
	: ($valueType=Is time:K8:8)
End case 

$0:=$result

