//%attributes = {}
C_OBJECT:C1216($selection_Cur;$selection_Main;$selection_Sel;$status)
C_LONGINT:C283($selection_Pos)
C_TEXT:C284($LBName)

$LBName:=$1  //Name of the Listbox
$relation:=$2  //Name of the Relational Attribute One-to-Many

$fieldName:=$relation

  //Instead of passing parameters like ;Form.data_Numbers;Form.cur_Numbers;Form.sel_Numbers;Form.pos_Numbers)...
  //..We can get the different collections from the name of the Listbox
  //For instance, if the name is _LB_Numbers, we can extract "Numbers", and then (thanks to the Bracket Notation)...
  //..get the Collections themselves:
If (Form:C1466.recordCanBeSaved)
	$selection_Main:=Form:C1466.editEntity[$relation]  //returns Form.editEntity.Lines_Fm_Invoices
	$selection_Cur:=Form:C1466["cur_"+$fieldName]
	$selection_Sel:=Form:C1466["sel_"+$fieldName]
	$selection_Pos:=Form:C1466["pos_"+$fieldName]
	
	$event:=Form event code:C388
	
	If ($event=On Clicked:K2:4)
		If ($selection_Sel.length>0)
			If ($selection_Cur#Null:C1517)
				CONFIRM:C162(Util_Get_LocalizedMessage ("RemoveLine";String:C10($selection_Pos));Get localized string:C991("Remove it");Get localized string:C991("Cancel"))
				
				If (OK=1)
					$status:=$selection_Cur.drop()
					
					If ($status.success)
						Form:C1466.editEntity.reload()
						  //LISTBOX SELECT ROW(*;$LBName;0;lk remove from selection)
						Util_EntityLoad_Specific (False:C215)
						
					Else   //This case should very unlikely happen, for the Record has been locked
						ALERT:C41(Util_Get_LocalizedMessage ("Recordnotdeleted";$status.statusText))
						
					End if 
				End if 
			End if 
		End if 
	End if 
End if 