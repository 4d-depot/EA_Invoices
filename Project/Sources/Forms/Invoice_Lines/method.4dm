$event:=Form event code:C388

Case of 
	: ($event=On Load:K2:1)
		Form:C1466.queryString:=""
		OBJECT SET ENABLED:C1123(*;"@_BUT_OK_@";(Form:C1466.case="MOD"))
		GOTO OBJECT:C206(*;"_PROP_Product_Reference_")
		If (Form:C1466.case="MOD")
			OBJECT SET VISIBLE:C603(*;"_QUERY_@";True:C214)
		End if 
		
	: ($event=On Data Change:K2:15)
		Form:C1466.Total:=Form:C1466.Quantity*Form:C1466.Unit_Price*(100-Form:C1466.Discount_Rate)/100
		Form:C1466.Total_Tax:=Round:C94(Form:C1466.Total*Form:C1466.Tax_Rate/100;2)
		OBJECT SET ENABLED:C1123(*;"@_BUT_OK_@";(Form:C1466.case="MOD") | (Form:C1466.Quantity>0))
	Else 
		
		  //If ((Form.type="COL") | (Form.type="TEXT"))  //Because we decided to not accept an empty text or an empty collection, but it can be changed...
		  //OBJECT SET ENABLED(*;"@_BUT_OK_@";((Form.propertyName#"") & (Form["propertyValue"+Form.type]#"")) | (Form.case="MOD"))
		  //Else 
		  //OBJECT SET ENABLED(*;"@_BUT_OK_@";(Form.propertyName#"") | (Form.case="MOD"))
		  //End if 
End case 

