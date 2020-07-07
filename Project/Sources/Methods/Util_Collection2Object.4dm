//%attributes = {}
C_OBJECT:C1216($object;$element)
C_COLLECTION:C1488($collection;$colValues)

$collection:=$1

$object:=New object:C1471

If ($collection#Null:C1517)
	If ($collection.length>0)
		$lineIndex:=0
		For each ($element;$collection)
			$type:=$element.Type  //Util_ConvertText2Type ($element.Type)
			
			Case of 
				: ($type=Is BLOB:K8:12)
				: ($type=Is null:K8:31)
				: ($type=Is object:K8:27)
				: ($type=Is picture:K8:10)
				: ($type=Is pointer:K8:14)
				: ($type=Is undefined:K8:13)
				: ($type=Object array:K8:28)
				: ($type=Is collection:K8:32)
					$text:=Replace string:C233($element.Value;Char:C90(Carriage return:K15:38);",")
					$colValues:=Split string:C1554($text;",";sk ignore empty strings:K86:1+sk trim spaces:K86:2)
					$object[$element.Property]:=$colValues
					
				Else   //is Boolean; is date; is longint; is text; is real; is time
					$object[$element.Property]:=$element.Value
					
			End case 
		End for each 
	End if 
End if 

$0:=$object

