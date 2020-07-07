$evt:=Form event code:C388
Case of 
	: ($evt=On Clicked:K2:4)
		$n:=Size of array:C274(qry_ar_Properties)
		Form:C1466.criteriaList.clear()
		If ($n>0)
			For ($i;1;$n)
				$criteria:=New object:C1471
				If (qry_ar_Logicals{$i}.valueType="text")
					$criteria.logicalOperator:=qry_ar_Logicals{$i}.value
				End if 
				$criteria.propertyName:=qry_ar_Properties{$i}
				$criteria.propertyLocalName:=qry_ar_PropertyName{$i}
				$criteria.comparison:=qry_ar_Operators{$i}
				$criteria.value:=qry_ar_Values{$i}.value
				$criteria.valueType:=qry_ar_Values{$i}.valueType
				$criteria.condition:=qry_ar_Values{$i}.condition
				Form:C1466.criteriaList.push($criteria)
			End for 
		End if 
End case 