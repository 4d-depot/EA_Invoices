property lastContentHash : Text

singleton Class constructor()
	// Singleton instance is automatically managed by 4D
	This:C1470.lastContentHash:=""
	
	
	//MARK: -
	//MARK: Private helper methods
	
Function _normalizeLineBreaks($text : Text) : Text
	// Convert literal \n to actual line breaks
	return Replace string:C233($text; "\\n"; Char:C90(Line feed:K15:40); *)
	
Function _createTag($tagType : Text; $content : Text; $isStreaming : Boolean) : Text
	// Create consistent HTML tags for different content types
	var $class : Text
	var $icon : Text
	
	Case of 
		: ($tagType="think")
			$class:="think-tag"
			$icon:="💭"
		Else 
			$class:="generic-tag"
			$icon:=""
	End case 
	
	If ($isStreaming)
		$class+=" streaming"
	End if 
	
	// Don't add icon here - let JavaScript handle it for better control
	return "<br><span class=\""+$class+"\" data-content=\""+This:C1470._escapeHTML($content)+"\">"+$content+"</span><br>"
	
Function _createPreview($text : Text; $maxLength : Integer) : Text
	// Create a preview of text content by normalizing whitespace and trimming
	var $preview : Text:=$text
	
	// Replace line feeds and tabs with spaces
	$preview:=Replace string:C233($preview; Char:C90(Line feed:K15:40); " "; *)
	$preview:=Replace string:C233($preview; Char:C90(Tab:K15:37); " "; *)
	
	// Trim whitespace using native 4D function
	$preview:=Trim:C1853($preview)
	
	// Truncate if too long
	If (Length:C16($preview)>$maxLength)
		$preview:=Substring:C12($preview; 1; $maxLength-3)+"..."
	End if 
	
	return $preview
	
Function _escapeHTML($text : Text) : Text
	// Escape HTML content with a single pass for better performance
	var $escaped : Text:=$text
	
	// Use a single Replace string call for better performance
	$escaped:=Replace string:C233($escaped; "&"; "&amp;"; *)  // Replace all occurrences
	$escaped:=Replace string:C233($escaped; "<"; "&lt;"; *)
	$escaped:=Replace string:C233($escaped; ">"; "&gt;"; *)
	$escaped:=Replace string:C233($escaped; "\""; "&quot;"; *)
	$escaped:=Replace string:C233($escaped; "'"; "&#39;"; *)
	
	return $escaped
	
	
	
Function _cleanMarkdownCodeBlocks($content : Text) : Text
	// Remove markdown code block markers like ```html...``` or ```...```
	var $result : Text:=$content
	var $startPos : Integer
	var $endPos : Integer
	
	// Handle code blocks starting with ``` (any language)
	If (Position:C15("```"; $result)=1)
		// Skip past opening ``` and optional language specifier
		$startPos:=Position:C15(Char:C90(Line feed:K15:40); $result)
		If ($startPos>0)
			$result:=Substring:C12($result; $startPos+1)  // Remove ```language\n
		Else 
			$result:=Substring:C12($result; 4)  // Remove ``` only
		End if 
		
		// Remove trailing ``` if present
		$endPos:=Position:C15("```"; $result; Length:C16($result)-2)
		If ($endPos>0)
			$result:=Substring:C12($result; 1; $endPos-1)
		End if 
	End if 
	
	// Use native 4D trim function
	$result:=Trim:C1853($result)
	
	return $result
	
	
Function _hasHTMLTags($content : Text) : Boolean
	// Check if content contains common HTML tags - optimized with early exit
	var $htmlTags : Collection:=["<div"; "<p>"; "<ul>"; "<li>"; "<strong>"; "<br>"; "<table"; "<tr>"; "<td>"; "<th>"; "<h1>"; "<h2>"; "<h3>"; "<h4>"; "<h5>"; "<h6>"; "<span"; "<ol>"; "<a "; "<a>"]
	var $tag : Text
	
	For each ($tag; $htmlTags)
		If (Position:C15($tag; $content)>0)
			return True:C214  // Early exit when first tag is found
		End if 
	End for each 
	
	return False:C215
	
	
