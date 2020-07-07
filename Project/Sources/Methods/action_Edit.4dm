//%attributes = {}
C_OBJECT:C1216($status)

Form:C1466.editEntity:=Form:C1466.clickedEntity
Form:C1466.recordCanBeSaved:=False:C215
$status:=Form:C1466.editEntity.lock()

Case of 
	: ($status.success)
		Form:C1466.recordCanBeSaved:=True:C214
		
	: ($status.status=dk status locked:K85:21)
		ALERT:C41(Util_Get_LocalizedMessage ("Record in use by";$status.lockInfo.user_name))
		
		
		  //All the following cases are here for information only, for it will happen only if you save an entity
	: ($status.status=dk status entity does not exist anymore:K85:23)  //This case cannot happen with a new entity
	: ($status.status=dk status stamp has changed:K85:20)  //Means that the record has been modified
	: ($status.success & $status.autoMerged)  //Saved & automerged
	: ($status.status=dk status automerge failed:K85:25)  //Automerge failed,
	: ($status.status=dk status wrong permission:K85:19)  //Nothing to do :-( You don't have the right to save it, period!
	: ($status.status=dk status serious error:K85:22)
		
End case 
OBJECT SET ENTERABLE:C238(*;"@_FIELD_@";Form:C1466.recordCanBeSaved)
FORM GOTO PAGE:C247(2)

