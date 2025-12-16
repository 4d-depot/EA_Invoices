//%attributes = {"invisible":false,"shared":false,"preemptive":"capable"}
// OB_StreamData
// Helper method for HTTPRequest streaming - handles onData callback
// $1: context object with chunkIndex, onChunk callback, formWindow
// $2: HTTPRequest object
// $3: Event object - $3.data contains the NEW chunk data (not cumulative)

#DECLARE($ctx : Object; $request : Object; $event : Object)

var $newChunk : Blob
var $newSize : Integer

// $event.data contains the NEW chunk data (not cumulative)
If ($event.data#Null:C1517)
	$newChunk:=$event.data
	$newSize:=BLOB size:C605($newChunk)
	
	If ($newSize>0)
		$ctx.chunkIndex:=$ctx.chunkIndex+1
		// Call the callback with (blob, index, formWindow)
		$ctx.onChunk.call(Null:C1517; $newChunk; $ctx.chunkIndex; $ctx.formWindow)
	End if 
Else 
	// Fallback: try cumulative approach with response.body
	var $data : Blob
	var $totalSize : Integer
	var $offset : Integer
	
	$data:=$request.response.body
	$totalSize:=BLOB size:C605($data)
	$newSize:=$totalSize-$ctx.lastSize
	
	If ($newSize>0)
		$offset:=$ctx.lastSize
		COPY BLOB:C558($data; $newChunk; $offset; 0; $newSize)
		
		$ctx.lastSize:=$totalSize
		$ctx.chunkIndex:=$ctx.chunkIndex+1
		
		$ctx.onChunk.call(Null:C1517; $newChunk; $ctx.chunkIndex; $ctx.formWindow)
	End if 
End if 
