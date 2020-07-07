$event:=Form event code:C388
Case of 
	: ($event=On Getting Focus:K2:7)
		OBJECT SET VISIBLE:C603(*;"_PRODUCTLIST_";Form:C1466.queryString#"")
		
	: ($event=On Losing Focus:K2:8)
		OBJECT SET VISIBLE:C603(*;"_PRODUCTLIST_";False:C215)
		
	: ($event=On After Keystroke:K2:26)
		$value:=Get edited text:C655
		If ($value#"")
			OBJECT SET VISIBLE:C603(*;"_PRODUCTLIST_";True:C214)
			Form:C1466.productsList:=ds:C1482.PRODUCTS.query("Reference = :1 or Name = :1";"@"+$value+"@")
		Else 
			OBJECT SET VISIBLE:C603(*;"_PRODUCTLIST_";False:C215)
		End if 
End case 
