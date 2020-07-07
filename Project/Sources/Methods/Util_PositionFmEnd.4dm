//%attributes = {}
  //Find the position of $char starting from end of $text

$char:=$1
$text:=$2

$result:=0

$len:=Length:C16($text)
If (Position:C15($char;$text)<1)
	
Else 
	For ($i;$len;1;-1)
		If ($text[[$i]]=$char)
			$result:=$i
			$i:=0
		End if 
	End for 
End if 

$0:=$result