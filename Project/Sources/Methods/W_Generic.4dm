//%attributes = {}
C_OBJECT:C1216($settings;$targetSelection)
C_LONGINT:C283($left;$top;$right;$bottom;$windowRef)
C_BOOLEAN:C305($fl_Select)

$dialog:=$1
$fl_Select:=$2
If ($fl_Select)
	$targetSelection:=$3
End if 

$fl_Exist:=(Storage:C1525[$dialog]#Null:C1517)  //We check if this Window already exists

$formData:=New object:C1471
$formData.settings:=Settings_GetCurrent 
$formData.currentDialog:=$dialog
$formData.displayMode:="LIST"

  //Form.settings.Modes.multiRecords

If ($fl_Exist)  //If yes...
	ARRAY LONGINT:C221($ar_References;0)
	WINDOW LIST:C442($ar_References)
	$fl_Exist:=(Find in array:C230($ar_References;Storage:C1525[$dialog].windowRef)>0)  //...we verify if it still exist
	$windowRef:=Storage:C1525[$dialog].windowRef
	
End if 
If ($fl_Exist)  //If yes, we just bring the Dialog to front
	GET WINDOW RECT:C443($left;$top;$right;$bottom;$windowRef)
	SET WINDOW RECT:C444($left;$top;$right;$bottom;$windowRef)  //These 2 lines will bring the Window at the frontmost level
	
Else   //if not, we create the Dialog
	Case of 
		: ($dialog="StartupScreen")
			$windowReference:=Open form window:C675($dialog;Plain form window:K39:10;*)
			
		: ($dialog="Settings")
			$windowReference:=Open form window:C675($dialog;Controller form window:K39:17;Horizontally centered:K39:1;Vertically centered:K39:4)
			
		Else 
			If ($fl_Select)
				GET WINDOW RECT:C443($left;$top;$right;$bottom;Frontmost window:C447)
				$windowReference:=Open form window:C675($dialog;Plain form window:K39:10;$left+20;$top+20;*)
			Else 
				$windowReference:=Open form window:C675($dialog;Plain form window:K39:10;*)
			End if 
			
	End case 
	
	$object:=New shared object:C1526  //Then we add the Dialog in the list
	Use ($object)
		$object.name:=$dialog  //This is not necessary, but it helps for debugging...
		$object.windowRef:=$windowReference
	End use 
	Use (Storage:C1525)
		Storage:C1525[$dialog]:=$object
	End use 
End if 

If ($fl_Select)
	CALL FORM:C1391(Storage:C1525[$dialog].windowRef;"Call_Update_Select";$targetSelection)
End if 
If (Not:C34($fl_Exist))
	DIALOG:C40($dialog;$formData;*)
End if 




