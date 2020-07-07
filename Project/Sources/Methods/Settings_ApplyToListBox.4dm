//%attributes = {}
C_LONGINT:C283($foregroundColor;$backgroundColor)
C_OBJECT:C1216($settings)
C_TEXT:C284($listboxName)

$settings:=$1
$listboxName:=$2
$fl_Enterable:=$3

LISTBOX SET GRID:C841(*;$listboxName;$settings.Display.HLinesVisible;$settings.Display.VLinesVisible)
OBJECT GET RGB COLORS:C1074(*;$listboxName;$foregroundColor;$backgroundColor)
If ($settings.Display.AlternateColor)
	OBJECT SET RGB COLORS:C628(*;$listboxName;$foregroundColor;$backgroundColor;$settings.Display.AlternateColorRGB)
Else 
	OBJECT SET RGB COLORS:C628(*;$listboxName;$foregroundColor;$backgroundColor;Background color none:K23:10)
End if 
If ($fl_Enterable)
	OBJECT SET ENTERABLE:C238(*;"_FIELD_Value_";$settings.Display.enterInList & Form:C1466.recordCanBeSaved)
End if 
