//%attributes = {}
C_PICTURE:C286($pict)
C_TEXT:C284($pictureName)

$pictureName:=$1

If ($pictureName#"")
	READ PICTURE FILE:C678("";$pict)
	If (OK=1)
		Form:C1466.editEntity[$pictureName]:=$pict
	End if 
End if 