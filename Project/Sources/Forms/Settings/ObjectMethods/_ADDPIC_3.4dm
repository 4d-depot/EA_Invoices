C_PICTURE:C286($pict)

READ PICTURE FILE:C678("";$pict)

If (OK=1)
	Form:C1466.settings.Company.Logo:=$pict
End if 