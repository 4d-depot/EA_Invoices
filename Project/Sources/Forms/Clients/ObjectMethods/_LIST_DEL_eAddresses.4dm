
If (False:C215)
	  //This is the basic way of programming, by passing parameters
	action_Property_Delete_Tradit ("_LB_eAddresses";Form:C1466.data_eAddresses;Form:C1466.cur_eAddresses;Form:C1466.sel_eAddresses;Form:C1466.pos_eAddresses)
Else 
	  //...and this is a more flexible way, by passing as few parameters as possible, requiring only a good naming of variables and form objects:
	action_Property_Delete ("_LB_eAddresses")
End if 

