//%attributes = {}
C_OBJECT:C1216($settings;$sel)
C_PICTURE:C286($pict)

$settings:=$1

$settings.Modes:=New object:C1471
$settings.Modes.multiProcess:=False:C215
$settings.Modes.multiRecords:=False:C215
$settings.Display:=New object:C1471
$settings.Display.enterInList:=True:C214
$settings.Display.HLinesVisible:=False:C215
$settings.Display.VLinesVisible:=False:C215
$settings.Display.AlternateColor:=True:C214
$settings.Display.AlternateColorRGB:=0x00F3F5FA
$settings.Company:=New object:C1471
$settings.Company.Name:="My Company"
$settings.Company.Logo:=$pict
$settings.Products:=New object:C1471
$settings.Products.defaultTaxRate:=0.2
$settings.Clients:=New object:C1471
$settings.Clients.defaultCountry:="USA"
$settings.Clients.defaultDiscount:=0
$settings.Invoices:=New object:C1471
$sel:=ds:C1482.INVOICES.query("ProForma = :1 & Credit_Note = :2";False:C215;False:C215)
If ($sel.length<1)
	$n:="INV00000"
Else 
	$n:=String:C10($sel.max("Invoice_Number");"00000")
End if 
$settings.Invoices.lastInvoiceNumber:=$n
$sel:=ds:C1482.INVOICES.query("ProForma = :1 & Credit_Note = :2";True:C214;False:C215)
If ($sel.length<1)
	$n:="PRF00000"
Else 
	$n:=String:C10($sel.max("Invoice_Number");"00000")
End if 
$settings.Invoices.lastProFormaNumber:=$n
$sel:=ds:C1482.INVOICES.query("ProForma = :1 & Credit_Note = :2";False:C215;True:C214)
If ($sel.length<1)
	$n:="QOT00000"
Else 
	$n:=String:C10($sel.max("Invoice_Number");"00000")
End if 
$settings.Invoices.lastQuoteNumber:=$n