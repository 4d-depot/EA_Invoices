If (Form:C1466.cur_Product#Null:C1517)
	Form:C1466.Product_ID:=Form:C1466.cur_Product.ID
	Form:C1466.Product_Reference:=Form:C1466.cur_Product.Reference
	Form:C1466.Product_Name:=Form:C1466.cur_Product.Name
	Form:C1466.Quantity:=0
	Form:C1466.Unit_Price:=Form:C1466.cur_Product.Sale_Price
	Form:C1466.Discount_Rate:=0
	Form:C1466.Tax_Rate:=Form:C1466.cur_Product.Tax_Rate
	Form:C1466.Total:=0
	Form:C1466.Total_Tax:=0
	
	OBJECT SET VISIBLE:C603(*;"_PRODUCTLIST_";False:C215)
	GOTO OBJECT:C206(*;"_PROP_Quantity_")
End if 
