//%attributes = {}
C_LONGINT:C283($1)
C_OBJECT:C1216($2;$DnDsource)
C_TEXT:C284($PrimaryKey)
C_COLLECTION:C1488($dragCollection)

$event:=$1
$selection:=$2

Case of 
	: ($event=On Begin Drag Over:K2:44)
		$nbOfLines:=$selection.length
		Case of 
			: ($nbOfLines<1)
				  //Nothing to do
			Else 
				$icon:=Util_Get_DragNDropIcon ($nbOfLines)
				SET DRAG ICON:C1272($icon)
				
				ARRAY REAL:C219($array;0)
				$collection:=$selection.toCollection("ID")
				COLLECTION TO ARRAY:C1562($collection;$array;"ID")
				$dragCollection:=New shared collection:C1527
				Use ($dragCollection)
					ARRAY TO COLLECTION:C1563($dragCollection;$array)
				End use 
				$dragThings:=New shared object:C1526
				Use ($dragThings)
					$dragThings.sourceDataClass:=Form:C1466.dataClassName
					$dragThings.sourceSelField:="ID"
				End use 
				Use (Storage:C1525)
					Storage:C1525.DnDdataClassInfo:=$dragThings
					Storage:C1525.DnDcollection:=$dragCollection
					  //storage.DnDproperty:="ID"
				End use 
				
		End case 
		
	: ($event=On Drag Over:K2:13)
		
		
	: ($event=On Drop:K2:12)
		$DnDsource:=Storage:C1525.DnDdataClassInfo
		If ($DnDsource#Null:C1517)
			$source:=Storage:C1525.DnDdataClassInfo.sourceDataClass
			If ($source=Form:C1466.dataClassName)
				  //Drop inside the same class, we do nothing
			Else 
				$PrimaryKey:=Storage:C1525.DnDdataClassInfo.sourceSelField
				$collection:=Storage:C1525.DnDcollection
				If (($source#"") & ($collection.length>0))
					$dataSource:=ds:C1482[$source]
					$selection2use:=$dataSource.query($PrimaryKey+" in :1";$collection)
					C_POINTER:C301($nilPtr)
					Call_Update_Dialogs ($nilPtr;$dataSource;$source;$selection2use;$selection2use;$selection2use.first();"DragDrop";1;Form:C1466.dataClassName)
				End if 
				Use (Storage:C1525)
					Storage:C1525.DnDdataClassInfo:=New shared object:C1526
					Storage:C1525.DnDcollection:=New shared collection:C1527
					  //storage.DnDproperty:="ID"
				End use 
			End if 
		End if 
End case 