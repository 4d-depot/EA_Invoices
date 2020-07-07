$event:=Form event code:C388

Case of 
	: ($event=On Double Clicked:K2:5)
		action_Open 
		
	: (($event=On Begin Drag Over:K2:44) | ($event=On Drag Over:K2:13) | ($event=On Drop:K2:12))
		Action_DragNDrop ($event;Form:C1466.selectedSubset)
		
		
End case 