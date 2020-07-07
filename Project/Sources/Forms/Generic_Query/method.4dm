$evt:=Form event code:C388

Case of 
	: ($evt=On Load:K2:1)
		  //ARRAY BOOLEAN(lb_Criterias;0)
		ARRAY OBJECT:C1221(qry_ar_Logicals;0)
		ARRAY TEXT:C222(qry_ar_Properties;0)
		ARRAY TEXT:C222(qry_ar_PropertyName;0)
		ARRAY OBJECT:C1221(qry_ar_Operators;0)
		ARRAY OBJECT:C1221(qry_ar_Values;0)
		Form:C1466.queryMenus:=Util_Query_PrepareMenus 
		Form:C1466.blankCell:=New object:C1471("valueType";"color";"value";0x00EEEEEE)
		OBJECT SET ENABLED:C1123(*;"@_VAL_@";False:C215)
		qry_ar_PropertyName:=0
		
	: ($evt=On Clicked:K2:4)
		
		
End case 

If (($evt=On Load:K2:1) | ($evt=On Clicked:K2:4) | ($evt=On Double Clicked:K2:5) | ($evt=On Drop:K2:12) | ($evt=On Selection Change:K2:29) | ($evt=On Data Change:K2:15))
	OBJECT SET ENABLED:C1123(*;"@_ADD_@";((Form:C1466.propertySelected#Null:C1517) & (Form:C1466.propertyPosition<=Form:C1466.propertyList.length)))
	OBJECT SET ENABLED:C1123(*;"@_REM_@";(qry_ar_PropertyName>0))
	OBJECT SET ENABLED:C1123(*;"@_VAL_@";(Size of array:C274(qry_ar_Operators)>0))
End if 
