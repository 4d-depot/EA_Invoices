//%attributes = {}
  //This method returns the number of found records to display in lists

C_OBJECT:C1216($selected;$selection;$dataClass)
C_LONGINT:C283($entitySelected;$entityInTable)

$selection:=$1
$selected:=$2

$display:="No Records"

$entityInSelection:=$selection.length  //We get the number of Records (Entities) in the Selection

If ($entityInSelection>0)  //We have at least one entity
	  //When getDataClass will be available, we will use nex line...
	  //$dataClass:=$selection.first().getDataClass()  //So we get the DataClass...
	  //...Meanwhile we use this :
	$dataClass:=Form:C1466.dataClass  //So we get the DataClass...
	
	$entityInTable:=$dataClass.all().length  //...and the total number of Records
	$name:=Form:C1466.dataClassName  //Form.dataClassName to be replaced by $name:=$dataClass.getInfo().name  //And also the Table (DataClass) name
	
	$display:=String:C10($entityInSelection;"|Long")+" "+$name+" / "+String:C10($entityInTable;"|Long")
	
	$entitySelected:=$selected.length
	If ($entitySelected>0)
		$display:=$display+"<span style=\"color:#4C5CC5\">"+" ("+String:C10($entitySelected;"|Long")+" selected)"+"</span>"
	End if 
End if 

$0:=$display