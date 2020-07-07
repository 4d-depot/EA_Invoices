//%attributes = {}
C_OBJECT:C1216($currentEntity)

  //We will set the Window Title according to the actual content and context
  //...as well as Buttons

If (Count parameters:C259>0)
	$actualPage:=$1
Else 
	$actualPage:=FORM Get current page:C276
End if 
If (Form:C1466.selectedSubset=Null:C1517)
	$subset:=New object:C1471
Else 
	$subset:=Form:C1466.selectedSubset
End if 
If (Form:C1466.displayedSelection=Null:C1517)
	$selection:=Form:C1466.selectedSubset
Else 
	$selection:=Form:C1466.displayedSelection
End if 
If (Form:C1466.clickedEntity=Null:C1517)
	If (Form:C1466.editEntity#Null:C1517)
		$currentEntity:=Form:C1466.editEntity
	End if 
Else 
	$currentEntity:=Form:C1466.clickedEntity
End if 

Case of 
	: (Form:C1466.displayMode="PAGE")
		If ($currentEntity=Null:C1517)
			$display:=Form:C1466.dataClassName
		Else 
			$display:="ID "+$currentEntity.getKey(dk key as string:K85:16)
			$display:=Form:C1466.dataClassName+" ("+Get localized string:C991("A_Record")+" "+$display+")"
		End if 
		SET WINDOW TITLE:C213($display;Form:C1466.windowRef)
		
	: ($actualPage=1)
		Util_SetWindowTitle ($selection;$subset;Form:C1466.dataClassName;$currentEntity;$actualPage;Current form window:C827)
		
	: ($actualPage=2)
		Util_SetWindowTitle ($selection;$subset;Form:C1466.dataClassName;Form:C1466.editEntity;$actualPage;Current form window:C827)
		  //We have to disable buttons depending on the entity position
		Util_HandleButtons (Form:C1466.editEntity)
		
End case 
  //We have to disable buttons which make sense only if some lines are selected
OBJECT SET ENABLED:C1123(*;"@_SEL_@";(Form:C1466.selectedSubset.length>0))


If (Form:C1466.editEntity#Null:C1517)  //Specific for each DataClass
	Case of 
		: (Form:C1466.dataClassName="INVOICES")  //Specific for Invoices
			$proforma:=Not:C34(OB Is empty:C1297(Form:C1466.editEntity))
			If ($proforma)
				$proforma:=Form:C1466.editEntity.ProForma
			End if 
			OBJECT SET VISIBLE:C603(*;"@_PROF_@";$proforma)
			
	End case 
End if 