$evt:=Form event code:C388

Case of 
	: ($evt=On Load:K2:1)
		OBJECT SET VISIBLE:C603(*;"_TEXT_COL_";(Form:C1466.type="COL"))
		OBJECT SET VISIBLE:C603(*;"@_VALUE_@";False:C215)
		OBJECT SET VISIBLE:C603(*;"@_VALUE_"+Form:C1466.type+"_@";True:C214)
		OBJECT SET ENABLED:C1123(*;"@_BUT_OK_@";(Form:C1466.case="MOD"))
		Form:C1466.nameBefore:=Form:C1466.propertyName
		
	Else 
		If ($evt=On After Edit:K2:43)
			  //$p:=object get pointer(Object named;OBJECT Get name(Object with focus))
		End if 
		
		If ((Form:C1466.type="COL") | (Form:C1466.type="TEXT"))  //Because we decided to not accept an empty text or an empty collection, but it can be changed...
			OBJECT SET ENABLED:C1123(*;"@_BUT_OK_@";((Form:C1466.propertyName#"") & (Form:C1466["propertyValue"+Form:C1466.type]#"")) | (Form:C1466.case="MOD"))
		Else 
			OBJECT SET ENABLED:C1123(*;"@_BUT_OK_@";(Form:C1466.propertyName#"") | (Form:C1466.case="MOD"))
		End if 
End case 

