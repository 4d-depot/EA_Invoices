C_OBJECT:C1216($object)

$evt:=Form event code:C388

Case of 
	: ($evt=On Double Clicked:K2:5)
		If (Form:C1466.propertySelected#Null:C1517)
			$object:=Form:C1466.propertySelected
			Form:C1466.criteriaList:=Form:C1466.criteriaList.push($object)
			$object.criteriaDesc:=False:C215
			$object.criteriaPict:=Choose:C955(Num:C11($object.criteriaDesc);Form:C1466.pictAsc;Form:C1466.pictDesc)
		End if 
		
	: ($evt=On Begin Drag Over:K2:44)
		Form:C1466.clipObject:=Form:C1466.propertySelected
		
		
End case 