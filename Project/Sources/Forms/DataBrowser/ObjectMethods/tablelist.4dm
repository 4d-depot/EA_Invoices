If (FORM Event:C1606.code=On Data Change:K2:15)
	$ptr:=OBJECT Get pointer:C1124(Object current:K67:2)
	If ($ptr->#0)
		$table:=Form:C1466.listbox.getDataClass()
		$ds:=$table.getDataStore()
		$tablename:=$ptr->{$ptr->}
		Form:C1466.listbox:=$ds[$tablename].all()
		$table:=$ds[$tablename]
		Databrowser_SetListbox 
		
		Databrowser_SetFieldPopup ($table)
	End if 
End if 