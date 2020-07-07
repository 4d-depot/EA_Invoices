//%attributes = {}
C_TEXT:C284($propertyName)
C_OBJECT:C1216($selection;$property)

If (Form event code:C388=On After Keystroke:K2:26)
	$text:=Get edited text:C655
Else 
	$text:=Form:C1466.queryString
End if 
$isNumeric:=($text=String:C10(Num:C11($text)))
$choice:=(Form:C1466.popupPtr)->
If (Form:C1466.inSelection)
	$selection:=Form:C1466.displayedSelection
Else 
	$selection:=Form:C1466.dataClass.all()
End if 
If ($choice<4)  //Search everywhere
	$qryString:=""
	For each ($property;Form:C1466.qryPropertyList)
		$type:=$property.type
		$isTypeNumeric:=($type="long") | ($type="number") | ($type="long64") | ($type="float")
		$toAdd:=""
		If ($qryString#"")
			$toAdd:=" OR "
		End if 
		If ($isTypeNumeric)
			If ($isNumeric)
				$qryString:=$qryString+$toAdd+$property.name+" = :1"
			End if 
		Else 
			$qryString:=$qryString+$toAdd+$property.name+" = :2"
		End if 
	End for each 
	Form:C1466.displayedSelection:=$selection.query($qryString;$text;"@"+$text+"@")
Else 
	$propertyName:=Form:C1466.qryPropertyList[$choice-3].name
	$type:=Form:C1466.qryPropertyList[$choice-3].type
	$isTypeNumeric:=($type="long") | ($type="number") | ($type="long64") | ($type="float")
	If ($isNumeric & $isTypeNumeric)
		Form:C1466.displayedSelection:=$selection.query($propertyName+" = :1";$text)
	Else 
		Form:C1466.displayedSelection:=$selection.query($propertyName+" = :1";"@"+$text+"@")
	End if 
End if 

