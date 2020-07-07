$evt:=Form event code:C388

Case of 
	: ($evt=On Drag Over:K2:13)
		If (Form:C1466.clipObject=Null:C1517)
			$0:=-1
		End if 
		
	: ($evt=On Drop:K2:12)
		If (Form:C1466.clipObject#Null:C1517)
			Util_Query_SetCriteriaLine (Form:C1466.clipObject)
		End if 
		
End case 