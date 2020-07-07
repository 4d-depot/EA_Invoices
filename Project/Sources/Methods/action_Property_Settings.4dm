//%attributes = {}
C_TEXT:C284($LBName)
C_BOOLEAN:C305($fl_Enterable)

$LBName:=$1
$fl_Enterable:=$2

$settings:=Form:C1466.settings

$settingMenu:=Create menu:C408
APPEND MENU ITEM:C411($settingMenu;Get localized string:C991("Show Horizontal Grid Lines"))
SET MENU ITEM PARAMETER:C1004($settingMenu;-1;"HGrid")
If ($settings.Display.HLinesVisible)
	SET MENU ITEM MARK:C208($settingMenu;-1;Char:C90(18))
End if 
APPEND MENU ITEM:C411($settingMenu;Get localized string:C991("Show Vertical Grid Lines"))
SET MENU ITEM PARAMETER:C1004($settingMenu;-1;"VGrid")
If ($settings.Display.VLinesVisible)
	SET MENU ITEM MARK:C208($settingMenu;-1;Char:C90(18))
End if 
If ($fl_Enterable)
	APPEND MENU ITEM:C411($settingMenu;Get localized string:C991("Enterable"))
	SET MENU ITEM PARAMETER:C1004($settingMenu;-1;"Enterable")
	If ($settings.Display.enterInList)
		SET MENU ITEM MARK:C208($settingMenu;-1;Char:C90(18))
	End if 
End if 
APPEND MENU ITEM:C411($settingMenu;Get localized string:C991("Alternate Background color"))
SET MENU ITEM PARAMETER:C1004($settingMenu;-1;"AlternateBckg")
If ($settings.Display.AlternateColor)
	SET MENU ITEM MARK:C208($settingMenu;-1;Char:C90(18))
End if 

$choice:=Dynamic pop up menu:C1006($settingMenu)  //Displays the popup menu
RELEASE MENU:C978($settingMenu)
  //Never forget to release every menus...

$fl_DoIt:=True:C214
Case of 
	: ($choice="HGrid")
		$settings.Display.HLinesVisible:=Not:C34($settings.Display.HLinesVisible)
		
	: ($choice="VGrid")
		$settings.Display.VLinesVisible:=Not:C34($settings.Display.VLinesVisible)
		
	: ($choice="Enterable")
		$settings.Display.enterInList:=Not:C34($settings.Display.enterInList)
		
	: ($choice="AlternateBckg")
		$settings.Display.AlternateColor:=Not:C34($settings.Display.AlternateColor)
		
	Else 
		$fl_DoIt:=False:C215
End case 

If ($fl_DoIt)
	Settings_ApplyToListBox ($settings;$LBName;$fl_Enterable)
End if 