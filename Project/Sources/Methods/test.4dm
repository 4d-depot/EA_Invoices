//%attributes = {}
$sel:=ds:C1482.CLIENTS.all()
For each ($editEntity;$sel)
	$editEntity.Total_Sales:=$editEntity.Invoice_List.sum("Total")
	$editEntity.save()
End for each 