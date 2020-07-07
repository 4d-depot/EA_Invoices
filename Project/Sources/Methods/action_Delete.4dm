//%attributes = {}
C_OBJECT:C1216($toDelete;$lockedSelection;$status;$subsel2Kill)
C_LONGINT:C283($n)

$toDelete:=$1
$what:=$2

If ($toDelete=Null:C1517)
	BEEP:C151
	ALERT:C41(Get localized string:C991("There is nothing to delete!"))
	
Else 
	  //The second parameter should not be necessary, for it is possible to get the type of object from the object itself:
	  //  1st solution : wait for the 'Get Class Name' command which will return 'PRODUCTS' for an Entity, and 'PRODUCTS Selection' for a Selection
	  //  2nd solution : Test If (Value type($toDelete.length)=Is undefined), because the read only '.length' property if defined for a Selection, and undifined for an Entity
	
	Case of 
		: ($what="Entity")
			If (Form:C1466.recordCanBeSaved)
				$text:=Util_Get_LocalizedMessage ("delete this Entity")
				CONFIRM:C162($text;Get localized string:C991("Delete it");Get localized string:C991("Cancel"))
				If (OK=1)
					START TRANSACTION:C239
					Case of   //Handling of special cases
						: (Form:C1466.dataClassName="INVOICES")  //To delete an invoice, it's necessary to delete invoice lines first
							$subsel2Kill:=Form:C1466.editEntity.Lines_Fm_Invoices
							$lockedSelection:=$subsel2Kill.drop(dk stop dropping on first error:K85:26)
							$fl_Stop:=($lockedSelection.length>0)
						Else 
							$fl_Stop:=True:C214
					End case 
					
					If ($fl_Stop)
						CANCEL TRANSACTION:C241
						ALERT:C41(Get localized string:C991("unexpected problem"))
					Else 
						$status:=Form:C1466.editEntity.drop()
						
						If ($status.success)
							Form:C1466.recordCanBeSaved:=False:C215
							Form:C1466.displayedSelection:=Form:C1466.displayedSelection.minus(Form:C1466.editEntity)
							VALIDATE TRANSACTION:C240
							If (Form:C1466.settings.Modes.multiRecords)
								Util_RecordInNewWindow ("CLOSE")
							Else 
								FORM GOTO PAGE:C247(1)
								Util_UpdateSelection ("_LB_1")
							End if 
							
						Else 
							Case of 
								: ($status.status=dk status locked:K85:21)  //This case should never happen in case of Pessimistic Locking!
									ALERT:C41(Util_Get_LocalizedMessage ("Recordinuse";$status.lockInfo.user_name))
									
								: ($status.status=dk status entity does not exist anymore:K85:23)  //This case also should never happen in case of  Pessimistic Locking!
									ALERT:C41(Get localized string:C991("Recorddeleted"))
									
								: ($status.status=dk status stamp has changed:K85:20)  //...neither this one...
								: ($status.status=dk status wrong permission:K85:19)  //Nothing to do :-( You don't have the right to delete it, period!
								: ($status.status=dk status serious error:K85:22)
									ALERT:C41(Util_Get_LocalizedMessage ("Something strange";$status.lockInfo.errors.text.join(Char:C90(Carriage return:K15:38))))
									
							End case 
							CANCEL TRANSACTION:C241
						End if 
					End if 
				End if 
				
			Else 
				BEEP:C151
				ALERT:C41(Get localized string:C991("Read-Only mode"))
				
			End if 
			
		: ($what="Selection")
			$n:=Form:C1466.selectedSubset.length
			$text:=Util_Get_LocalizedMessage ("deleteSelection";String:C10($n))
			CONFIRM:C162($text;Get localized string:C991("Delete it");Get localized string:C991("Cancel"))
			If (OK=1)
				START TRANSACTION:C239  //This is only necessary when deletion of Records imply deletion of records from another Table (i.e. [INVOICES] and [INVOICES_LINES] for instance)
				
				Case of   //Handling of special cases
					: (Form:C1466.dataClassName="INVOICES")  //To delete an invoice, it's necessary to delete invoice lines first
						$subsel2Kill:=Form:C1466.selectedSubset.Lines_Fm_Invoices
						$lockedSelection:=$subsel2Kill.drop(dk stop dropping on first error:K85:26)
						$fl_Stop:=($lockedSelection.length>0)
					Else 
						$fl_Stop:=True:C214
				End case 
				
				If ($fl_Stop)
					CANCEL TRANSACTION:C241
					ALERT:C41(Get localized string:C991("unexpected problem"))
				Else 
					$lockedSelection:=Form:C1466.selectedSubset.drop(dk stop dropping on first error:K85:26)  //$lockedSelection is an entity selection containing the first not dropped entity
					If ($lockedSelection.length=0)  //The delete action is successful, all the entities have been deleted
						VALIDATE TRANSACTION:C240
						ALERT:C41(Util_Get_LocalizedMessage ("You have dropped";String:C10($n);Form:C1466.dataClassName))  //The dropped entity selection remains in memory
						Form:C1466.displayedSelection:=Form:C1466.displayedSelection.minus($toDelete)
						Util_UpdateSelection ("_LB_1")
						
					Else 
						CANCEL TRANSACTION:C241
						ALERT:C41(Get localized string:C991("At least one"))
						
					End if 
				End if 
				
			End if 
	End case 
End if 