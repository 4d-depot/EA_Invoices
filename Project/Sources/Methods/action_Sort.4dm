//%attributes = {}
If (Macintosh option down:C545)
	  //If you want an extended method using the Table properties, objects fields, and related tables
	If (Form:C1466.displayedSelection=Null:C1517)
		Form:C1466.displayedSelection:=Util_OrderSelection_Extended (ds:C1482;Form:C1466.dataClass;Form:C1466.dataClass.newSelection(dk keep ordered:K85:11))
	Else 
		Form:C1466.displayedSelection:=Util_OrderSelection_Extended (ds:C1482;Form:C1466.dataClass;Form:C1466.displayedSelection)
	End if 
	
Else 
	  //If you want a simple method using only the Table properties
	Form:C1466.displayedSelection:=Util_OrderSelection_Simple (Form:C1466.dataClass;Form:C1466.displayedSelection)
	
End if 
