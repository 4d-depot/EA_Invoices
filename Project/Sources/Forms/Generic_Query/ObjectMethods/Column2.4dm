C_LONGINT:C283($index;$item)
C_TEXT:C284($type)
$evt:=Form event code:C388

Case of 
	: ($evt=On Data Change:K2:15)
		$line:=OBJECT Get pointer:C1124(Object current:K67:2)->
		$index:=qry_ar_Operators{$line}.qryIndex
		$type:=qry_ar_Operators{$line}.qryType
		$item:=qry_ar_Operators{$line}.requiredList.indexOf(qry_ar_Operators{$line}.value)
		qry_ar_Values{$line}:=Util_Query_SetCriteriaValueCell ($index;$item;$type)
		
		  //unitReference
		
End case 