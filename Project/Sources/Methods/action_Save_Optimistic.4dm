//%attributes = {}
  //This Method will save an Entity which has not been locked prior to modifications.
  //Therefore, it uses Optimistic Locking

C_OBJECT:C1216($status;$entity;$dataClass;$entity2Save;$1;$2)
C_TEXT:C284($attribute)
C_BOOLEAN:C305($fl_IsNewRecord;$0)

$entity:=$1
$dataClass:=$2

$saved_OK:=True:C214

$fl_IsNewRecord:=$entity.isNew()  //A New Record cannot be locked, but others errors may occur...

$status:=$entity.save(dk auto merge:K85:24)
Case of 
	: ($status.success)
		$status:=$entity.unlock()  //Just in case this method is called on a locked entity
		
	: ($status.success & $status.autoMerged)  //Saved & automerged : It means that the Entity has been modified, saved, then unlocked.
		$status:=$entity.unlock()  //Just in case this method is called on a locked entity
		BEEP:C151
		ALERT:C41(Util_Get_LocalizedMessage ("RecordMerged"))
		
	: (($status.status=dk status automerge failed:K85:25) | ($status.status=dk status stamp has changed:K85:20))  //Automerge failed, or Stamp has changed
		  //In both cases, you have to reload the Entity, and redo the modifications
		BEEP:C151
		ALERT:C41(Util_Get_LocalizedMessage ("RecordNotMerged"))
		
	: ($status.status=dk status locked:K85:21)  //This case should never happen in case of  Pessimistic Locking!
		ALERT:C41(Util_Get_LocalizedMessage ("Recordinusesaved";$status.lockInfo.user_name)+Char:C90(Carriage return:K15:38)+Get localized string:C991("RetryOrCancel"))
		$saved_OK:=False:C215
		
	: ($status.status=dk status entity does not exist anymore:K85:23)  //This case may happen in case of Optimistic Locking!
		$entity2Save:=$dataClass.new()  // We can always save a new Entity
		For each ($attribute;$entity)  //We cannot use .clone(), for the copy will be too perfect ;-)
			$entity2Save[$attribute]:=$entity[$attribute]  //...so we duplicate every attributes.
		End for each 
		$entity2Save.save()  //And then we save it
		
	: ($status.status=dk status wrong permission:K85:19)  //Nothing to do :-( You don't have the right to save it, period!
	: ($status.status=dk status serious error:K85:22)
		ALERT:C41(Util_Get_LocalizedMessage ("Something strangesave";$status.lockInfo.errors.text.join(Char:C90(Carriage return:K15:38))))
		
End case 

$0:=$saved_OK
