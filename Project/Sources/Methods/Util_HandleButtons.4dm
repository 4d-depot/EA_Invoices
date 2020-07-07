//%attributes = {}
C_OBJECT:C1216($entity)

$entity:=$1

OBJECT SET ENTERABLE:C238(*;"@_FIELD_@";Form:C1466.recordCanBeSaved)
OBJECT SET ENABLED:C1123(*;"@_FIELD_@";Form:C1466.recordCanBeSaved)
OBJECT SET ENTERABLE:C238(*;"_FIELD_Value_";Form:C1466.settings.Display.enterInList & Form:C1466.recordCanBeSaved)
OBJECT SET VISIBLE:C603(*;"@_ADDPIC_@";Form:C1466.recordCanBeSaved)
OBJECT SET ENABLED:C1123(*;"@_SAVE_@";Form:C1466.recordCanBeSaved)
OBJECT SET ENABLED:C1123(*;"@_RW_DELETE_@";(Form:C1466.recordCanBeSaved & Not:C34($entity.isNew())))
OBJECT SET ENABLED:C1123(*;"@_RW_CALL_@";(Form:C1466.recordCanBeSaved | $entity.isNew()))

OBJECT SET ENABLED:C1123(*;"@_UNLOCK_@";Not:C34($entity.isNew()))
If (Form:C1466.recordCanBeSaved)
	If ($entity.isNew())
		OBJECT SET TITLE:C194(*;"@_UNLOCK_@";":xliff:New")
	Else 
		OBJECT SET TITLE:C194(*;"@_UNLOCK_@";":xliff:Lock")
	End if 
Else 
	OBJECT SET TITLE:C194(*;"@_UNLOCK_@";":xliff:Unlock")
End if 
OBJECT SET DRAG AND DROP OPTIONS:C1183(*;"@_Picture_@";True:C214;True:C214;Form:C1466.recordCanBeSaved;Form:C1466.recordCanBeSaved)  //draggable ; automaticDrag ; droppable ; automaticDrop )
For each ($object;Form:C1466.objectsNames)
	OBJECT SET VISIBLE:C603(*;"@_LIST_DEL_"+$object;(Form:C1466["data_"+$object].length>0) & (Form:C1466["sel_"+$object].length>0))  //If at least a Property has been selected
End for each 
Case of   //For Forms displaying related entities
	: (Form:C1466.dataClassName="INVOICES")
		OBJECT SET VISIBLE:C603(*;"@_LIST_DEL_INVOICE_LINES";Form:C1466.recordCanBeSaved & (Form:C1466.sel_Lines_Fm_Invoices.length>0))  //If at least an Entity has been selected
End case 
OBJECT SET ENABLED:C1123(*;"@_LIST_@";Form:C1466.recordCanBeSaved)  //
OBJECT SET ENABLED:C1123(*;"@_FRST_@";($entity.indexOf(Form:C1466.displayedSelection)>0) & Not:C34($entity.isNew()))  //...if the Entity is the first one
OBJECT SET ENABLED:C1123(*;"@_LAST_@";($entity.indexOf(Form:C1466.displayedSelection)<(Form:C1466.displayedSelection.length-1)) & Not:C34($entity.isNew()))  //...or the last one
If (Form:C1466.pictureName#"")
	OBJECT SET VISIBLE:C603(*;"@_NOPIC_@";(Picture size:C356($entity[Form:C1466.pictureName])=0))
End if 
OBJECT SET VISIBLE:C603(*;"@_NEWINV_@";Form:C1466.editEntity.isNew())