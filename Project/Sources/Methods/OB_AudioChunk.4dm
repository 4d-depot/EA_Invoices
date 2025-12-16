//%attributes = {"invisible":false,"shared":false,"preemptive":"capable"}
// OB_AudioChunk
// Helper method for TTS streaming - handles audio chunk callback
// $1: chunkBlob - the audio data blob
// $2: chunkIndex - the chunk number
// $3: formWindow - the form window ID for CALL FORM

#DECLARE($chunkBlob : Blob; $chunkIndex : Integer; $formWindow : Integer)

// Delegate to VoiceServices
cs:C1710.VoiceServices.new().sendAudioChunkToWebArea($chunkBlob; $chunkIndex; $formWindow)
