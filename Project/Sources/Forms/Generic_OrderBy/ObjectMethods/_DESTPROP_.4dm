C_OBJECT:C1216($object)

$evt:=Form event code:C388

Case of 
	: ($evt=On Clicked:K2:4)
		
	: ($evt=On Drag Over:K2:13)
		If (Form:C1466.clipObject=Null:C1517)
			$0:=-1
		End if 
		
	: ($evt=On Drop:K2:12)
		If (Form:C1466.clipObject#Null:C1517)
			$object:=Form:C1466.clipObject
			Form:C1466.criteriaList.push($object)
			$object.criteriaDesc:=False:C215
			$object.criteriaPict:=Choose:C955(Num:C11($object.criteriaDesc);Form:C1466.pictAsc;Form:C1466.pictDesc)
			CLEAR VARIABLE:C89(Form:C1466.clipObject)
		End if 
End case 