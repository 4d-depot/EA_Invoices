$evt:=Form event code:C388

Case of 
	: ($evt=On Double Clicked:K2:5)
		If (Form:C1466.propertySelected#Null:C1517)
			Util_Query_SetCriteriaLine (Form:C1466.propertySelected)
		End if 
		
	: ($evt=On Begin Drag Over:K2:44)
		Form:C1466.clipObject:=Form:C1466.propertySelected
		
		
End case 