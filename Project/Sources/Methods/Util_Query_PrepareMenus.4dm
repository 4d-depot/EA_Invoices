//%attributes = {}
$col_menusItems:=New collection:C1472

$col_MenuText:=New collection:C1472  //  index 0
$col_MenuText.push(New object:C1471("menu";Get localized string:C991("criteria_TextIsEqual");"condition";"T="))
$col_MenuText.push(New object:C1471("menu";Get localized string:C991("criteria_TextIsNotEqual");"condition";"T#"))
$col_MenuText.push(New object:C1471("menu";Get localized string:C991("criteria_TextContains");"condition";"T[=]"))
$col_MenuText.push(New object:C1471("menu";Get localized string:C991("criteria_TextDoesNotContain");"condition";"T[#]"))
$col_MenuText.push(New object:C1471("menu";Get localized string:C991("criteria_TextStartsWith");"condition";"T=]"))
$col_MenuText.push(New object:C1471("menu";Get localized string:C991("criteria_TextEndsWith");"condition";"T[="))
$col_MenuText.push(New object:C1471("menu";Get localized string:C991("criteria_TextIsBigger");"condition";"T>"))
$col_MenuText.push(New object:C1471("menu";Get localized string:C991("criteria_TextIsBiggerOrEqual");"condition";"T>="))
$col_MenuText.push(New object:C1471("menu";Get localized string:C991("criteria_TextIsLower");"condition";"T<"))
$col_MenuText.push(New object:C1471("menu";Get localized string:C991("criteria_TextIsLowerOrEqual");"condition";"T<="))
$col_MenuText.push(New object:C1471("menu";Get localized string:C991("criteria_TextIsEmpty");"condition";"T=0"))
$col_MenuText.push(New object:C1471("menu";Get localized string:C991("criteria_TextIsNotEmpty");"condition";"T#0"))

$col_MenuNum:=New collection:C1472  //  index 1
$col_MenuNum.push(New object:C1471("menu";Get localized string:C991("criteria_NumIsEqual");"condition";"N="))
$col_MenuNum.push(New object:C1471("menu";Get localized string:C991("criteria_NumIsNotEqual");"condition";"N#"))
$col_MenuNum.push(New object:C1471("menu";Get localized string:C991("criteria_NumIsBigger");"condition";"N>"))
$col_MenuNum.push(New object:C1471("menu";Get localized string:C991("criteria_NumIsBiggerOrEqual");"condition";"N>="))
$col_MenuNum.push(New object:C1471("menu";Get localized string:C991("criteria_NumIsLower");"condition";"N<"))
$col_MenuNum.push(New object:C1471("menu";Get localized string:C991("criteria_NumIsLowerOrEqual");"condition";"N<="))

$col_MenuBool:=New collection:C1472  //  index 2
$col_MenuBool.push(New object:C1471("menu";Get localized string:C991("criteria_BoolIsTrue");"condition";"B=";"value";"none"))
$col_MenuBool.push(New object:C1471("menu";Get localized string:C991("criteria_BoolIsFalse");"condition";"B#";"value";"none"))
$col_MenuBool.push(New object:C1471("menu";Get localized string:C991("criteria_BoolIsUndefined");"condition";"B=?";"value";"none"))
$col_MenuBool.push(New object:C1471("menu";Get localized string:C991("criteria_BoolIsNotUndefined");"condition";"B#?";"value";"none"))

$col_MenuDate:=New collection:C1472  //  index 3
$col_MenuDate.push(New object:C1471("menu";Get localized string:C991("criteria_DateIsEqual");"condition";"D="))
$col_MenuDate.push(New object:C1471("menu";Get localized string:C991("criteria_DateIsNotEqual");"condition";"D#"))
$col_MenuDate.push(New object:C1471("menu";Get localized string:C991("criteria_DateIsBigger");"condition";"D>"))
$col_MenuDate.push(New object:C1471("menu";Get localized string:C991("criteria_DateIsBiggerOrEqual");"condition";"D>="))
$col_MenuDate.push(New object:C1471("menu";Get localized string:C991("criteria_DateIsLower");"condition";"D<"))
$col_MenuDate.push(New object:C1471("menu";Get localized string:C991("criteria_DateIsLowerOrEqual");"condition";"D<="))
$col_MenuDate.push(New object:C1471("menu";Get localized string:C991("criteria_DateIsToday");"condition";"D=D";"value";"none"))
$col_MenuDate.push(New object:C1471("menu";Get localized string:C991("criteria_DateIsTomorrow");"condition";"D=D+";"value";"none"))
$col_MenuDate.push(New object:C1471("menu";Get localized string:C991("criteria_DateIsYesterday");"condition";"D=D-";"value";"none"))

