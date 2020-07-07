//%attributes = {}
$listbox:=$1

If (Form:C1466.editEntity#Null:C1517)
	If (Not:C34(OB Is empty:C1297(Form:C1466.editEntity)))
		$n:=Form:C1466.editEntity.indexOf(Form:C1466.displayedSelection)  //Find the position of the current selected entity 
		
		If ($n<1)
			LISTBOX SELECT ROW:C912(*;$listbox;0;lk remove from selection:K53:3)  //Deselect every line
		Else 
			LISTBOX SELECT ROW:C912(*;$listbox;$n+1;lk replace selection:K53:1)  //Update the highlighted line
			OBJECT SET SCROLL POSITION:C906(*;$listbox;$n+1;1)  // displays 4th row of 2nd column of list box in the first position
		End if 
	End if 
End if 
