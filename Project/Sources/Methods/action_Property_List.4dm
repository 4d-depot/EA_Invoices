//%attributes = {}
C_LONGINT:C283($column;$row)
C_COLLECTION:C1488($colFound;$collection_Main;$collection_Sel)
C_OBJECT:C1216($collection_Cur)
C_LONGINT:C283($collection_Pos)
C_TEXT:C284($LBName)

$LBName:=$1

$event:=Form event code:C388

Case of 
	: (($event=On Clicked:K2:4) | ($event=On Double Clicked:K2:5))
		If (Right click:C712 | Contextual click:C713 | ($event=On Double Clicked:K2:5))
			If (Form:C1466.recordCanBeSaved)
				LISTBOX GET CELL POSITION:C971(*;$LBName;$column;$row)
				action_Property_Add ($LBName)
			End if 
		End if 
End case 
