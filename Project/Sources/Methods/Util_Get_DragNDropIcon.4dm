//%attributes = {}

  //Thanks to Keisuke Miyako for this clever piece of code!

C_LONGINT:C283($badge;$1)
C_PICTURE:C286($icon;$0)

If (Count parameters:C259>0)
	$badge:=$1
Else 
	$badge:=0
End if 

If ($badge<1)
	$badge:=1
End if 

$path:=Get 4D folder:C485(Current resources folder:K5:16)\
+"Images"+Folder separator:K24:12\
+"DnD"+Folder separator:K24:12\
+"drag.svg"

$dom:=DOM Parse XML source:C719($path)

Case of 
	: ($badge>1)
		DOM SET XML ATTRIBUTE:C866(DOM Find XML element by ID:C1010($dom;"icon");"xlink:href";"drag-multiple.png")
		DOM SET XML ELEMENT VALUE:C868(DOM Find XML element by ID:C1010($dom;"badge-title");String:C10($badge;"&xml"))
		DOM SET XML ATTRIBUTE:C866(DOM Find XML element by ID:C1010($dom;"badge");"fill-opacity";1;"stroke-opacity";1)
End case 
SVG EXPORT TO PICTURE:C1017($dom;$icon;Own XML data source:K45:18)

$0:=$icon