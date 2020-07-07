//%attributes = {}
C_PICTURE:C286($pict)
C_OBJECT:C1216($currentSelection;$zeProperty;$dataClass;$zeRelatedDataclass;$zeRelatedProperty;$object;$criteria)
C_TEXT:C284($property;$relatedProperty)
C_COLLECTION:C1488($zePaths;$typeList;$propertyCol)

$what2do:=$1
$formData:=$2
$currentSelection:=$3

  //We make the list of the Entity Types accepted by Query or Order by, in a Collection (much simpler than an array)
$colOK2Use:=New collection:C1472("long";"string";"number";"date";"duration";"bool";"long64";"float";"variant")
  // Other types, like image, blob, or objects, cannot be use directly for sorting

  //We get the things that we will need (here the pictures of up and down arrows) but it can be Strings or any other data
$formData.pictures:=New object:C1471
Case of 
	: ($what2do="SORT")
		$path:=Get 4D folder:C485(Current resources folder:K5:16)+"Images"+Folder separator:K24:12+"4DIcons"+Folder separator:K24:12
		READ PICTURE FILE:C678($path+"ArrowUp.png";$pict)
		$formData.pictAsc:=$pict
		READ PICTURE FILE:C678($path+"ArrowDown.png";$pict)
		$formData.pictDesc:=$pict
		
	: ($what2do="QRY")
		$colOK2Use.push("image").push("blob").push("object").push("array").push("1toN").push("Nto1")  //  To add properties which can be used for searching...
		
End case 

Util_GetPropertyTypePictures ($formData;$colOK2Use;$what2do)

$propertyCol:=$formData.propertyList

For each ($property;$formData.zeDataClass)  //For each property in the DataClass ($property is the property name)
	$zeProperty:=$formData.zeDataClass[$property]  //Access the property from it's name
	If ($property#"_@")  //Fields beginning by "_" are supposed to be invisible
		Case of 
			: ($zeProperty.kind="storage")
				Case of 
					: ($zeProperty.type="object")  //If it's an object field, we will get the different contents
						  //Until the member function .distinctPaths will be available, please use:
						$zePaths:=wrap_distinctPaths ($currentSelection;$zeProperty.name)  //Equivalent to DISTINCT ATTRIBUTE PATHS
						  //As soon as available, replace the line above by the following one:
						  //$zePaths:=$currentSelection.distinctPaths($zeProperty.name)
						
						For each ($path;$zePaths)
							Case of 
								: (($path="@[]") & ($what2do="SORT"))  //This is an array, and can't be used for sorting
									If (False:C215)
										$object:=$propertyCol.pop()  //In case of Sorting, only length is relevant
										If ($path="@.length")  //This the number of elements of an array
											$propertyCol.push(New object:C1471("name";$zeProperty.name+"."+$path;"type";"long";"localName";Util_Get_LocalizedMessage ($zeProperty.name)+"."+$path))
										End if 
									End if 
									
								: ($path="@[]")
									$object:=$propertyCol.pop()  //Returns the last object while removing it
									$object.type:="object"
									$propertyCol.push($object)  //Can also be written : $propertyCol[$propertyCol.length-1].type:="object"
									$propertyCol.push(New object:C1471("name";$zeProperty.name+"."+$path;"type";"array";"localName";Util_Get_LocalizedMessage ($zeProperty.name)+"."+$path))
									
								: ($path="@.length")  //This the number of elements of an array
									$propertyCol.push(New object:C1471("name";$zeProperty.name+"."+$path;"type";"long";"localName";Util_Get_LocalizedMessage ($zeProperty.name)+"."+$path))
									  //Here you can define other exclusions if needed
									
								Else 
									$propertyCol.push(New object:C1471("name";$zeProperty.name+"."+$path;"type";"variant";"localName";Util_Get_LocalizedMessage ($zeProperty.name)+"."+$path))
									  //We use Variant for the type, for we can't know the type of an object's property
							End case 
						End for each 
						
					: ($colOK2Use.indexOf($zeProperty.type)>-1)  //We can use it for sorting or searching
						$propertyCol.push(New object:C1471("name";$zeProperty.name;"type";$zeProperty.type;"localName";Util_Get_LocalizedMessage ($zeProperty.name)))
						
					Else 
						
				End case 
				
			: (($zeProperty.kind="relatedEntities") & ($what2do="SORT"))  //This is 1->N relation, it can't be used for sorting
				
				
			: ($zeProperty.kind="relatedEntities")  //We are going to get the related Many table's fields
				$zeRelatedDataclass:=$formData.zeDataStore[$zeProperty.relatedDataClass]
				If ($zeProperty.name="NU_@")
					  // NU for Not Used. This is my own convention, please feel free to use your own if you want...
				Else 
					$propertyCol.push(New object:C1471("name";$zeProperty.name;"type";"1toN";"localName";Util_Get_LocalizedMessage ($zeProperty.name)))  //$zeRelatedDataclass.getInfo().name gives the name of the dataclass
					For each ($relatedProperty;$zeRelatedDataclass)
						$zeRelatedProperty:=$zeRelatedDataclass[$relatedProperty]
						If ($zeRelatedProperty.kind="storage")
							$propertyCol.push(New object:C1471("name";$zeProperty.name+"."+$zeRelatedProperty.name;"type";$zeRelatedProperty.type;"localName";Util_Get_LocalizedMessage ($zeProperty.name)+"."+Util_Get_LocalizedMessage ($zeRelatedProperty.name)))
						End if 
					End for each 
				End if 
				
			: ($zeProperty.kind="relatedEntity")  //We are going to get the related One table's fields
				$zeRelatedDataclass:=$formData.zeDataStore[$zeProperty.relatedDataClass]
				For each ($relatedProperty;$zeRelatedDataclass)
					$zeRelatedProperty:=$zeRelatedDataclass[$relatedProperty]
					If ($zeRelatedProperty.kind="storage")
						$propertyCol.push(New object:C1471("name";$zeProperty.name+"."+$zeRelatedProperty.name;"type";$zeRelatedProperty.type;"localName";Util_Get_LocalizedMessage ($zeProperty.name)+"."+Util_Get_LocalizedMessage ($zeRelatedProperty.name)))
					End if 
				End for each 
				
			Else 
				
		End case 
	End if 
End for each 
