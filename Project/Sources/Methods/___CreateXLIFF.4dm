//%attributes = {}
$text:=""
$cr:=Char:C90(Carriage return:K15:38)

For each ($dataClass;ds:C1482)
	$text:=$text+"<group resname=\"CLASS-"+$dataClass+"\">"+$cr
	
	
	For each ($property;ds:C1482[$dataClass])  //For each property in the DataClass ($property is the property name)
		$text:=$text+"<trans-unit resname=\""+$property+"\">"+$cr
		$text:=$text+"<source>"+$property+"</source>"+$cr
		$text:=$text+"<target>"+$property+"</target>"+$cr
		$text:=$text+"</trans-unit>"+$cr
		
	End for each 
	$text:=$text+"</group>"+$cr
	
End for each 
$docref:=Create document:C266("";".txt")
CLOSE DOCUMENT:C267($docref)
TEXT TO DOCUMENT:C1237(Document;$text;"UTF-8")
