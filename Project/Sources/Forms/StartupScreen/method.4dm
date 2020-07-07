$event:=Form event code:C388

Case of 
	: ($event=On Load:K2:1)
		OBJECT Get pointer:C1124(Object named:K67:5;"_TITLE_")->:=Get localized string:C991("STARTUP")
		OBJECT Get pointer:C1124(Object named:K67:5;"_PRODUCTS_Text")->:=Get localized string:C991("PRODUCTS")
		OBJECT Get pointer:C1124(Object named:K67:5;"_CLIENTS_Text")->:=Get localized string:C991("CLIENTS")
		OBJECT Get pointer:C1124(Object named:K67:5;"_INVOICES_Text")->:=Get localized string:C991("INVOICES")
		OBJECT Get pointer:C1124(Object named:K67:5;"_SETTINGS_Text")->:=Get localized string:C991("SETTINGS")
		
End case 