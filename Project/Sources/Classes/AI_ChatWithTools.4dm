property AIClient : cs:C1710.AIKit.OpenAI
property AIBot : cs:C1710.AIKit.OpenAIChatHelper
property formObject : Object
property defaultTop : Integer

singleton Class constructor()
	This:C1470.AIBot:=Null:C1517
	This:C1470.formObject:=Null:C1517
	This:C1470.defaultTop:=100
	
	
	//MARK: -
	//MARK: Tools declaration & schema
	
Function _loadTools()
	var $toolsFilePath:="/RESOURCES/AITools.json"
	var $jsonText : Text
	var $jsonObject : Object
	var $tool : Object
	
	Try
		$jsonText:=File:C1566($toolsFilePath).getText()
		$jsonObject:=JSON Parse:C1218($jsonText; Is object:K8:27)
		For each ($tool; $jsonObject.tools)
			$tool.handler:=This:C1470
		End for each 
		This:C1470.AIBot.registerTools($jsonObject.tools)
	Catch
		return 
	End try
	
Function _getToolArgumentsSchema($name : Text) : Object
	var $toolDecl : Object
	
	$toolDecl:=This:C1470.AIBot.tools.query("name = :1"; $name).first()
	return ($toolDecl#Null:C1517) ? $toolDecl.parameters : Null:C1517
	
	//MARK: -
	//MARK: Tools implementation
	
Function _functionName($callChain : Collection) : Text
	var $name : Text:=$callChain[0].name
	
	Try
		return Split string:C1554($name; ".")[1]
	Catch
		return ""
	End try
	
Function tool_createInvoice($input : Object) : Object
	var $validation; $returnObject : Object
	var $client : cs:C1710.CLIENTSEntity
	var $invoice : cs:C1710.INVOICESEntity
	var $invoiceObject : Object
	var $invoiceLine : cs:C1710.INVOICE_LINESEntity
	var $invoiceLineObject : Object
	var $product : cs:C1710.PRODUCTSEntity
	var $lineNumber : Integer:=1
	var $nb0 : Integer
	
	//$input.Client_ID: Client_ID must exist in database
	$client:=ds:C1482.CLIENTS.get($input.Client_ID)
	
	Case of 
		: ($input.Lines_Fm_Invoices.length=0)
			return {error: "Invoice must have invoice lines"}
		: ($client=Null:C1517)
			return {error: "Client ID not found in database"}
	End case 
	
	ds:C1482.startTransaction()
	Try
		$invoice:=ds:C1482.INVOICES.new()
		$invoice.Client:=$client
		$invoice.Creation_Date:=Date:C102($input.Creation_Date)  // date YYYY-MM-DD
		$invoice.Paid:=$input.Paid  // Boolean. if true, Payment_Date, Payment_Method and Payment_Reference should be filled
		$invoice.Payment_Date:=Date:C102($input.Payment_Date)  // date YYYY-MM-DD
		$invoice.Payment_Method:=$input.Payment_Method  // String
		$invoice.Payment_Reference:=$input.Payment_Reference  // String
		$invoice.ProForma:=$input.ProForma  // Boolean
		$invoice.Payment_Delay:=$input.Payment_Delay  // Integer, number of days, should be 30, 60 or 90
		$invoice.Proforma_Number:=$input.Proforma_Number  // String
		$invoice.Credit_Note:=$input.Credit_Note  // Boolean
		
		$invoice.save()
		
		//$input.Lines_Fm_Invoices must be a collection of INVOICE_LINESEntity objects
		For each ($invoiceLineObject; $input.Lines_Fm_Invoices)
			//Product_ID must exist in database
			$product:=ds:C1482.PRODUCTS.get($invoiceLineObject.Product_ID)
			If ($product=Null:C1517)
				ds:C1482.cancelTransaction()
				return {error: "Product ID not found in database"}
			End if 
			$invoiceLine:=ds:C1482.INVOICE_LINES.new()
			$invoiceLine.Invoice:=$invoice
			$invoiceLine.Product:=$product
			$invoiceLine._ProductReference:=$product.Reference  // Obtained from product
			$invoiceLine._ProductName:=$product.Name  // Obtained from product
			$invoiceLine.Quantity:=$invoiceLineObject.Quantity  // Integer
			$invoiceLine.Unit_Price:=$product.Sale_Price  // Obtained from product
			$invoiceLine.Discount_Rate:=$invoiceLineObject.Discount_Rate  // Integer between 0 and 100, mostly under 10
			$invoiceLine.Tax_Rate:=$product.Tax_Rate  // Obtained from product
			$invoiceLine.Total:=Round:C94($invoiceLine.Quantity*$invoiceLine.Unit_Price*(1-($invoiceLine.Discount_Rate/100)); 2)  // Calculated
			$invoiceLine.Total_Tax:=Round:C94($invoiceLine.Total*($invoiceLine.Tax_Rate/100); 2)  // Calculated
			$invoiceLine.Line_Number:=$lineNumber  // Calculated
			$invoiceLine.save()
			$lineNumber+=1
		End for each 
		
		$nb0:=5-Length:C16(String:C10($invoice.ID))
		$invoice.Invoice_Number:="INV"+($nb0*"0")+String:C10($invoice.ID)
		$invoice.Subtotal_BT:=$invoice.Lines_Fm_Invoices.sum("Total")
		$invoice.Tax:=$invoice.Lines_Fm_Invoices.sum("Total_Tax")
		$invoice.Total:=$invoice.Subtotal_BT+$invoice.Tax
		$invoice.save()
	Catch
		ds:C1482.cancelTransaction()
		return {error: "An error occured while trying to create the invoice: "+JSON Stringify:C1217(Last errors:C1799; *)}
		
	End try
	ds:C1482.validateTransaction()
	
	$returnObject:={}
	$returnObject.form:="Invoices"
	$returnObject.dataClass:="INVOICES"
	$returnObject.entity:=JSON Stringify:C1217($invoice.toObject("*, Lines_Fm_Invoices.*"))
	return $returnObject
	
Function tool_getProducts($input : Object) : Object
	var $validation; $returnObject : Object
	var $entities : cs:C1710.PRODUCTSSelection:=ds:C1482.PRODUCTS.all()
	
	$validation:=JSON Validate:C1456($input; This:C1470._getToolArgumentsSchema(This:C1470._functionName(Call chain:C1662)))
	If (Not:C34($validation.success))
		return {error: "Could not validate input parameters against JSON Schema, call the tool again with proper input parameters"}
	End if 
	
	$input.ID:=($input.ID) || "any"
	$input.Reference:=($input.Reference) || "@"
	$input.Name:=($input.Name) || "@"
	$input.Sale_Price:=$input.Sale_Price || {}
	$input.Sale_Price.min:=$input.Sale_Price.min || 0
	$input.Sale_Price.max:=$input.Sale_Price.max || 999999
	$input.orderBy:=($input.orderBy) || {}
	$input.orderBy.field:=($input.orderBy.field) || "Name"
	$input.orderBy.order:=($input.orderBy.order) || "asc"
	$input.top:=($input.top) || This:C1470.defaultTop
	$input.countOnly:=($input.countOnly) || False:C215
	
	$returnObject:={}
	$returnObject.form:="Products"
	$returnObject.dataClass:="PRODUCTS"
	$returnObject.counts:={}
	$returnObject.counts.total:=$entities.length
	
	If ($input.ID#"any")
		$entities:=$entities.query("ID = :1"; $input.ID)
	End if 
	
	$entities:=$entities.query("Reference = :1 and Name = :2 and Sale_Price >= :3 and Sale_Price <= :4 order by "+$input.orderBy.field+" "+$input.orderBy.order; $input.Reference; $input.Name; $input.Sale_Price.min; $input.Sale_Price.max)
	$returnObject.counts.totalFiltered:=$entities.length
	If ($returnObject.totalEntities>$input.top)
		$entities:=$entities.slice(0; $input.top)
	End if 
	$returnObject.counts.totalSent:=$entities.length
	$returnObject.entities:=($input.countOnly) ? [] : $entities.toCollection("ID, Reference, Name, Sale_Price")
	
	return $returnObject
	
Function tool_getClients($input : Object) : Object
	var $validation; $returnObject : Object
	var $entities : cs:C1710.CLIENTSSelection:=ds:C1482.CLIENTS.all()
	
	$validation:=JSON Validate:C1456($input; This:C1470._getToolArgumentsSchema(This:C1470._functionName(Call chain:C1662)))
	If (Not:C34($validation.success))
		return {error: "Could not validate input parameters against JSON Schema, call the tool again with proper input parameters"}
	End if 
	
	$input.ID:=($input.ID) || "any"
	$input.Name:=($input.Name) || "@"
	$input.Contact:=($input.Contact) || "@"
	$input.Total_Sales:=$input.Total_Sales || {}
	$input.Total_Sales.min:=$input.Total_Sales.min || 0
	$input.Total_Sales.max:=$input.Total_Sales.max || 9999999
	$input.orderBy:=($input.orderBy) || {}
	$input.orderBy.field:=($input.orderBy.field) || "Name"
	$input.orderBy.order:=($input.orderBy.order) || "asc"
	$input.top:=($input.top) || This:C1470.defaultTop
	$input.countOnly:=($input.countOnly) || False:C215
	
	$returnObject:={}
	$returnObject.form:="Clients"
	$returnObject.dataClass:="CLIENTS"
	$returnObject.counts:={}
	$returnObject.counts.total:=$entities.length
	
	If ($input.ID#"any")
		$entities:=$entities.query("ID = :1"; $input.ID)
	End if 
	
	$entities:=$entities.query("Name = :1 and Contact = :2 and Total_Sales >= :3 and Total_Sales <= :4 order by "+$input.orderBy.field+" "+$input.orderBy.order; $input.Name; $input.Contact; $input.Total_Sales.min; $input.Total_Sales.max)
	$returnObject.counts.totalFiltered:=$entities.length
	If ($returnObject.totalEntities>$input.top)
		$entities:=$entities.slice(0; $input.top)
	End if 
	$returnObject.counts.totalSent:=$entities.length
	$returnObject.entities:=($input.countOnly) ? [] : $entities.toCollection("ID, Name, Contact, City, State, Country, Discount_Rate, Total_Sales, Comments")
	
	return $returnObject
	
Function tool_getInvoices($input : Object) : Object
	var $validation; $returnObject : Object
	var $entities : cs:C1710.INVOICESSelection:=ds:C1482.INVOICES.all()
	
	//Quick fix until JSON Validate properly handles dates in objects
	//Temporarily put string in date fields
	$input.Creation_Date:=$input.Creation_Date || {}
	$input.Creation_Date.min:=($input.Creation_Date.min) ? String:C10($input.Creation_Date.min; "yyyy-MM-dd")+"T00:00:00" : ""  // date YYYY-MM-DD
	$input.Creation_Date.max:=($input.Creation_Date.max) ? String:C10($input.Creation_Date.max; "yyyy-MM-dd")+"T00:00:00" : ""  // date YYYY-MM-DD
	// end of fix
	
	$validation:=JSON Validate:C1456($input; This:C1470._getToolArgumentsSchema(This:C1470._functionName(Call chain:C1662)))
	If (Not:C34($validation.success))
		return {error: "Could not validate input parameters against JSON Schema, call the tool again with proper input parameters"}
	End if 
	
	$input.Invoice_Number:=($input.Invoice_Number) || "@"
	$input.Client_ID:=($input.Client_ID) || "any"
	$input.Total:=$input.Total || {}
	$input.Total.min:=$input.Total.min || 0
	$input.Total.max:=$input.Total.max || 9999999
	$input.Creation_Date:=$input.Creation_Date || {}
	$input.Creation_Date.min:=($input.Creation_Date.min) ? Date:C102($input.Creation_Date.min) : Date:C102("2000-01-01")  // date YYYY-MM-DD
	$input.Creation_Date.max:=($input.Creation_Date.max) ? Date:C102($input.Creation_Date.max) : Date:C102("2350-12-31")  // date YYYY-MM-DD
	$input.orderBy:=($input.orderBy) || {}
	$input.orderBy.field:=($input.orderBy.field) || "Total"
	$input.orderBy.order:=($input.orderBy.order) || "desc"
	$input.top:=($input.top) || This:C1470.defaultTop
	$input.countOnly:=($input.countOnly) || False:C215
	
	$returnObject:={}
	$returnObject.form:="Invoices"
	$returnObject.dataClass:="INVOICES"
	$returnObject.counts:={}
	$returnObject.counts.total:=$entities.length
	
	If ($input.Client_ID#"any")
		$entities:=$entities.query("Client_ID = :1"; $input.Client_ID)
	End if 
	
	$entities:=$entities.query("Invoice_Number = :1 and Total >= :2 and Total <= :3 and Creation_Date >= :4 and Creation_Date <= :5 order by "+$input.orderBy.field+" "+$input.orderBy.order; $input.Invoice_Number; $input.Total.min; $input.Total.max; $input.Creation_Date.min; $input.Creation_Date.max)
	$returnObject.counts.totalFiltered:=$entities.length
	If ($returnObject.totalEntities>$input.top)
		$entities:=$entities.slice(0; $input.top)
	End if 
	$returnObject.counts.totalSent:=$entities.length
	$returnObject.entities:=($input.countOnly) ? [] : $entities.toCollection("ID, Invoice_Number, Client_ID, Creation_Date, Paid, Payment_Date, Total")
	
	return $returnObject
	
Function tool_getInvoiceLines($input : Object) : Object
	var $validation; $returnObject : Object
	var $entities : cs:C1710.INVOICE_LINESSelection:=ds:C1482.INVOICE_LINES.all()
	
	$validation:=JSON Validate:C1456($input; This:C1470._getToolArgumentsSchema(This:C1470._functionName(Call chain:C1662)))
	If (Not:C34($validation.success))
		return {error: "Could not validate input parameters against JSON Schema, call the tool again with proper input parameters"}
	End if 
	
	$input.Invoice_Number:=($input.Invoice_Number) || "@"
	$input.Client_ID:=($input.Client_ID) || "any"
	$input.Product_ID:=($input.Product_ID) || "any"
	$input.Invoice_ID:=($input.Invoice_ID) || "any"
	$input.Quantity:=$input.Quantity || {}
	$input.Quantity.min:=$input.Quantity.min || 0
	$input.Quantity.max:=$input.Quantity.max || 9999999
	$input.Total:=$input.Total || {}
	$input.Total.min:=$input.Total.min || 0
	$input.Total.max:=$input.Total.max || 9999999
	$input.orderBy:=($input.orderBy) || {}
	$input.orderBy.field:=($input.orderBy.field) || "Total"
	$input.orderBy.order:=($input.orderBy.order) || "desc"
	$input.top:=($input.top) || This:C1470.defaultTop
	$input.countOnly:=($input.countOnly) || False:C215
	
	$returnObject:={}
	$returnObject.form:="not available"
	$returnObject.dataClass:="INVOICE_LINES"
	$returnObject.counts:={}
	$returnObject.counts.total:=$entities.length
	
	If ($input.Client_ID#"any")
		$entities:=$entities.query("Invoice.Client_ID = :1"; $input.Client_ID)
	End if 
	
	If ($input.Invoice_Number#"any")
		$entities:=$entities.query("Invoice.Invoice_Number = :1"; $input.Invoice_Number)
	End if 
	
	If ($input.Product_ID#"any")
		$entities:=$entities.query("Product_ID = :1"; $input.Product_ID)
	End if 
	
	If ($input.Invoice_ID#"any")
		$entities:=$entities.query("Invoice_ID = :1"; $input.Invoice_ID)
	End if 
	
	$entities:=$entities.query("Total >= :1 and Total <= :2 and Quantity >= :3 and Quantity <= :4 order by "+$input.orderBy.field+" "+$input.orderBy.order; $input.Total.min; $input.Total.max; $input.Quantity.min; $input.Quantity.max)
	$returnObject.counts.totalFiltered:=$entities.length
	If ($returnObject.totalEntities>$input.top)
		$entities:=$entities.slice(0; $input.top)
	End if 
	$returnObject.counts.totalSent:=$entities.length
	$returnObject.entities:=($input.countOnly) ? [] : $entities.toCollection("ID, Line_Number, Invoice.Invoice_Number, Invoice.Client_ID, Total, Quantity, Product.ID")
	
	return $returnObject
	
	
	//MARK: -
	//MARK: onStreamTerminate and onStreamData
	
	
Function _onStreamTerminate($result : cs:C1710.AIKit.OpenAIChatCompletionsResult)
	var $me:=cs:C1710.AI_ChatWithTools.me
	
	If (Not:C34($result.success))
		ALERT:C41("Problem querying AI provider, please try again. Error: "+$result.errors[0].message)
		return 
	End if 
	
	$me.formObject.terminateChat()
	
Function _onStreamData($result : cs:C1710.AIKit.OpenAIChatCompletionsResult)
	var $me:=cs:C1710.AI_ChatWithTools.me
	
	If (Not:C34($result.success))
		ALERT:C41("Problem querying AI provider, please try again. Error: "+$result.errors[0].message)
		return 
	End if 
	
	If (Not:C34(Undefined:C82($me.AIBot.messages)))
		$me.formObject.progressChat({messages: $me.AIBot.messages})
	End if 
	
	
	
	//MARK: -
	//MARK: AIBot management functions
	
Function _relationsInfos() : Collection
	var $info; $relation; $field : Object
	var $relations : Collection
	
	$info:=cs:C1710.StructureInfo.me.get()
	$relations:=$info.relation.copy()
	$relations:=$relations.extract("name_1toN"; "name_1toN"; "name_Nto1"; "name_Nto1"; "related_field"; "related_field")
	For each ($relation; $relations)
		For each ($field; $relation.related_field)
			OB REMOVE:C1226($field.field_ref; "uuid")
			OB REMOVE:C1226($field.field_ref.table_ref; "uuid")
			$field.field_ref.dataClass:=$field.field_ref.table_ref
			OB REMOVE:C1226($field.field_ref; "table_ref")
		End for each 
	End for each 
	return $relations
	
Function messages() : Collection
	return (This:C1470.AIBot) ? This:C1470.AIBot.messages : Null:C1517
	
Function resetContext()
	This:C1470.AIClient:=Null:C1517
	This:C1470.AIBot:=Null:C1517
	
Function _initBot() : cs:C1710.AIKit.OpenAIChatHelper
	var $systemPrompt : Text
	var $options:=cs:C1710.AIKit.OpenAIChatCompletionsParameters.new()
	var $provider : Object
	var $relations : Collection:=This:C1470._relationsInfos()
	
	Try
		$provider:=JSON Parse:C1218(File:C1566("/RESOURCES/AIProvider.json").getText(); Is object:K8:27)
	Catch
		ALERT:C41("Missing or corrupted AI Provider settings file.\nMake sure your /RESOURCES/AIProvider.json is formatted properly")
		return Null:C1517
	End try
	
	This:C1470.AIClient:=cs:C1710.AIKit.OpenAI.new($provider.reasoning.key)
	If ($provider.reasoning.url#"")
		This:C1470.AIClient.baseURL:=$provider.reasoning.url
	End if 
	
	$options.model:=$provider.reasoning.model
	$options.stream:=True:C214
	$options.onData:=This:C1470._onStreamData
	$options.onTerminate:=This:C1470._onStreamTerminate
	$options.tool_choice:="auto"  //fixme: check if 'any'
	
	$systemPrompt:="You are a helpful assistant. I need your help to answer questions data stored in my application.\n"+\
		"**CONTEXT**\n"+\
		"The application stores data about invoices, products and clients"+\
		"In some cases, you'll need to cross query several tables (dataClasses) in order to answer. To help you, here are the application relations between tables (dataClasses):\n"+\
		JSON Stringify:C1217($relations)+"\n"+\
		"**INSTRUCTIONS**\n"+\
		"Analyze questions and answer step by step.\n"+\
		"Use the tools at your disposal to answer everytime you think they are relevant.\n"+\
		"**FORMATTING**\n"+\
		"Always use HTML. Avoid markdown. Use bullet lists and tables when presenting structured data.\n"+\
		"**IMPORTANT**\n"+\
		"When calling tools, always include all required arguments in valid JSON. Do not call a tool with empty arguments. If a value is missing, choose a reasonable default.\n"+\
		"Always double check tools results before answering. Especially when they rely on vector search. Indeed they may return results not matching with your search intention.\n"+\
		"When tool calling returns data not related with the initial question, or that you cannot use to answer, avoid detailing such results too much and stay short.\n"+\
		"**CHARTS**\n"+\
		"Create charts for rankings, comparisons, trends, or distributions. Format: <chart>{...JSON...}</chart>\n"+\
		"Available types: bar, line, pie, doughnut, radar, polarArea. Always include:\n"+\
		"- \"type\": chart type\n"+\
		"- \"data.labels\": array of x-axis labels\n"+\
		"- \"data.datasets\": array with \"label\", \"data\" (numeric array), \"backgroundColor\" (color array)\n"+\
		"- \"options.responsive\": true\n"+\
		"- \"options.plugins.title\": {\"display\": true, \"text\": \"Chart Title\"}\n"+\
		"- \"options.scales.y.beginAtZero\": true (for bar/line charts)\n"+\
		"Use distinct vibrant colors (e.g., #4caf50, #2196f3, #ff9800, #e91e63, #9c27b0). Set \"legend.display\" to false for single datasets, true for multiple.\n"+\
		"**CUSTOM URL HANDLING**\n"+\
		"Tools responses give information about the form to open when available, the dataClass and entities ID\n"+\
		"When you display any element coming from a tool response, you must use a custom url so that the user can open the corresponding form\n"+\
		"Such custom url must follow the following syntax examples:\n"+\
		"<a href=\"myapp://openform?form=Products&dataClass=PRODUCTS&entities=989511\">A single product</a>\n"+\
		"<a href=\"myapp://openform?form=Invoices&dataClass=INVOICESS&entities=654KJY,6467HGS,79864JSD\">A list of invoices</a>\n"+\
		"**NOTES**:\n"+\
		"The end-user sometimes asks irrelevant questions, not related to persons, skills, job position or locations.\n"+\
		"In such case, and only in such case, do not execute any tool and invite the user to ask more appropriate questions.\n"
	
	This:C1470.AIBot:=This:C1470.AIClient.chat.create($systemPrompt; $options)
	This:C1470._loadTools()
	
	return This:C1470.AIBot
	
	
	//MARK: -
	//MARK: Main entry point: askMe function
Function askMe($prompt : Text; $formObject : Object)
	This:C1470.formObject:=$formObject
	
	This:C1470.AIBot:=(This:C1470.AIBot) || This:C1470._initBot()
	return (This:C1470.AIBot) ? This:C1470.AIBot.prompt($prompt) : This:C1470.formObject.terminateChat()
	
	
	
	
	
	