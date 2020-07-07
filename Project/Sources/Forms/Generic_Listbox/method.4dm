C_TEXT:C284($object)

$event:=Form event code:C388

Case of 
	: ($event=On Load:K2:1)
		  //General
		Form:C1466.queryString:=""
		Form:C1466.inSelection:=False:C215
		Form:C1466.dataClass:=ds:C1482.INVOICES
		Form:C1466.dataClassName:=Form:C1466.dataClass.getInfo().name
		Form:C1466.dataClassPtr:=Table:C252(Form:C1466.dataClass.getInfo().tableNumber)
		
		SetupListbox 
		
	: ($event=On Close Box:K2:21)
		Case of 
			: (FORM Get current page:C276=1)
				BEEP:C151
				  //CANCEL  // CHECK IF record needs to be saved
				
				
		End case 
		
End case 