$col_MenuPict:=New collection:C1472  //  index 4
$col_MenuPict.push(New object:C1471("menu";Get localized string:C991("criteria_PictIsEmpty");"condition";"I=";"value";"none"))
$col_MenuPict.push(New object:C1471("menu";Get localized string:C991("criteria_PictIsNotEmpty");"condition";"I#";"value";"none"))
$col_MenuPict.push(New object:C1471("menu";Get localized string:C991("criteria_PictIsBigger");"condition";"I>";"value";"long"))
$col_MenuPict.push(New object:C1471("menu";Get localized string:C991("criteria_PictIsLower");"condition";"I<";"value";"long"))
$col_MenuPict.push(New object:C1471("menu";Get localized string:C991("criteria_PictContainsWords");"condition";"I=W";"value";"text"))
$col_MenuPict.push(New object:C1471("menu";Get localized string:C991("criteria_PictDoesNotContainWords");"condition";"I#W";"value";"text"))
$col_MenuPict.push(New object:C1471("menu";Get localized string:C991("criteria_PictIsUndefined");"condition";"I=?";"value";"none"))
$col_MenuPict.push(New object:C1471("menu";Get localized string:C991("criteria_PictIsNotUndefined");"condition";"I#?";"value";"none"))

$col_MenuBlob:=New collection:C1472  //  index 5
$col_MenuBlob.push(New object:C1471("menu";Get localized string:C991("criteria_BlobIsNotEmpty");"condition";"O=";"value";"none"))
$col_MenuBlob.push(New object:C1471("menu";Get localized string:C991("criteria_BlobIsEmpty");"condition";"O#";"value";"none"))
$col_MenuBlob.push(New object:C1471("menu";Get localized string:C991("criteria_BlobIsBigger");"condition";"O>";"value";"long"))
$col_MenuBlob.push(New object:C1471("menu";Get localized string:C991("criteria_BlobIsBiggerOrEqual");"condition";"O>=";"value";"long"))
$col_MenuBlob.push(New object:C1471("menu";Get localized string:C991("criteria_BlobIsLower");"condition";"O<";"value";"long"))
$col_MenuBlob.push(New object:C1471("menu";Get localized string:C991("criteria_BlobIsLowerOrEqual");"condition";"O<=";"value";"long"))
$col_MenuBlob.push(New object:C1471("menu";Get localized string:C991("criteria_NumIsUndefined");"condition";"O=?";"value";"none"))
$col_MenuBlob.push(New object:C1471("menu";Get localized string:C991("criteria_BlobIsNotUndefined");"condition";"O#?";"value";"none"))

$col_MenuProp:=New collection:C1472  //  index 6
$col_MenuProp.push(New object:C1471("menu";Get localized string:C991("PropertyExists");"condition";"P=";"value";"none"))
$col_MenuProp.push(New object:C1471("menu";Get localized string:C991("PropertyNotExist");"condition";"P#";"value";"none"))

$col_MenuArray:=New collection:C1472  //  index 7
$col_MenuArray.push(New object:C1471("menu";Get localized string:C991("criteria_TextContains");"condition";"T="))
$col_MenuArray.push(New object:C1471("menu";Get localized string:C991("criteria_TextDoesNotContain");"condition";"T#"))
$col_MenuArray.push(New object:C1471("menu";Get localized string:C991("PropertyExists");"condition";"P=";"value";"none"))
$col_MenuArray.push(New object:C1471("menu";Get localized string:C991("PropertyNotExist");"condition";"P#";"value";"none"))

$obj_MenuObj:=New object:C1471  //Not used rignt now
$obj_MenuObj.text:=Get localized string:C991("KindText")
$obj_MenuObj.num:=Get localized string:C991("KindNum")
$obj_MenuObj.Boolean:=Get localized string:C991("KindBoolean")
$obj_MenuObj.date:=Get localized string:C991("KindDate")
$obj_MenuObj.property:=Get localized string:C991("KindProperty")

$col_menusItems.push($col_MenuText).push($col_MenuNum).push($col_MenuBool).push($col_MenuDate).push($col_MenuPict).push($col_MenuBlob)
$col_menusItems.push($col_MenuProp).push($col_MenuArray).push($obj_MenuObj)

$0:=$col_menusItems

