//%attributes = {}
C_OBJECT:C1216($formData;$selection)
C_TEXT:C284($dialog)

$what2Do:=$1


Case of 
	: ($what2Do="OPEN")
		$dialog:=Form:C1466.currentDialog
		GET WINDOW RECT:C443($left;$top;$right;$bottom;Frontmost window:C447)
		$selection:=Form:C1466.dataClass.query("ID = :1";Form:C1466.clickedEntity.ID)
		
		$formData:=OB Copy:C1225(Form:C1466)
		$formData.settings:=Settings_GetCurrent 
		$formData.displayMode:="PAGE"
		$formData.openSelection:=$selection
		$formData.openSubset:=$selection
		$formData.openEntity:=Form:C1466.clickedEntity
		
		$windowReference:=Open form window:C675($dialog;Plain form window:K39:10;$left+20;$top+20)
		$formData.windowRef:=$windowReference
		CALL FORM:C1391($windowReference;"Call_Open1Record";$formData;$selection)
		DIALOG:C40($dialog;$formData;*)
		
	: ($what2Do="CLOSE")
		
		CANCEL:C270
		
End case 
