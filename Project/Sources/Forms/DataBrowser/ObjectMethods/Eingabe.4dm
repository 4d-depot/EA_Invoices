If (FORM Event:C1606.code=On Data Change:K2:15)
	  // find indexed fields
	$table:=Form:C1466.listbox.getDataClass()
	$ds:=$table.getDataStore()
	$tablename:=$table.getInfo().name
	
	$ptr:=OBJECT Get pointer:C1124(Object named:K67:5;"fieldlist")
	$selectedfield:=$ptr->
	If ($selectedfield=1)
		$querystring:=""
		$fieldcol:=New collection:C1472
		
		For each ($field;$table)
			$fieldobject:=$table[$field]
			If ($fieldobject.kind="storage")
				If ($fieldobject.indexed)
					$string:="("+$field+" = :1)"
					$fieldcol.push($string)
				End if 
			End if 
		End for each 
		
		
		$querystring:=$fieldcol.join(" or ")
		Form:C1466.listbox:=$table.query($querystring;Form:C1466.query+"@")
	Else 
		$fieldname:=$ptr->{$ptr->}
		If ($fieldname#"-")
			$querystring:=$fieldname+" = :1"
			Form:C1466.listbox:=$table.query($querystring;Form:C1466.query+"@")
		End if 
	End if 
	
End if 