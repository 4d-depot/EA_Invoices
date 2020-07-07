$event:=FORM Event:C1606
If ($event.code=On Header Click:K2:40)
	If (Right click:C712)
		$popup:="Delete Column;Add Formula;Save;Clear Saved;-;"
		$table:=Form:C1466.listbox.getDataClass()
		$ds:=$table.getDataStore()
		$tablename:=$table.getInfo().name
		
		  // build list of missing fields...
		  // first existing fields
		LISTBOX GET ARRAYS:C832(*;$event.objectName;$arrSpaNamen;$arrKopfNamen;$arrSpaVars;$arrKopfVars;$arrSpaSichtbar;$arrStile)
		For each ($field;$table)
			$pos:=Find in array:C230($arrSpaNamen;$field)
			If ($pos<0)
				$popup:=$popup+$field+";"
			End if 
		End for each 
		
		
		$select:=Pop up menu:C542($popup)
		
		Case of 
			: ($select=1)
				LISTBOX DELETE COLUMN:C830(*;$event.objectName;$event.column)
				
			: ($select=2)
				$formula:=Request:C163("Formula (this.field)")
				If (OK=1)
					C_POINTER:C301($nullpointer)
					If ($formula="this.@")
						$title:=Substring:C12($formula;6)
					Else 
						$title:=$formula
					End if 
					LISTBOX INSERT COLUMN FORMULA:C970(*;"List Box";$event.column+1;$title;$formula;Is text:K8:3;$title;$nullpointer->)
					OBJECT SET TITLE:C194(*;$title;$title)
				End if 
				
				
			: ($select=3)  // save
				$object:=New object:C1471("table";$tablename)
				$col:=New collection:C1472
				LISTBOX GET ARRAYS:C832(*;$event.objectName;$arrSpaNamen;$arrKopfNamen;$arrSpaVars;$arrKopfVars;$arrSpaSichtbar;$arrStile)
				For ($i;1;Size of array:C274($arrSpaNamen))
					$formula:=LISTBOX Get column formula:C1202(*;$arrSpaNamen{$i})
					$width:=LISTBOX Get column width:C834(*;$arrSpaNamen{$i})
					$col.push(New object:C1471("pos";$i;"formula";$formula;"width";$width;"title";$arrKopfNamen{$i}))
				End for 
				$object.columns:=$col
				$created:=File:C1566("/PACKAGE/Databrowser/"+$tablename+".myPrefs").setText(JSON Stringify:C1217($object))
				
			: ($select=4)  // clear
				File:C1566("/PACKAGE/Databrowser/"+$tablename+".myPrefs").delete()
				
			: ($select>5)
				$col:=Split string:C1554($popup;";")
				$title:=$col[$select-1]
				C_POINTER:C301($nullpointer)
				LISTBOX INSERT COLUMN FORMULA:C970(*;"List Box";$event.column+1;$title;"this."+$title;Is text:K8:3;$title;$nullpointer->)
				OBJECT SET TITLE:C194(*;$title;$title)
		End case 
	End if 
End if 