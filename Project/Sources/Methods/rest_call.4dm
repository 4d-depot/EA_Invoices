//%attributes = {"publishedWeb":true}
ARRAY TEXT:C222($namearray;0)
ARRAY TEXT:C222($valuearray;0)
WEB GET VARIABLES:C683($namearray;$valuearray)
If (Size of array:C274($namearray)>0)
	Case of 
		: ($namearray{1}="name")
			$sel:=ds:C1482.CLIENTS.query("Name=:1";$valuearray{1})
		: ($namearray{1}="city")
			$sel:=ds:C1482.CLIENTS.query("City=:1";$valuearray{1})
		Else 
			$sel:=ds:C1482.CLIENTS.newSelection()
	End case 
	$result:=$sel.toCollection("";dk with primary key:K85:6+dk with stamp:K85:28)
End if 

$answer:=JSON Stringify:C1217($result)
WEB SEND TEXT:C677($answer;"application/json")