//%attributes = {}
C_OBJECT:C1216($1;$0;$o;$variant;$3)
C_TEXT:C284($2;$property)
C_COLLECTION:C1488($properties)

$object:=$1
$path:=$2
$variant:=$3

$properties:=Split string:C1554($path;".")

If ($properties.length>0)
	$i:=0
	For each ($property;$properties)
		Case of 
			: ($i>=($properties.length-1))  //last property in the path, must take the value
				$o[$property]:=$variant.value
				
			: ($i=0)
				If ($object[$property]=Null:C1517)
					$object[$property]:=New object:C1471
				End if 
				$o:=$object[$property]
				
			Else 
				If ($o[$property]=Null:C1517)
					$o[$property]:=New object:C1471
				End if 
				$o:=$o[$property]
				
		End case 
		$i:=$i+1
	End for each 
End if 

$0:=$object
