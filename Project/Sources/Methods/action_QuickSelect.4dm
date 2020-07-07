//%attributes = {}
C_TEXT:C284($propertyName;$queryString)
C_OBJECT:C1216($dataClass;$selection;$property;$0)

$queryString:=$1
$dataClass:=$2

If (Form event code:C388=On After Keystroke:K2:26)
	$text:=Get edited text:C655
Else 
	$text:=$queryString
End if 
$isNumeric:=($text=String:C10(Num:C11($text)))
$selection:=$dataClass.all()
$qryString:=""
$qryPropertyList:=New collection:C1472
ARRAY TEXT:C222($ar_Properties;0)
Util_GetSimplePropertyList (->$ar_Properties;$dataClass;$qryPropertyList;"SIMPLE")  //Creates the list of properties for the QuickSelect
For each ($property;$qryPropertyList)
	$type:=$property.type
	$isTypeNumeric:=($type="long") | ($type="number") | ($type="long64") | ($type="float")
	$toAdd:=""
	If ($qryString#"")
		$toAdd:=" OR "
	End if 
	Case of 
		: ($type="variant")
			  //We don't use it here
			
		: ($isTypeNumeric)
			If ($isNumeric)
				$qryString:=$qryString+$toAdd+$property.name+" = :1"
			End if 
		Else 
			$qryString:=$qryString+$toAdd+$property.name+" = :2"
	End case 
End for each 

$selection:=$dataClass.query($qryString;$text;"@"+$text+"@")

$0:=$selection

