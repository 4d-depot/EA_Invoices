//%attributes = {}

C_LONGINT:C283($1;$pid)
C_OBJECT:C1216($invoices)
If (Count parameters:C259=0)
	
	For ($i;1;3)
		$pid:=Execute on server:C373(Current method name:C684;0;"QUERYING ON SERVER "+String:C10($i);10)
	End for 
	
Else 
	
	For ($i;1;4000)
		$invoices:=ds:C1482.INVOICES.query("Total > :1";Random:C100/3000).orderBy("Tax desc, Creation_Date asc")
	End for 
	
End if 

