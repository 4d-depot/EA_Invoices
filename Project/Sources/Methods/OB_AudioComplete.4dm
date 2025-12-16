//%attributes = {"invisible":false,"shared":false,"preemptive":"capable"}
// OB_AudioComplete
// Helper method for TTS streaming - handles stream completion callback
// $1: success - Boolean indicating if streaming was successful
// $2: error - error message if any
// $3: formWindow - the form window ID for CALL FORM

#DECLARE($success : Boolean; $error : Text; $formWindow : Integer)

// Delegate to VoiceServices
cs:C1710.VoiceServices.new().handleAudioStreamComplete($success; $error; $formWindow)
