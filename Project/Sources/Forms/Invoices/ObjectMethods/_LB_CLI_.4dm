$event:=Form event code:C388
Case of 
	: ($event=On Clicked:K2:4)
		If (Form:C1466.cur_clientSelection#Null:C1517)
			Form:C1466.editEntity.Client_ID:=Form:C1466.cur_clientSelection.ID
			
			OBJECT SET VISIBLE:C603(*;"@DNE_@";True:C214)
			OBJECT SET VISIBLE:C603(*;"@_CLI_@";False:C215)
			Form:C1466.queryClient:=""
			GOTO OBJECT:C206(*;"_FIELD_Invoice_Number_")
		End if 
		
End case 