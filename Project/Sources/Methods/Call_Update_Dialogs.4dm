//%attributes = {}
  //Call_Update_Dialogs (Self;Form.dataClass;Form.dataClassName;Form.displayedSelection;Form.selectedSubset;Form.editEntity;Current form name;FORM Get current page;"Products")
C_OBJECT:C1216($selection2Use;$targetSelection;$dataClass;$displayedSelection;$selectedSubset;$editEntity)
C_POINTER:C301($self)
C_TEXT:C284($dataClassName;$target;$currentFormName)
C_LONGINT:C283($currentPage)

$self:=$1
$dataClass:=$2
$dataClassName:=$3
$displayedSelection:=$4
$selectedSubset:=$5
$editEntity:=$6
$currentFormName:=$7
$currentPage:=$8
$target:=$9

  //OBJECT Get name(

If ($currentPage=1)  //It's a List
	If ($selectedSubset.length=0)
		$selection2Use:=$displayedSelection
	Else 
		$selection2Use:=$selectedSubset
	End if 
	
Else   //It's an Entity (therefore a Record)
	$selection2Use:=$dataClass.newSelection().add($editEntity)
End if 

Case of 
	: ($dataClassName="PRODUCTS")
		Case of 
			: ($target="INVOICES")
				$targetSelection:=$selection2Use.Lines_Fm_Product.Invoice
				
			: ($target="CLIENTS")
				$targetSelection:=$selection2Use.Lines_Fm_Product.Invoice.Client
				
		End case 
		
	: ($dataClassName="INVOICES")
		Case of 
			: ($target="PRODUCTS")
				$targetSelection:=$selection2Use.Lines_Fm_Invoices.Product
				
			: ($target="CLIENTS")
				$targetSelection:=$selection2Use.Client
				
		End case 
		
	: ($dataClassName="CLIENTS")
		Case of 
			: ($target="INVOICES")
				$targetSelection:=$selection2Use.Invoice_List
				
			: ($target="PRODUCTS")
				$targetSelection:=$selection2Use.Invoice_List.Lines_Fm_Invoices.Product
				
		End case 
		
End case 

$fl_Select:=True:C214
CALL WORKER:C1389("Generic";"W_Generic";$target;$fl_Select;$targetSelection)


