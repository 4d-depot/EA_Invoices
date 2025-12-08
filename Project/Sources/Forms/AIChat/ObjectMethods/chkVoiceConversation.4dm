// Button for continuous voice conversation mode
// Toggles between enabled (🗣️) and disabled (💬) states

Case of 
	: (Form event code:C388=On Clicked:K2:4)
		// Toggle the voice conversation mode
		Form:C1466.voiceConversationMode:=Not:C34(Form:C1466.voiceConversationMode)
		
		// Update button icon to reflect state
		If (Form:C1466.voiceConversationMode)
			OBJECT SET TITLE:C194(*; "chkVoiceConversation"; "🗣️")  // Active: speaking head
			// Start recording immediately when enabling
			Form:C1466.startVoiceRecording()
		Else 
			OBJECT SET TITLE:C194(*; "chkVoiceConversation"; "💬")  // Inactive: speech bubble
		End if 
End case 
