//%attributes = {}
C_OBJECT:C1216($dataStore;$dataClass;$criteria;$displayedSelection;$lineInfos)
C_BOOLEAN:C305($inSelection)

  //Util_Query_Extended

  //This method provides an example of what could be a generic Query Editor that you can modify and/or adapt to your own needs


C_PICTURE:C286($pict)
$indent:=Char:C90(NBSP ASCII CODE:K15:43)*2

$dataStore:=$1
$dataClass:=$2  //  The DataClass to Query
$displayedSelection:=$3  //  The Entity Selection of this DataClass to sort (In case of QUERY SELECTION)
$inSelection:=$4  //True if the query has to be done inside the current selection

$formData:=New object:C1471  //To prepare the data to use with the Generic_Query Form

$formData.zeDataStore:=$dataStore
$formData.zeDataClass:=$dataClass  //This is the  Table search on

$formData.propertyList:=New collection:C1472  //We can also use $dataClass.keys() if we just need the names
$formData.propertySelected:=New object:C1471  //will be the current selected element in the propertyList
$formData.propertyPosition:=0  //will be the current selected element position in the propertyList (starting from 0)
$formData.ck_CurrentSel:=$inSelection

Util_GetPropertyList ("QRY";$formData;$dataClass.all())

$formData.criteriaList:=New collection:C1472
$formData.criteriaSelected:=New object:C1471
$formData.criteriaPosition:=0
$formData.clipObject:=Null:C1517  //This object will be used by the Drag & Drop
$formData.ck_CurrentSel:=False:C215

$w:=Open form window:C675("Generic_Query";Movable form dialog box:K39:8;Horizontally centered:K39:1;Vertically centered:K39:4;*)
SET WINDOW TITLE:C213("Query "+Form:C1466.dataClassName+" with...";$w)  //To be replaced by $dataClass.getInfo().name

DIALOG:C40("Generic_Query";$formData)

If (OK=1)
	If ($formData.criteriaList.length>0)
		
		$inSelection:=$formData.ck_CurrentSel
		
		$queryString:=""
		
		$queryParams:=New object:C1471
		$queryParams.queryPlan:=False:C215
		$queryParams.queryPath:=False:C215
		$queryParams.parameters:=New collection:C1472
		
		$index:=0
		$parmIndex:=0
		For each ($criteria;$formData.criteriaList)
			$index:=$index+1
			If ($index=1)  //First line
				
			Else 
				$queryString:=$queryString+" "+$criteria.logicalOperator+" "
			End if 
			$lineInfos:=$criteria.comparison
			$condition:=$criteria.condition
			$fl_AtBefore:="@"*Num:C11(Position:C15("[";$condition)>0)
			$fl_AtAfter:="@"*Num:C11(Position:C15("]";$condition)>0)
			$linePrefix:=""
			$lineSuffix:=""
			$condition:=Replace string:C233($condition;"[";"")
			$condition:=Substring:C12(Replace string:C233($condition;"]";"");2)
			$fl_HasParm:=False:C215
			Case of   // Analyse of special cases (See Util_Query_PrepareMenus method)
				: (Position:C15("0";$condition)>0)  //Text is empty or not
					$condition:=Replace string:C233($condition;"0";" ''")
					
				: (Position:C15("?";$condition)>0)  // is defined or not
					$condition:=Replace string:C233($condition;"?";" null")
					
				: (Position:C15("W";$condition)>0)  // contains keywords
					$condition:=Replace string:C233($condition;"W";" % ")
					$fl_HasParm:=True:C214
					If ($condition="#W")  //  Doesn't contain KW -> Not(contains KW)
						$linePrefix:="not("
						$lineSuffix:=")"
					End if 
					
				: ($condition="=D@")  //Today
					$condition:="="
					$criteria.value:=Current date:C33
					$fl_HasParm:=True:C214
					Case of 
						: ($condition="=D+")  //Tomorrow
							$criteria.value:=Current date:C33+1
						: ($condition="=D-")  //Yesterday
							$criteria.value:=Current date:C33-1
					End case 
					
				: ($criteria.condition="B=")  //Booleans
					$condition:=" is true"
				: ($criteria.condition="B#")
					$condition:=" is false"
					
				: ($criteria.condition="P=")  //Properties
					If (($lineInfos.originalType="object") & ($criteria.propertyName#"@[]"))
						$criteria.propertyName:=$criteria.propertyName+"[]"
					End if 
					$condition:=" is not null"
				: ($criteria.condition="P#")
					If (($lineInfos.originalType="object") & ($criteria.propertyName#"@[]"))
						$criteria.propertyName:=$criteria.propertyName+"[]"
					End if 
					$condition:=" is null"
					
				: ($criteria.condition="T@")
					$criteria.value:=$fl_AtBefore+$criteria.value+$fl_AtAfter
					$fl_HasParm:=True:C214
					
				Else 
					$fl_HasParm:=True:C214
			End case 
			
			$queryString:=$queryString+$linePrefix+$criteria.propertyName+" "+$condition+" "
			If ($fl_HasParm)
				$parmIndex:=$parmIndex+1
				$queryString:=$queryString+":"+String:C10($parmIndex)
				$queryParams.parameters.push($criteria.value)
			End if 
			
			$queryString:=$queryString+$lineSuffix
			
		End for each 
		
		If ($queryParams.queryPlan)
			$qryPlan:=Get last query plan:C1046(Description in text format:K19:5)
		End if 
		If ($queryParams.queryPath)
			$qryPath:=Get last query path:C1045(Description in text format:K19:5)
		End if 
		
		If ($inSelection)
			$displayedSelection:=$displayedSelection.query($queryString;$queryParams)
		Else 
			$displayedSelection:=$dataClass.query($queryString;$queryParams)
		End if 
		
	End if 
End if 

$0:=$displayedSelection




