//%attributes = {"invisible":false,"shared":false,"preemptive":"capable"}
// OB_AudioChunkQueued
// Helper method for queued TTS streaming - handles audio chunk callback
// Sends chunks to the TTS queue with request ID for ordering
// $1: chunkBlob - the audio data blob
// $2: chunkIndex - the chunk number
// $3: formWindow - the form window ID for CALL FORM
// $4: requestId - the TTS request ID for ordering

#DECLARE($chunkBlob : Blob; $chunkIndex : Integer; $formWindow : Integer; $requestId : Integer)

var $base64Chunk : Text
var $result : Text

// Convert chunk to base64
BASE64 ENCODE:C895($chunkBlob; $base64Chunk)
// Remove line breaks
$base64Chunk:=Replace string:C233(Replace string:C233($base64Chunk; "\r"; ""); "\n"; "")

// Send chunk to JavaScript TTS queue with request ID
CALL FORM:C1391($formWindow; Formula:C1597(WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; "Web Area"; "addQueuedAudioChunk"; $1; $2; $3)); ->$result; $base64Chunk; $requestId)
