//%attributes = {}
C_COLLECTION:C1488($colFound;$collection_Main;$collection_Sel)
C_OBJECT:C1216($collection_Cur)
C_LONGINT:C283($collection_Pos)
C_TEXT:C284($LBName)

$LBName:=$1
  //Instead of passing parameters like ;Form.data_Numbers;Form.cur_Numbers;Form.sel_Numbers;Form.pos_Numbers)...
  //..We can get the different collections from the name of the Listbox
  //For instance, if the name is _LB_Numbers, we can extract "Numbers", and then (thanks to the Bracket Notation)...
  //..get the Collections themselves:

$fieldName:=Substring:C12($LBName;Length:C16("_LB_")+1)

$collection_Main:=Form:C1466["data_"+$fieldName]  //This is exactly the same than Form.data_Numbers or Form.data_Optional_Data
$collection_Cur:=Form:C1466["cur_"+$fieldName]
$collection_Sel:=Form:C1466["sel_"+$fieldName]
$collection_Pos:=Form:C1466["pos_"+$fieldName]

$event:=Form event code:C388

If (($event=On Clicked:K2:4) | ($event=On Double Clicked:K2:5))
	
	$vAddMenu:=Create menu:C408
	If (Form:C1466.recordCanBeSaved)
		APPEND MENU ITEM:C411($vAddMenu;Get localized string:C991("Add Text"))
		SET MENU ITEM PARAMETER:C1004($vAddMenu;-1;"ADD_Text")
		APPEND MENU ITEM:C411($vAddMenu;Get localized string:C991("Add Numeric"))
		SET MENU ITEM PARAMETER:C1004($vAddMenu;-1;"ADD_Num")
		APPEND MENU ITEM:C411($vAddMenu;Get localized string:C991("Add Date"))
		SET MENU ITEM PARAMETER:C1004($vAddMenu;-1;"ADD_Date")
		APPEND MENU ITEM:C411($vAddMenu;Get localized string:C991("Add Boolean"))
		SET MENU ITEM PARAMETER:C1004($vAddMenu;-1;"ADD_Bool")
		APPEND MENU ITEM:C411($vAddMenu;Get localized string:C991("Add List"))
		SET MENU ITEM PARAMETER:C1004($vAddMenu;-1;"ADD_Col")
		If ($collection_Sel.length>0)
			APPEND MENU ITEM:C411($vAddMenu;"-")
			APPEND MENU ITEM:C411($vAddMenu;Util_Get_LocalizedMessage ("Modify Property";$collection_Cur.Property))
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
			$form.title:=Util_Get_LocalizedMessage ("Modifying Property";$collection_Cur.Property)
			$form.type:=Util_ConvertTypeToText ($collection_Cur.Type)
			$form.propertyValueText:=""
			$form.propertyValueNum:=0
			$form.propertyValueDate:=Current date:C33
			$form.propertyValueBool:=False:C215
			$form.propertyValueCol:=""
			If ($form.type="Col")
				$form.propertyValueCol:=Replace string:C233($collection_Cur.Value;", ";",")
				$form.propertyValueCol:=Replace string:C233($form.propertyValueCol;",";Char:C90(Carriage return:K15:38))
			Else 
				$form["propertyValue"+$form.type]:=$collection_Cur.Value
			End if 
			$form.propertyName:=$collection_Cur.Property
			
		Else   //We want to add a proprty
			$form.case:="ADD"
			$form.title:=Get localized string:C991("New Property")
			$form.type:=Replace string:C233($choice;"ADD_";"")
			$form.propertyValueText:=""
			$form.propertyValueNum:=0
			$form.propertyValueDate:=Current date:C33
			$form.propertyValueBool:=False:C215
			$form.propertyValueCol:=""
			$form.propertyName:=""
		End if 
		
		$w:=Open form window:C675("Generic_EditProperty";Sheet form window:K39:12)
		DIALOG:C40("Generic_EditProperty";$form)
		CLOSE WINDOW:C154($w)
		
		If (OK=1)
			If ($form.case="MOD")
				$newObject:=$collection_Cur
				$valueType:=$collection_Cur.Type
				$index:=$collection_Pos
			Else 
				$newObject:=New object:C1471
				$valueType:=Util_ConvertText2Type ($form.type)
				$index:=-5
			End if 
			
			Case of 
				: ($form.type="Text")
					$newObject.Value:=$form.propertyValueText
				: ($form.type="Num")
					$newObject.Value:=$form.propertyValueNum
				: ($form.type="Date")
					$newObject.Value:=$form.propertyValueDate
				: ($form.type="Bool")
					$newObject.Value:=$form.propertyValueBool
				: ($form.type="Col")
					$text:=Replace string:C233($form.propertyValueCol;", ";",")
					$text:=Replace string:C233($text;Char:C90(Carriage return:K15:38);",")
					$text:=Replace string:C233($text;",";", ")
					$newObject.Value:=$text
			End case 
			$name:=Util_FilterPropertyName ($form.propertyName)
			If ($form.case="ADD")
				Repeat 
					$colFound:=$collection_Main.indices("Property = :1";$name)  //We search if the property name already exists
					If ($colFound.length=0)  //If it does't exist
						$flOK:=True:C214
					Else   //It exists, we look if it's the same element
						$flOK:=($colFound[0]=$index)
					End if 
					If (Not:C34($flOK))  //It exists, so we modify the name
						$name:=$name+"_"+String:C10($index)
					End if 
				Until ($flOK)
			End if 
			$newObject.Property:=$name
			$newObject.Type:=Util_ConvertText2Type ($form.type)
			If ($form.case="ADD")
				$collection_Main.push($newObject)
			End if 
		End if 
		$collection_Main:=$collection_Main
		Form:C1466["data_"+$fieldName]:=Form:C1466["data_"+$fieldName]
	End if 
End if 







