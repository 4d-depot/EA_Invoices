//%attributes = {}
C_OBJECT:C1216($objectAttribute;$element)
C_COLLECTION:C1488($collection)
C_TEXT:C284($property;$subProp)

$objectAttribute:=$1

$collection:=New collection:C1472

If ($objectAttribute#Null:C1517)
	If (Not:C34(OB Is empty:C1297($objectAttribute)))
		$lineIndex:=0
		For each ($property;$objectAttribute)
			$type:=Value type:C1509($objectAttribute[$property])
			Case of 
				: ($type=Is BLOB:K8:12)
				: ($type=Is null:K8:31)
				: ($type=Is object:K8:27)
					For each ($subProp;$objectAttribute[$property])
						$collection.push(New object:C1471("Property";$property+"."+$subProp;"Value";$objectAttribute[$property][$subProp];"Type";Value type:C1509($objectAttribute[$property][$subProp])))
					End for each 
				: ($type=Is picture:K8:10)
				: ($type=Is pointer:K8:14)
				: ($type=Is undefined:K8:13)
				: ($type=Object array:K8:28)
				: ($type=Is collection:K8:32)
					Case of 
						: ($objectAttribute[$property].length=0)
						: (Value type:C1509($objectAttribute[$property][0])=Is object:K8:27)
							$lineIndex:=0
							For each ($element;$objectAttribute[$property])
								$lineIndex:=$lineIndex+1
								For each ($subProp;$element)
									$collection.push(New object:C1471("Property";$property+"["+String:C10($lineIndex)+"]."+$subProp;"Value";$element[$subProp];"Type";Value type:C1509($element[$subProp])))
								End for each 
							End for each 
						Else 
							$collection.push(New object:C1471("Property";$property;"Value";$objectAttribute[$property].join(", ");"Type";$type))
					End case 
				Else   //is Boolean; is date; is longint; is text; is real; is time
					$collection.push(New object:C1471("Property";$property;"Value";$objectAttribute[$property];"Type";$type))
			End case 
		End for each 
	End if 
End if 

$0:=$collection

