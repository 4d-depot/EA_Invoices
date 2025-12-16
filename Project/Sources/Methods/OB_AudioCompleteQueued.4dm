//%attributes = {"invisible":false,"shared":false,"preemptive":"capable"}
// OB_AudioCompleteQueued
// Helper method for queued TTS streaming - handles stream completion callback
// Signals to JavaScript that one TTS request is complete
// $1: success - Boolean indicating if streaming was successful
// $2: error - error message if any
// $3: formWindow - the form window ID for CALL FORM
// $4: requestId - the TTS request ID for ordering

#DECLARE($success : Boolean; $error : Text; $formWindow : Integer; $requestId : Integer)

var $result : Text

If ($success)
	// Signal this TTS request is complete with its ID
	CALL FORM:C1391($formWindow; Formula:C1597(WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "Web Area"; "endQueuedAudioStream"; $1; $2)); ->$result; $requestId)
Else 
	// Error occurred
	CALL FORM:C1391($formWindow; Formula:C1597(WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "Web Area"; "errorQueuedAudioStream"; $1; $2; $3)); ->$result; $requestId; $error)
End if 
