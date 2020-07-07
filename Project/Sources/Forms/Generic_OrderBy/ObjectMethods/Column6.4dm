If (Form event code:C388=On Clicked:K2:4)
	If (Form:C1466.criteriaSelected#Null:C1517)
		Form:C1466.criteriaSelected.criteriaDesc:=Not:C34(Form:C1466.criteriaSelected.criteriaDesc)
		Form:C1466.criteriaSelected.criteriaPict:=Choose:C955(Num:C11(Form:C1466.criteriaSelected.criteriaDesc);Form:C1466.pictAsc;Form:C1466.pictDesc)
		  //***************************
		Form:C1466.criteriaList:=Form:C1466.criteriaList  //To force the update of the list
		  //***************************
	End if 
End if 