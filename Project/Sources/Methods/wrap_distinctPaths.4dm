//%attributes = {}
C_COLLECTION:C1488($zePaths)
C_OBJECT:C1216($currentSelection)
C_TEXT:C284($zeProperty_name)
C_POINTER:C301($fldPtr)
C_LONGINT:C283($tableNb)

$currentSelection:=$1
$zeProperty_name:=$2

$zePaths:=New collection:C1472
ARRAY TEXT:C222($ar_FieldNames;0)
ARRAY LONGINT:C221($ar_FieldNumbers;0)
GET FIELD TITLES:C804(Form:C1466.dataClassPtr->;$ar_FieldNames;$ar_FieldNumbers)  //Pointer on the table

$found:=Find in array:C230($ar_FieldNames;$zeProperty_name)

If ($found>0)
	$tableNb:=Table:C252(Form:C1466.dataClassPtr)
	$fldPtr:=Field:C253($tableNb;$ar_FieldNumbers{$found})
	ARRAY TEXT:C222($ar_Paths;0)
	USE ENTITY SELECTION:C1513($currentSelection)
	DISTINCT ATTRIBUTE PATHS:C1395($fldPtr->;$ar_Paths)
	If (Size of array:C274($ar_Paths)>0)
		ARRAY TO COLLECTION:C1563($zePaths;$ar_Paths)
		
	End if 
End if 
$0:=$zePaths