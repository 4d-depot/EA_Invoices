$line:=Find in array:C230(lb_Criterias;True:C214)
If ($line>0)
	LISTBOX DELETE ROWS:C914(lb_Criterias;$line;1)
	LISTBOX SELECT ROW:C912(lb_Criterias;0;lk remove from selection:K53:3)
	qry_ar_Properties:=0
	If (Size of array:C274(lb_Criterias)>0)
		If (qry_ar_Logicals{1}.valueType="text")
			qry_ar_Logicals{1}:=Form:C1466.blankCell
		End if 
	End if 
End if 
