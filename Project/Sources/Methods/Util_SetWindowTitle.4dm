//%attributes = {}
  //This method sets the Window Title according to the content of the screen

C_OBJECT:C1216($selected;$selection;$dataClass;$currentEntity)
C_LONGINT:C283($entitySelected;$entityInTable)
$selection:=$1
$selected:=$2
$dataClassName:=$3
$currentEntity:=$4
$currentPage:=$5
$currentWindowRef:=$6

$display:=""

Case of 
	: ($currentPage=1)  //We display a List
		
		$display:=Util_Get_LocalizedMessage ("No_Record";$dataClassName)
		$entityInSelection:=$selection.length  //We get the number of Records (Entities) in the Selection
		If ($entityInSelection>0)  //We have at least one entity
			$entitySelected:=$selected.length
			  //When getDataClass will be available, we will use nex line...
			  //$dataClass:=$selection.first().getDataClass()  //So we get the DataClass...
			  //...Meanwhile we use this :
			$dataClass:=Form:C1466.dataClass  //So we get the DataClass...
			
			$entityInTable:=$dataClass.all().length  //...and the total number of Records
			$display:=String:C10($entityInSelection;"|Long")+" "+$dataClassName+" / "+String:C10($entityInTable;"|Long")
			$display:=$display+" ("+String:C10($entitySelected;"|Long")+" "+Get localized string:C991("Selected")+")"
		End if 
		
	: ($currentPage=2)  //We display an Entity
		$display:=Choose:C955(Num:C11($currentEntity.isNew());"ID "+$currentEntity.getKey(dk key as string:K85:16);Get localized string:C991("New_Record"))
		$display:=$dataClassName+" ("+$display+")"
		
End case 

SET WINDOW TITLE:C213($display;$currentWindowRef)

