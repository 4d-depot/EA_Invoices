//%attributes = {}
C_OBJECT:C1216($object)
C_COLLECTION:C1488($col_Operator;$col_Condition;$col_ValueType)


$index:=$1
$item:=$2
$type:=$3

$col_Operator:=Form:C1466.queryMenus[$index].extract("menu")  //  Just for testing
$col_Condition:=Form:C1466.queryMenus[$index].extract("condition")  //  Just for testing
$col_ValueType:=Form:C1466.queryMenus[$index].extract("value";ck keep null:K85:1)  //can be none long text 

Case of 
	: ($col_ValueType[$item]="none")
		$object:=Form:C1466.blankCell
		$object.condition:=$col_Condition[$item]
		
	: ($col_ValueType[$item]="long")
		$object:=New object:C1471("valueType";"integer";"value";0;"condition";$col_Condition[$item])
		
	: ($col_ValueType[$item]="text")
		$object:=New object:C1471("valueType";"text";"value";"";"condition";$col_Condition[$item])
		
	Else   //  Null
		Case of 
			: ($type="integer")
				$object:=New object:C1471("valueType";"integer";"value";0;"condition";$col_Condition[$item])
				
			: ($type="real")
				$object:=New object:C1471("valueType";"real";"value";0;"condition";$col_Condition[$item])
				
			: ($type="text")
				$object:=New object:C1471("valueType";"text";"value";"";"condition";$col_Condition[$item])
				
			: ($type="boolean")
				$object:=New object:C1471("valueType";"boolean";"value";False:C215;"condition";$col_Condition[$item])
				
			Else 
				$object:=New object:C1471("valueType";"text";"value";"";"condition";$col_Condition[$item])
		End case 
End case 

$0:=$object