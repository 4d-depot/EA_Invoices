//%attributes = {}
C_TEXT:C284($1;${2})
$resname:=$1

$message:=Get localized string:C991($resname)
If ((OK=1) & ($message#""))
	$message:=Replace string:C233($message;"[CR]";Char:C90(Carriage return:K15:38))
	For ($i;1;Count parameters:C259-1)
		$message:=Replace string:C233($message;"["+String:C10($i)+"]";${$i+1})
	End for 
Else 
	$message:=$resname
End if 

$0:=$message
