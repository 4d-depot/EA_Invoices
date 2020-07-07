$event:=Form event code:C388

Case of 
	: ($event=On Load:K2:1)
		ARRAY TEXT:C222(ar_TablesList;0)
		Form:C1466.title:=Get localized string:C991("SETTINGS")
		
		Form:C1466.settings:=Settings_GetCurrent 
		
		Form:C1466.popupPtr:=OBJECT Get pointer:C1124(Object named:K67:5;"_TABLES_LIST_")
		APPEND TO ARRAY:C911(Form:C1466.popupPtr->;Get localized string:C991("PRODUCTS"))
		APPEND TO ARRAY:C911(Form:C1466.popupPtr->;Get localized string:C991("CLIENTS"))
		APPEND TO ARRAY:C911(Form:C1466.popupPtr->;Get localized string:C991("INVOICES"))
		Form:C1466.popupPtr->:=1
		
		OBJECT SET RGB COLORS:C628(*;"_COLOR_VIEW_";0x00DDDDDD;Form:C1466.settings.Display.AlternateColorRGB)
		OBJECT SET ENABLED:C1123(*;"_VALUE_BOOL_4";False:C215)
		
	Else 
		
		
End case 
OBJECT SET VISIBLE:C603(*;"@_NOPIC_@";Picture size:C356(Form:C1466.settings.Company.Logo)<1)
OBJECT SET VISIBLE:C603(*;"@_TABLE_@";False:C215)
$choice:=(Form:C1466.popupPtr)->
$selectedDataClass:=(Form:C1466.popupPtr)->{$choice}
OBJECT SET VISIBLE:C603(*;"@_"+$selectedDataClass+"_@";True:C214)
