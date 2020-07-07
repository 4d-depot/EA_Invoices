//%attributes = {}
C_OBJECT:C1216($status)
C_BOOLEAN:C305($fl_IsNewRecord)
C_TEXT:C284($object)

$fl_IsNewRecord:=Form:C1466.editEntity.isNew()
If (Form:C1466.recordCanBeSaved)
	For each ($object;Form:C1466.objectsNames)
		If ($object#"")
			Form:C1466.editEntity[$object]:=Util_Collection2Object (Form:C1466["data_"+$object])  //To Update the Object Fields
		End if 
	End for each 
	$status:=Form:C1466.editEntity.save()  //Here we do not use the 'dk auto merge' parameter, for we use Pessimistic Locking
	
	$flOK2Validate:=False:C215
	Case of 
		: ($status.success)
			$status:=Form:C1466.editEntity.unlock()
			$flOK2Validate:=True:C214
			
		: ($status.status=dk status locked:K85:21)  //This case should never happen in case of  Pessimistic Locking!
			ALERT:C41(Util_Get_LocalizedMessage ("Recordinusesaved";$status.lockInfo.user_name))
			
		: ($status.status=dk status entity does not exist anymore:K85:23)  //This case also should never happen in case of  Pessimistic Locking!
		: ($status.status=dk status stamp has changed:K85:20)  //...neither this one...
		: ($status.success & $status.autoMerged)  //Saved & automerged
		: ($status.status=dk status automerge failed:K85:25)  //Automerge failed,
		: ($status.status=dk status wrong permission:K85:19)  //Nothing to do :-( You don't have the right to save it, period!
		: ($status.status=dk status serious error:K85:22)
			ALERT:C41(Util_Get_LocalizedMessage ("Something strangesave";$status.lockInfo.errors.text.join(Char:C90(Carriage return:K15:38))))
	End case 
	If (In transaction:C397)
		If ($flOK2Validate)
			VALIDATE TRANSACTION:C240
		Else 
			CANCEL TRANSACTION:C241
		End if 
	End if 
End if 

If (Form:C1466.settings.Modes.multiRecords)
	Util_RecordInNewWindow ("CLOSE")
Else 
	Form:C1466.recordCanBeSaved:=False:C215
	If ($fl_IsNewRecord)
		Form:C1466.displayedSelection.add(Form:C1466.editEntity)
	End if 
	Form:C1466.displayedSelection:=Form:C1466.displayedSelection
	FORM GOTO PAGE:C247(1)
	Util_UpdateSelection ("_LB_1")
End if 