$name:=Util_FilterPropertyName (Form:C1466.propertyName)
If ($name#Form:C1466.propertyName)
	BEEP:C151
	ALERT:C41(Util_Get_LocalizedMessage ("ForbiddenCharacter";Form:C1466.propertyName))
	Form:C1466.propertyName:=$name
	GOTO OBJECT:C206(*;"_PROP_NAME_")
End if 