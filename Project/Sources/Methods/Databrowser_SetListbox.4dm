//%attributes = {}
  // set Listbox, define values
  // Form.listbox entity selection
  // "list box" is listbox to fill

$table:=Form:C1466.listbox.getDataClass()
$ds:=$table.getDataStore()
$tablename:=$table.getInfo().name
LISTBOX DELETE COLUMN:C830(*;"list box";1;100)

C_POINTER:C301($nullpointer)

$file:=File:C1566("/PACKAGE/Databrowser/"+$tablename+".myPrefs")
If ($file.exists)
	$object:=JSON Parse:C1218($file.getText())
	$counter:=0
	For each ($column;$object.columns)
		$counter:=$counter+1
		LISTBOX INSERT COLUMN FORMULA:C970(*;"List Box";$counter;$column.title;$column.formula;Is text:K8:3;$column.title;$nullpointer->)
		OBJECT SET TITLE:C194(*;$column.title;$column.title)
		LISTBOX SET COLUMN WIDTH:C833(*;$column.title;$column.width)
	End for each 
	
	
Else 
	
	  // without defined content we use the first 10 attributes to display
	$counter:=0
	For each ($field;$table) While ($counter<10)
		$fieldobject:=$table[$field]
		If ($fieldobject.kind="storage")
			If (($fieldobject.fieldType#Is BLOB:K8:12) & ($fieldobject.fieldType#Is object:K8:27))
				$counter:=$counter+1
				LISTBOX INSERT COLUMN FORMULA:C970(*;"List Box";$counter;$field;"This."+$field;$fieldobject.fieldType;$field;$nullpointer->)
				OBJECT SET TITLE:C194(*;$field;$field)
			End if 
		End if 
	End for each 
End if 

  // build subform
$page:=New object:C1471

$top:=10
For each ($field;$table)
	$fieldobject:=$table[$field]
	If ($fieldobject.kind="storage")
		If ($fieldobject.fieldType#Is BLOB:K8:12)
			$formobject:=New object:C1471
			$formobject.text:=$field
			$formobject.type:="text"
			$formobject.left:=10
			$formobject.top:=$top
			$formobject.width:=120
			$formobject.height:=16
			$page[$field]:=$formobject
			
			$formobject:=New object:C1471
			$formobject.type:="input"
			$formobject.dataSource:="Form."+$field
			$formobject.left:=130
			$formobject.top:=$top
			$formobject.width:=250
			$formobject.sizingX:="grow"
			If (($fieldobject.fieldType#Is text:K8:3) & ($fieldobject.fieldType#Is picture:K8:10) & ($fieldobject.fieldType#Is object:K8:27))
				$formobject.height:=16
				$top:=$top+25
			Else 
				If ($fieldobject.fieldType=Is picture:K8:10)
					$formobject.dataSourceTypeHint:="picture"
				End if 
				$formobject.height:=95
				$formobject.sizingY:="grow"
				$top:=$top+100
				
				  // add splitter
				$page[$field+"_"]:=$formobject
				
				$formobject:=New object:C1471
				$formobject.type:="splitter"
				  //$formobject.dataSource:="Form."+$field
				$formobject.left:=1
				$formobject.top:=$top
				$formobject.width:=390
				$formobject.sizingX:="grow"
				$formobject.height:=5
				$top:=$top+10
			End if 
			$page[$field+"_splitter"]:=$formobject
			
			
		End if 
	End if 
	
End for each 
$subform:=New object:C1471("pages";New collection:C1472(Null:C1517;New object:C1471("objects";$page)))

OBJECT SET SUBFORM:C1138(*;"subform";$subform)

