//%attributes = {}
C_OBJECT:C1216($colFound;$selection_Main;$selection_Sel;$status)
C_OBJECT:C1216($selection_Cur)
C_LONGINT:C283($selection_Pos)
C_TEXT:C284($LBName)

$LBName:=$1  //Name of the Listbox
$relation:=$2  //Name of the Relational Attribute One-to-Many

$fieldName:=$relation

If (Form:C1466.recordCanBeSaved)
	$selection_Main:=Form:C1466.editEntity[$relation]  //returns Form.editEntity.Lines_Fm_Invoices
	$selection_Cur:=Form:C1466["cur_"+$fieldName]
	$selection_Sel:=Form:C1466["sel_"+$fieldName]
	$selection_Pos:=Form:C1466["pos_"+$fieldName]
	
	$event:=Form event code:C388
	
	If (Right click:C712 | ($event=On Double Clicked:K2:5))
		
		$vAddMenu:=Create menu:C408
		If (Form:C1466.recordCanBeSaved)
			APPEND MENU ITEM:C411($vAddMenu;Get localized string:C991("Add Line"))
			SET MENU ITEM PARAMETER:C1004($vAddMenu;-1;"ADD_Line")
			If ($selection_Sel.length>0)
				APPEND MENU ITEM:C411($vAddMenu;"-")
				APPEND MENU ITEM:C411($vAddMenu;Util_Get_LocalizedMessage ("Modify Line";String:C10($selection_Cur.Line_Number)))
				SET MENU ITEM PARAMETER:C1004($vAddMenu;-1;"MOD")
			End if 
		Else 
			APPEND MENU ITEM:C411($vAddMenu;Get localized string:C991("No_Click"))
			SET MENU ITEM PARAMETER:C1004($vAddMenu;-1;"NOCLICK")
			DISABLE MENU ITEM:C150($vAddMenu;-1)
		End if 
		$choice:=Dynamic pop up menu:C1006($vAddMenu)  //Displays the popup menu
		RELEASE MENU:C978($vAddMenu)  //Never forget to release every menus...
		
		If (($choice#"") & ($choice#"NOCLICK"))
			$form:=New object:C1471
			If ($choice="MOD")  //We want to modify the selected property
				$form.case:="MOD"
				$form.title:=Util_Get_LocalizedMessage ("Modifying Line";String:C10($selection_Cur.Line_Number))
				$form.Line_Number:=$selection_Cur.Line_Number
				$form.Invoice_ID:=$selection_Cur.Invoice_ID
				$form.Product_ID:=$selection_Cur.Product_ID
				$form.Product_Reference:=$selection_Cur.Product.Reference
				$form.Product_Name:=$selection_Cur.Product.Name
				$form.Quantity:=$selection_Cur.Quantity
				$form.Unit_Price:=$selection_Cur.Unit_Price
				$form.Discount_Rate:=$selection_Cur.Discount_Rate
				$form.Tax_Rate:=$selection_Cur.Tax_Rate
				$form.Total:=$selection_Cur.Total
				$form.Total_Tax:=$selection_Cur.Total_Tax
				$form.Product_Picture:=$selection_Cur.Product.Picture
				
			Else   //We want to add a proprty
				$form.case:="ADD"
				$form.title:=Get localized string:C991("Adding Line")
				$form.Line_Number:=$selection_Main.max("Line_Number")+1
				$form.Invoice_ID:=Form:C1466.editEntity.ID
				$form.Product_ID:=0
				$form.Product_Reference:=""
				$form.Product_Name:=""
				$form.Quantity:=0
				$form.Unit_Price:=0
				$form.Discount_Rate:=0
				$form.Tax_Rate:=0
				$form.Total:=0
				$form.Total_Tax:=0
				C_PICTURE:C286($pict)
				$form.Product_Picture:=$pict
				
			End if 
			
			$w:=Open form window:C675("Invoice_Lines";Sheet form window:K39:12)
			DIALOG:C40("Invoice_Lines";$form)
			CLOSE WINDOW:C154($w)
			
			If (OK=1)
				If ($form.case="MOD")
					$entity:=$selection_Cur
					$index:=$selection_Pos
				Else 
					$entity:=Form:C1466.relatedDataClass.new()
					$entity.Line_Number:=$form.Line_Number
				End if 
				
				$entity.Invoice_ID:=$form.Invoice_ID
				$entity.Product_ID:=$form.Product_ID
				$entity.Product.Reference:=$form.Product_Reference
				$entity.Product.Name:=$form.Product_Name
				$entity.Quantity:=$form.Quantity
				$entity.Unit_Price:=$form.Unit_Price
				$entity.Discount_Rate:=$form.Discount_Rate
				$entity.Tax_Rate:=$form.Tax_Rate
				$entity.Total:=$form.Total
				$entity.Total_Tax:=$form.Total_Tax
				$status:=$entity.save()
				If ($status.success)
					If ($form.case="ADD")
						$selection_Main.add($entity)
					End if 
					Form:C1466.editEntity.reload()
					  //$selection_Main.refresh()
				End if 
				Util_EntityLoad_Specific ($form.case="ADD")
				
				$selection_Main:=Form:C1466.editEntity.Lines_Fm_Invoices
				
			Else   //This case should very unlikely happen, for the Record has been locked
				ALERT:C41(Util_Get_LocalizedMessage ("Recordnotbeensaved";$status.statusText))
				
			End if 
		End if 
	End if 
	
End if 





