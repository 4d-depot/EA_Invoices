$evt:=Form event code:C388

Case of 
	: (($evt=On Load:K2:1) | ($evt=On Clicked:K2:4) | ($evt=On Selection Change:K2:29) | ($evt=On Double Clicked:K2:5))
		
		OBJECT SET ENABLED:C1123(*;"@_ADD_@";((Form:C1466.propertySelected#Null:C1517) & (Form:C1466.propertyPosition<=Form:C1466.propertyList.length)))
		OBJECT SET ENABLED:C1123(*;"@_REM_@";(Form:C1466.criteriaSelected#Null:C1517))
		OBJECT SET ENABLED:C1123(*;"@_VAL_@";(Form:C1466.criteriaList.length>0))
		  //LISTBOX SET PROPERTY(*;"_DESTPROP_";lk hide selection highlight;lk yes)
		
End case 