Function _detectChartMarker($content : Text) : Object
	// Detect chart markers like <chart>...</chart> in content
	// Returns {found: Boolean, startPos: Integer, endPos: Integer, isComplete: Boolean}
	var $result : Object:={found: False:C215; startPos: 0; endPos: 0; isComplete: False:C215}
	
	$result.startPos:=Position:C15("<chart>"; $content)
	If ($result.startPos>0)
		$result.found:=True:C214
		$result.endPos:=Position:C15("</chart>"; $content; $result.startPos)
		$result.isComplete:=($result.endPos>0)
	End if 
	
	return $result
	
	
Function _generateChartHTML($chartData : Text; $isStreaming : Boolean; $chartId : Text) : Text
	// Generate chart HTML with skeleton loader for streaming state
	var $result : Text
	var $chartConfig : Object
	var $containerClass : Text:="chart-container"
	
	If ($isStreaming)
		// Show skeleton loader while streaming - use simple CSS-based skeleton like tool-spinner
		$containerClass+=" streaming"
		$result:="<div class=\""+$containerClass+"\" data-chart-id=\""+$chartId+"\">\n"
		$result+="<span class=\"chart-skeleton\"></span>\n"
		$result+="</div>\n"
	Else 
		// Parse complete chart data and render
		$chartConfig:=This:C1470._cleanAndParseJSON($chartData)
		
		If ($chartConfig=Null:C1517)
			return "<!-- Invalid chart config -->\n"
		End if 
		
		$result:="<div class=\""+$containerClass+"\" data-chart-id=\""+$chartId+"\" data-chart-rendered=\"false\">\n"
		
		// Extract title from chart config if present
		var $title : Text:=This:C1470._extractChartTitle($chartConfig)
		If ($title#"")
			$result+="<div class=\"chart-title\">"+This:C1470._escapeHTML($title)+"</div>\n"
		End if 
		
		// Escape the JSON for HTML attribute
		var $escapedConfig : Text:=JSON Stringify:C1217($chartConfig)
		$escapedConfig:=Replace string:C233($escapedConfig; "\""; "&quot;"; *)
		
		$result+="<canvas id=\""+$chartId+"\" data-chart-config=\""+$escapedConfig+"\"></canvas>\n"
		$result+="</div>\n"
	End if 
	
	return $result
	
	
Function _extractChartTitle($chartConfig : Object) : Text
	// Extract title from chart configuration
	If ($chartConfig.options#Null:C1517)
		If ($chartConfig.options.plugins#Null:C1517)
			If ($chartConfig.options.plugins.title#Null:C1517)
				If ($chartConfig.options.plugins.title.text#Null:C1517)
					return String:C10($chartConfig.options.plugins.title.text)
				End if 
			End if 
		End if 
	End if 
	return ""
	
	
	
Function _processThinkSections($content : Text) : Text
	// Process content that contains <think> sections with state logic like tool calls
	var $result : Text:=$content
	var $thinkStart : Integer
	var $thinkEnd : Integer
	var $beforeThink : Text
	var $thinkContent : Text
	var $afterThink : Text
	var $thinkCard : Text
	var $thinkPreview : Text
	var $isThinkRunning : Boolean
	
	// Process all <think> sections in the content
	Repeat 
		$thinkStart:=Position:C15("<think>"; $result)
		If ($thinkStart>0)
			$thinkEnd:=Position:C15("</think>"; $result; $thinkStart)
			
			// Determine if thinking is running (like $isToolRunning logic)
			$isThinkRunning:=($thinkEnd=0)  // No closing tag = still thinking
			
			If ($isThinkRunning)
				// Still thinking - show streaming content
				$beforeThink:=Substring:C12($result; 1; $thinkStart-1)
				$thinkContent:=Substring:C12($result; $thinkStart+7)  // Get content after <think>
				
				// Show the actual streaming content, not just "Thinking..."
				$thinkCard:=This:C1470._createTag("think"; $thinkContent; True:C214)
				$result:=$beforeThink+$thinkCard
				break  // Exit like tool calls do when running
			Else 
				// Thinking complete - show content (like completed tool calls)
				$beforeThink:=Substring:C12($result; 1; $thinkStart-1)
				$thinkContent:=Substring:C12($result; $thinkStart+7; $thinkEnd-$thinkStart-7)
				$afterThink:=Substring:C12($result; $thinkEnd+8)
				
				// For completed thinking, pass the full content (JavaScript will handle summary)
				$thinkCard:=This:C1470._createTag("think"; $thinkContent; False:C215)
				$result:=$beforeThink+$thinkCard+$afterThink
			End if 
		End if 
	Until ($thinkStart=0)
	
	return $result
	
	
Function _processChartSections($content : Text; $messageIndex : Integer) : Text
	// Process content that contains <chart> sections similar to think sections
	var $result : Text:=$content
	var $chartMarker : Object
	var $beforeChart : Text
	var $chartContent : Text
	var $afterChart : Text
	var $chartHTML : Text
	var $chartId : Text
	var $chartCounter : Integer:=1
	
	// Process all <chart> sections in the content
	Repeat 
		$chartMarker:=This:C1470._detectChartMarker($result)
		
		If ($chartMarker.found)
			// Use message index + counter for stable IDs across streaming updates
			$chartId:="chart-msg"+String:C10($messageIndex)+"-"+String:C10($chartCounter)
			$chartCounter:=$chartCounter+1
			
			If ($chartMarker.isComplete)
				// Complete chart - parse and render
				$beforeChart:=Substring:C12($result; 1; $chartMarker.startPos-1)
				$chartContent:=Substring:C12($result; $chartMarker.startPos+7; $chartMarker.endPos-$chartMarker.startPos-7)
				$afterChart:=Substring:C12($result; $chartMarker.endPos+8)
				
				// Trim excessive line breaks around chart
				// Remove trailing line breaks from before section
				While ((Length:C16($beforeChart)>0) && ((Substring:C12($beforeChart; Length:C16($beforeChart); 1)=Char:C90(Line feed:K15:40)) || (Substring:C12($beforeChart; Length:C16($beforeChart); 1)=Char:C90(Carriage return:K15:38))))
					$beforeChart:=Substring:C12($beforeChart; 1; Length:C16($beforeChart)-1)
				End while 
				
				// Remove leading line breaks from after section
				While ((Length:C16($afterChart)>0) && ((Substring:C12($afterChart; 1; 1)=Char:C90(Line feed:K15:40)) || (Substring:C12($afterChart; 1; 1)=Char:C90(Carriage return:K15:38))))
					$afterChart:=Substring:C12($afterChart; 2)
				End while 
				
				$chartHTML:=This:C1470._generateChartHTML($chartContent; False:C215; $chartId)
				// No line breaks around chart - it's a block element with CSS margins
				$result:=$beforeChart+$chartHTML+$afterChart
			Else 
				// Streaming chart - show skeleton
				$beforeChart:=Substring:C12($result; 1; $chartMarker.startPos-1)
				$chartContent:=Substring:C12($result; $chartMarker.startPos+7)
				
				$chartHTML:=This:C1470._generateChartHTML($chartContent; True:C214; $chartId)
				$result:=$beforeChart+$chartHTML
				break  // Stop processing when streaming
			End if 
		End if 
	Until (Not:C34($chartMarker.found))
	
	return $result
	
	
Function _processRegularContent($content : Text; $messageIndex : Integer) : Text
	// Process content without [PERSONS] marker but check for <think> and <chart> sections
	var $processedContent : Text:=$content
	var $cleanContent : Text
	var $contentHasHTML : Boolean
	
	// Convert literal \n to actual line breaks using centralized function
	$processedContent:=This:C1470._normalizeLineBreaks($processedContent)
	
	// Process <think> sections BEFORE any other processing
	If (Position:C15("<think>"; $processedContent)>0)
		$processedContent:=This:C1470._processThinkSections($processedContent)
	End if 
	
	// Process <chart> sections BEFORE HTML processing
	If (Position:C15("<chart>"; $processedContent)>0)
		$processedContent:=This:C1470._processChartSections($processedContent; $messageIndex)
	End if 
	
	// Then clean markdown and check for HTML tags
	$cleanContent:=This:C1470._cleanMarkdownCodeBlocks($processedContent)
	$contentHasHTML:=This:C1470._hasHTMLTags($cleanContent)
	
	If ($contentHasHTML)
		// HTML content doesn't need line breaks converted - HTML handles spacing
		// Wrap HTML content - JavaScript cleanupHTML handles incomplete tags
		return "<div class=\"html-content\">"+$cleanContent+"</div>"
	Else 
		// Escape HTML but preserve line breaks by converting to <br>
		var $escaped : Text:=This:C1470._escapeHTML($processedContent)
		$escaped:=Replace string:C233($escaped; Char:C90(Line feed:K15:40); "<br>"; *)
		return $escaped
	End if 
	
	
Function _hasIncompleteToolArgs($toolCall : Object) : Boolean
	// Check if tool call has incomplete or missing arguments
	var $args : Text:=$toolCall.function.arguments
	If ($args=Null:C1517) || ($args="")
		return True:C214
	End if 
	
	// Try to parse JSON arguments
	var $parsed : Object
	Try
		$parsed:=JSON Parse:C1218($args; Is object:K8:27)
		return ($parsed=Null:C1517)
	Catch
		return True:C214  // Parse error means incomplete
	End try
	
	
Function _hasToolResponse($toolCall : Object; $messages : Collection; $currentIndex : Integer) : Boolean
	// Check if this tool call has a response by looking ahead in messages array
	If ($toolCall.id=Null:C1517) || ($toolCall.id="")
		return False:C215
	End if 
	
	// Look for tool response messages after current message
	For ($j; $currentIndex+1; $messages.length-1)
		var $laterMessage : Object:=$messages[$j]
		If ($laterMessage.role="tool") && ($laterMessage.tool_call_id=$toolCall.id)
			return True:C214
		End if 
	End for 
	
	return False:C215
	
	
Function _renderToolCallArgs($toolCall : Object) : Text
	// Render tool call arguments as HTML
	var $argumentsText : Text:=$toolCall.function.arguments
	var $toolArgs : Object
	var $result : Text
	var $argKey : Text
	var $argCount : Integer
	var $argValue : Text
	
	If ($argumentsText=Null:C1517) || ($argumentsText="")
		return ""
	End if 
	
	// Try to parse JSON arguments
	Try
		$toolArgs:=JSON Parse:C1218($argumentsText; Is object:K8:27)
	Catch
		// If JSON parsing fails (incomplete stream), show raw arguments
		return "<span class=\"tool-args\">"+This:C1470._escapeHTML($argumentsText)+"</span>"
	End try
	
	If ($toolArgs=Null:C1517)
		return "<span class=\"tool-args\">"+This:C1470._escapeHTML($argumentsText)+"</span>"
	End if 
	
	// Successfully parsed JSON - show as compact key:value pairs
	$result:="<span class=\"tool-args\">"
	$argCount:=0
	For each ($argKey; $toolArgs)
		If ($argCount>0)
			$result+="<span class=\"arg-separator\">,</span>"
		End if 
		$result+="<span class=\"arg-key\">"+This:C1470._escapeHTML($argKey)+":</span>"
		// Handle both primitive values and objects/collections
		Case of 
			: (Value type:C1509($toolArgs[$argKey])=Is object:K8:27) || (Value type:C1509($toolArgs[$argKey])=Is collection:K8:32)
				$argValue:=JSON Stringify:C1217($toolArgs[$argKey])
			Else 
				$argValue:=String:C10($toolArgs[$argKey])
		End case 
		$result+="<span class=\"arg-value\">"+This:C1470._escapeHTML($argValue)+"</span>"
		$argCount:=$argCount+1
	End for each 
	$result+="</span>"
	
	return $result
	
	
Function _processToolCalls($message : Object; $messages : Collection; $currentIndex : Integer) : Text
	// Process all tool calls for a message
	var $result : Text:=""
	var $toolCall : Object
	
	// Render each tool call with appropriate icon
	For each ($toolCall; $message.tool_calls)
		var $isToolRunning : Boolean:=False:C215
		var $toolIcon : Text
		
		// Determine if this specific tool is still running
		If (This:C1470._hasIncompleteToolArgs($toolCall))
			$isToolRunning:=True:C214
		Else 
			$isToolRunning:=(This:C1470._hasToolResponse($toolCall; $messages; $currentIndex)=False:C215)
		End if 
		
		// Choose icon based on tool status
		If ($isToolRunning)
			$toolIcon:="<span class=\"tool-spinner\"></span>"  // CSS spinner for running tools
		Else 
			$toolIcon:="<span class=\"tool-icon\"><img src=\"../Resources/tool-icon.svg\" alt=\"tool\"></span>"  // Small SVG tool icon for completed tools
		End if 
		
		$result+="<span class=\"tool-call\">"
		$result+="<span class=\"tool-name\">"+$toolIcon+" "+This:C1470._escapeHTML($toolCall.function.name)+"</span>"
		$result+=This:C1470._renderToolCallArgs($toolCall)
		$result+="</span> "
	End for each 
	
	return $result
	
	
Function _generateContentHash($messages : Collection) : Text
	// Generate a simple hash of the messages to detect if content changed
	var $content : Text
	var $message : Object
	
	For each ($message; $messages)
		$content+=$message.role+String:C10($message.content)
		If ($message.tool_calls#Null:C1517)
			$content+=JSON Stringify:C1217($message.tool_calls)
		End if 
	End for each 
	
	return Generate digest:C1147($content; MD5 digest:K66:1)
	
	
	//MARK: -
	//MARK: Public methods
	
Function getInitialHTML() : Text
	// Returns the filename of the HTML template for initial load
	// The calling code should combine this with Current resources folder
	return "chat-template.html"
	
	
Function generateMessagesHTML($messages : Collection) : Text
	// Generates only the messages HTML content (not the full page)
	var $message : Object
	var $content : Text
	var $i : Integer
	var $result : Text
	
	For ($i; 0; $messages.length-1)
		$message:=$messages[$i]
		
		Case of 
			: ($message.role="user")
				$result+="<div class=\"message user-message\">\n"
				$result+="<div class=\"message-content\">"+This:C1470._escapeHTML($message.content)+"</div>\n"
				$result+="</div>\n\n"
				
			: ($message.role="assistant")
				$result+="<div class=\"message assistant-message\">\n"
				
				// Only show copy button if there's actual content (not just tool calls)
				var $hasContent : Boolean:=(($message.content#Null:C1517) && ($message.content#""))
				If ($hasContent)
					$result+="<button class=\"copy-button\" onclick=\"copyMessageContent(this, "+String:C10($i)+")\">Copy</button>\n"
				End if 
				
				$result+="<div class=\"message-content\">\n"
				
				// Handle content if present (show before tool calls)
				If ($message.content#Null:C1517) && ($message.content#"")
					$content:=This:C1470._processRegularContent($message.content; $i)
					$result+=$content+"\n"
				End if 
				
				// Handle tool calls if present (show after content)
				If ($message.tool_calls#Null:C1517) && ($message.tool_calls.length>0)
					$result+=This:C1470._processToolCalls($message; $messages; $i)
				End if 
				
				$result+="</div>\n"
				$result+="</div>\n\n"
				
			: ($message.role="tool")
				// Skip tool response messages (they're already handled in assistant messages)
				// But for debugging, let's log that we're skipping them
				
			Else 
				// Debug: log unknown message types
				$result+="<!-- DEBUG: Unknown message role: "+This:C1470._escapeHTML(String:C10($message.role))+" -->\n"
		End case 
	End for 
	
	return $result
	
	
Function updateWebAreaWithJS($webAreaName : Text; $messages : Collection)
	// Update web area content via JavaScript without page reload
	var $messagesHTML : Text
	var $jsResult : Text
	
	$messagesHTML:=This:C1470.generateMessagesHTML($messages)
	
	// Early exit if no content
	If (Length:C16($messagesHTML)=0)
		return 
	End if 
	
	// Minimal escaping for JavaScript safety - single pass with Replace string *
	$messagesHTML:=Replace string:C233($messagesHTML; "\\"; "\\\\"; *)  // Escape backslashes
	$messagesHTML:=Replace string:C233($messagesHTML; Char:C90(Line feed:K15:40); " "; *)  // Replace line feeds with spaces
	$messagesHTML:=Replace string:C233($messagesHTML; Char:C90(Carriage return:K15:38); " "; *)  // Replace carriage returns with spaces
	$messagesHTML:=Replace string:C233($messagesHTML; Char:C90(Tab:K15:37); " "; *)  // Replace tabs with spaces
	
	WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; $webAreaName; "updateMessages"; $jsResult; $messagesHTML)
	
	
Function _cleanAndParseJSON($jsonContent : Text) : Object
	// Shared helper to clean and parse JSON content
	var $cleanJSON : Text:=$jsonContent
	var $parsedJSON : Object
	
	// Clean up JSON content in one pass
	$cleanJSON:=Replace string:C233($cleanJSON; Char:C90(Tab:K15:37); "")
	$cleanJSON:=Replace string:C233($cleanJSON; Char:C90(Line feed:K15:40); "")
	$cleanJSON:=Replace string:C233($cleanJSON; Char:C90(Carriage return:K15:38); "")
	$cleanJSON:=Replace string:C233($cleanJSON; "json"+Char:C90(Line feed:K15:40); "")  // Remove "json" if present
	
	Try
		$parsedJSON:=JSON Parse:C1218($cleanJSON)
		return $parsedJSON
	Catch
		return Null:C1517
	End try
	