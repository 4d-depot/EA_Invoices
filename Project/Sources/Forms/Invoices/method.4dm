C_TEXT:C284($object)

$event:=Form event code:C388

Case of 
	: ($event=On Load:K2:1)
		  //General
		Form:C1466.queryString:=""
		Form:C1466.inSelection:=False:C215
		Form:C1466.dataClass:=ds:C1482.INVOICES
		Form:C1466.dataClassName:="INVOICES"  //To be replaced by :=$dataClass.getInfo().name  //The Table (DataClass) name
		Form:C1466.dataClassPtr:=->[INVOICES:2]  //To be replaced when it will be possible to get a pointer on a DataClass...
		Form:C1466.objectsNames:=New collection:C1472("")  //Names ob Object Fields containing Multiple Values
		Form:C1466.relatedDataClass:=ds:C1482.INVOICE_LINES
		
		  //Page 1
		Form:C1466.qryPropertyList:=New collection:C1472
		Form:C1466.popupPtr:=OBJECT Get pointer:C1124(Object named:K67:5;"_PROPERTIES_POPUP_")
		Util_GetSimplePropertyList (Form:C1466.popupPtr;Form:C1466.dataClass;Form:C1466.qryPropertyList;"COMPLETE")  //Creates the list of properties for the QuickSearch pop-up menu
		If (Form:C1466.displayMode="PAGE")
			Form:C1466.displayedSelection:=Form:C1466.openSelection
			Form:C1466.selectedSubset:=Form:C1466.openSubset
			Form:C1466.clickedEntity:=Form:C1466.openEntity
			Form:C1466.clickedEntityPosition:=0
		Else 
			Form:C1466.displayedSelection:=Form:C1466.dataClass.all()
			Form:C1466.selectedSubset:=Form:C1466.dataClass.newSelection()
			Form:C1466.clickedEntity:=New object:C1471
			Form:C1466.clickedEntityPosition:=0
		End if 
		OBJECT SET RGB COLORS:C628(*;"@Header@";0x00212121;0x00E0E5EE)
		
		  //Page 2
		Form:C1466.editEntity:=Form:C1466.clickedEntity
		Form:C1466.pictureName:=""
		  //Now we define the necessary elements for the Invoice_Lines included form
		Form:C1466.cur_Lines_Fm_Invoices:=New object:C1471
		Form:C1466.pos_Lines_Fm_Invoices:=0
		Form:C1466.sel_Lines_Fm_Invoices:=New collection:C1472
		Form:C1466.recordCanBeSaved:=False:C215
		
		Settings_ApplyToListBox (Form:C1466.settings;"_LB_INVOICE_LINES")
		
	: ($event=On Close Box:K2:21)
		Case of 
			: (FORM Get current page:C276=1)
				CANCEL:C270
				
			: (FORM Get current page:C276=2)
				action_Cancel 
		End case 
		
End case 

If (($event=On Load:K2:1) | ($event=On Selection Change:K2:29) | ($event=On Clicked:K2:4) | ($event=On Drop:K2:12) | ($event=On Data Change:K2:15) | ($event=On After Edit:K2:43))
	Util_UpdateOnContext 
End if 


