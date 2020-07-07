C_OBJECT:C1216($object)

If (Form:C1466.propertySelected#Null:C1517)
	$object:=Form:C1466.propertySelected
	Form:C1466.criteriaList:=Form:C1466.criteriaList.push($object)
	$object.criteriaDesc:=False:C215
	$object.criteriaPict:=Choose:C955(Num:C11($object.criteriaDesc);Form:C1466.pictAsc;Form:C1466.pictDesc)
	Form:C1466.criteriaList:=Form:C1466.criteriaList
End if 
