//%attributes = {}
  // handles listbox creation/filling for current table


$usertable:=ds:C1482.Listbox_Setting.query("TableName=:1 and UserName=:2";Form:C1466.dataClassName;Current user:C182).first()
If ($usertable=Null:C1517)
	$usertable:=ds:C1482.Listbox_Setting.query("TableName=:1 and UserName=:2";Form:C1466.dataClassName;"default").first()
End if 
  //If ($usertable=Null)