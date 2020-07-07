//%attributes = {}
C_OBJECT:C1216($entity;$selection;$subselection;$status;$line)

$selection:=ds:C1482.PRODUCTS.all()
ARRAY OBJECT:C1221($arObjects;0)

If (False:C215)
	For each ($entity;$selection)
		OB GET ARRAY:C1229($entity.Optional_Data;"Options";$arObjects)
		If (Size of array:C274($arObjects)>0)
			$colCase:=New collection:C1472
			$colDeco:=New collection:C1472
			$colExt:=New collection:C1472
			For ($i;1;Size of array:C274($arObjects))
				$colCase.push($arObjects{$i}.Case)
				$colDeco.push($arObjects{$i}.Deco)
				$colExt.push($arObjects{$i}.External_Deco)
			End for 
			OB REMOVE:C1226($entity.Optional_Data;"Options")
			$entity.Optional_Data.Deco:=$colDeco
			$entity.Optional_Data.Case:=$colCase
			$entity.Optional_Data.External_Deco:=$colExt
		End if 
		$status:=$entity.save()
	End for each 
	
End if 

If (False:C215)
	$selection:=ds:C1482.CLIENTS.all()
	ARRAY OBJECT:C1221($arObjects;0)
	
	For each ($entity;$selection)
		$entity.Numbers:=New object:C1471
		$entity.Numbers.Phone:=$entity.Phone
		$entity.Numbers.Mobile:=$entity.Mobile
		$entity.Numbers.Fax:=$entity.Fax
		
		$entity.eAddress:=New object:C1471
		$entity.eAddress.eMail:=$entity.Email
		$entity.eAddress.WebSite:=$entity.Web_Site
		
		$entity.Phone:=""
		$entity.Mobile:=""
		$entity.Fax:=""
		$entity.Email:=""
		$entity.Web_Site:=""
		
		$status:=$entity.save()
	End for each 
	
End if 

If (True:C214)
	$selection:=ds:C1482.INVOICES.all()
	ARRAY OBJECT:C1221($arObjects;0)
	
	For each ($entity;$selection)
		$subselection:=$entity.Lines_Fm_Invoices
		$index:=0
		For each ($line;$subselection)
			$index:=$index+1
			$line.Line_Number:=$index
			$status:=$line.save()
		End for each 
	End for each 
End if 




