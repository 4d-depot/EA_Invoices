//%attributes = {}
C_COLLECTION:C1488($colFound;$collection_Main;$collection_Sel)
C_OBJECT:C1216($collection_Cur)
C_LONGINT:C283($collection_Pos)
C_TEXT:C284($LBName)

$LBName:=$1
$collection_Main:=$2
$collection_Cur:=$3
$collection_Sel:=$4
$collection_Pos:=$5

  //This is the traditional way. with passing parameters Form.data_Optional_Data;Form.cur_Optional_Data;Form.sel_Optional_Data;Form.pos_Optional_Data)

  //For a more flexible way, have a look at action_Property_Delete

$event:=Form event code:C388

If ($event=On Clicked:K2:4)
	If ($collection_Sel.length>0)
		If ($collection_Cur#Null:C1517)
			CONFIRM:C162(Util_Get_LocalizedMessage ("RemoveProperty";$collection_Cur.Property);Get localized string:C991("Remove it");Get localized string:C991("Cancel"))
			
			If (OK=1)
				$collection_Main.remove($collection_Pos-1)
				$collection_Main:=$collection_Main
				LISTBOX SELECT ROW:C912(*;$LBName;0;lk remove from selection:K53:3)
			End if 
		End if 
	End if 
End if 
