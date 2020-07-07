//%attributes = {}
$what2do:=$1

If (Form event code:C388#On Load:K2:1)
	  //Products_InputCommonTasks($evt;"SAVE")
End if 

$OK:=True:C214

Case of 
	: ($what2do="FIRST")
		Form:C1466.clickedEntity:=Form:C1466.clickedEntity.first()
	: ($what2do="PREVIOUS")
		If (Not:C34(Form:C1466.clickedEntity.previous()=Null:C1517))
			Form:C1466.clickedEntity:=Form:C1466.clickedEntity.previous()
		End if 
	: ($what2do="NEXT")
		If (Not:C34(Form:C1466.clickedEntity.next()=Null:C1517))  //isLast())
			Form:C1466.clickedEntity:=Form:C1466.clickedEntity.next()
		End if 
	: ($what2do="LAST")
		Form:C1466.clickedEntity:=Form:C1466.clickedEntity.last()
	Else 
		$OK:=False:C215
End case 

If ($OK)
	Form:C1466.editEntity:=Form:C1466.clickedEntity
	Util_EntityLoad (Form:C1466.editEntity;Form:C1466.objectsNames)
End if 


