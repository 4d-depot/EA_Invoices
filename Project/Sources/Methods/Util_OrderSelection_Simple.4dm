//%attributes = {}
C_OBJECT:C1216($displayedSelection;$zeProperty;$dataClass;$displayedSelection;$criteria)
C_TEXT:C284($property)
  //Util_OrderSelection_ (Simple or Extended)

  //This method provides an example of what could be a generic Sort Editor that you can modify and/or adapt to your own needs

C_PICTURE:C286($pict)
$indent:=Char:C90(NBSP ASCII CODE:K15:43)*2

$dataClass:=$1  //  The DataClass to sort
$displayedSelection:=$2  //  The Entity Selection of this DataClass to sort

$formData:=New object:C1471  //To prepare the data to use with the Generic_OrderBy Form

  //We get the things that we will need (here the pictures of up and down arrows) but it can be Strings or any other data
$path:=Get 4D folder:C485(Current resources folder:K5:16)+"Images"+Folder separator:K24:12+"4DIcons"+Folder separator:K24:12
$formData.pictures:=New collection:C1472
READ PICTURE FILE:C678($path+"ArrowUp.png";$pict)
$formData.pictAsc:=$pict
READ PICTURE FILE:C678($path+"ArrowDown.png";$pict)
$formData.pictDesc:=$pict

$formData.zeDataClass:=$dataClass  //This is the  Table to sort

$formData.propertyList:=New collection:C1472  //We can also use $dataClass.keys() if we just need the names
$formData.propertySelected:=New object:C1471  //will be the current selected element in the propertyList
$formData.propertyPosition:=0  //will be the current selected element position in the propertyList (starting from 0)

  //We make the list of the Entity Types accepted by Order by, in a Collection (much simpler than an array)
$colOK4Sort:=New collection:C1472("long";"string";"number";"date";"duration";"bool";"long64";"float")
  // Other types, like image, blob, or objects, cannot be use directly for sorting

$formData.pictures:=New object:C1471
Util_GetPropertyTypePictures ($formData;$colOK4Sort;"SORT")

For each ($property;$formData.zeDataClass)  //For each property in the DataClass ($property is the property name)
	$zeProperty:=$formData.zeDataClass[$property]  //Access the property from it's name
	Case of 
		: ($zeProperty.kind="storage")
			If ($colOK4Sort.indexOf($zeProperty.type)>-1)  //We can use it for sorting
				$formData.propertyList.push(New object:C1471("name";$zeProperty.name;"type";$zeProperty.type;"localName";Util_Get_LocalizedMessage ($zeProperty.name)))
			End if 
			
		: ($zeProperty.kind="relatedEntities")
			
		: ($zeProperty.kind="relatedEntity")
			
		Else 
			
	End case 
End for each 

$formData.criteriaList:=New collection:C1472
$formData.criteriaSelected:=New object:C1471
$formData.criteriaSelection:=New collection:C1472
$formData.criteriaPosition:=0
$formData.clipObject:=Null:C1517  //This object will be used by the Drag & Drop

$w:=Open form window:C675("Generic_OrderBy";Movable form dialog box:K39:8;Horizontally centered:K39:1;Vertically centered:K39:4;*)
SET WINDOW TITLE:C213(Util_Get_LocalizedMessage ("Order_By";Form:C1466.dataClassName);$w)  //To be replaced by $dataClass.getInfo().name

DIALOG:C40("Generic_OrderBy";$formData)

If (OK=1)
	If ($formData.criteriaList.length>0)
		
		  //2 ways can be used to use the criteriaList and perform the Order by: 
		If (False:C215)  //  1st way : If you have to add complex calculations :
			$myOrderCol:=New collection:C1472
			For each ($criteria;$formData.criteriaList)
				  //Here you can do your complex calculations
				$myOrderCol.push(New object:C1471("propertyPath";$criteria.name;"descending";$criteria.criteriaDesc))
			End for each 
			
		Else   //  2nd way : much simpler, just .extract) the criteriaList into an usable collection
			$myOrderCol:=$formData.criteriaList.extract("name";"propertyPath";"criteriaDesc";"descending")
		End if 
		
		  //Then perform the Order by...
		$displayedSelection:=$displayedSelection.orderBy($myOrderCol)
		
	End if 
End if 

$0:=$displayedSelection

