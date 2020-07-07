C_LONGINT:C283($foreColor;$backColor)
$ObjName:="@_COLOR_@"
OBJECT GET RGB COLORS:C1074(*;$ObjName;$foreColor;$backColor)
$backColor:=Select RGB color:C956($backColor)
If (OK=1)
	OBJECT SET RGB COLORS:C628(*;$ObjName;$foreColor;$backColor)
	Form:C1466.settings.Display.AlternateColorRGB:=$backColor
End if 