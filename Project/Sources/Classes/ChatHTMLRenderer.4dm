property lastContentHash : Text

singleton Class constructor()
	// Singleton instance is automatically managed by 4D
	This.lastContentHash:=""
	
	
	//MARK: -
	//MARK: Private helper methods
	
Function _normalizeLineBreaks($text : Text) : Text
	// Convert literal \n to actual line breaks
	return Replace string($text; "\\n"; Char(Line feed); *)

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
	return "<br><span class=\""+$class+"\" data-content=\""+This._escapeHTML($content)+"\">"+$content+"</span><br>"

Function _createPreview($text : Text; $maxLength : Integer) : Text
	// Create a preview of text content by normalizing whitespace and trimming
	var $preview : Text:=$text
	
	// Replace line feeds and tabs with spaces
	$preview:=Replace string($preview; Char(Line feed); " "; *)
	$preview:=Replace string($preview; Char(Tab); " "; *)
	
	// Trim whitespace using native 4D function
	$preview:=Trim($preview)
	
	// Truncate if too long
	If (Length($preview)>$maxLength)
		$preview:=Substring($preview; 1; $maxLength-3)+"..."
	End if
	
	return $preview

Function _escapeHTML($text : Text) : Text
	// Escape HTML content with a single pass for better performance
	var $escaped : Text:=$text
	
	// Use a single Replace string call for better performance
	$escaped:=Replace string($escaped; "&"; "&amp;"; *)  // Replace all occurrences
	$escaped:=Replace string($escaped; "<"; "&lt;"; *)
	$escaped:=Replace string($escaped; ">"; "&gt;"; *)
	$escaped:=Replace string($escaped; "\""; "&quot;"; *)
	$escaped:=Replace string($escaped; "'"; "&#39;"; *)
	
	return $escaped
	


Function _cleanMarkdownCodeBlocks($content : Text) : Text
	// Remove markdown code block markers like ```html...``` or ```...```
	var $result : Text:=$content
	var $startPos : Integer
	var $endPos : Integer
	
	// Handle code blocks starting with ``` (any language)
	If (Position("```"; $result)=1)
		// Skip past opening ``` and optional language specifier
		$startPos:=Position(Char(Line feed); $result)
		If ($startPos>0)
			$result:=Substring($result; $startPos+1)  // Remove ```language\n
		Else 
			$result:=Substring($result; 4)  // Remove ``` only
		End if 
		
		// Remove trailing ``` if present
		$endPos:=Position("```"; $result; Length($result)-2)
		If ($endPos>0)
			$result:=Substring($result; 1; $endPos-1)
		End if 
	End if 
	
	// Use native 4D trim function
	$result:=Trim($result)
	
	return $result


Function _hasHTMLTags($content : Text) : Boolean
	// Check if content contains common HTML tags - optimized with early exit
	var $htmlTags : Collection:=["<div"; "<p>"; "<ul>"; "<li>"; "<strong>"; "<br>"; "<table"; "<tr>"; "<td>"; "<th>"; "<h1>"; "<h2>"; "<h3>"; "<h4>"; "<h5>"; "<h6>"; "<span"; "<ol>"; "<a "; "<a>"]
	var $tag : Text
	
	For each ($tag; $htmlTags)
		If (Position($tag; $content)>0)
			return True  // Early exit when first tag is found
		End if 
	End for each 
	
	return False


Function _detectChartMarker($content : Text) : Object
	// Detect chart markers like <chart>...</chart> in content
	// Returns {found: Boolean, startPos: Integer, endPos: Integer, isComplete: Boolean}
	var $result : Object:={found: False; startPos: 0; endPos: 0; isComplete: False}
	
	$result.startPos:=Position("<chart>"; $content)
	If ($result.startPos>0)
		$result.found:=True
		$result.endPos:=Position("</chart>"; $content; $result.startPos)
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
		$chartConfig:=This._cleanAndParseJSON($chartData)
		
		If ($chartConfig=Null)
			return "<!-- Invalid chart config -->\n"
		End if 
		
		$result:="<div class=\""+$containerClass+"\" data-chart-id=\""+$chartId+"\" data-chart-rendered=\"false\">\n"
		
		// Extract title from chart config if present
		var $title : Text:=This._extractChartTitle($chartConfig)
		If ($title#"")
			$result+="<div class=\"chart-title\">"+This._escapeHTML($title)+"</div>\n"
		End if
		
		// Escape the JSON for HTML attribute
		var $escapedConfig : Text:=JSON Stringify($chartConfig)
		$escapedConfig:=Replace string($escapedConfig; "\""; "&quot;"; *)
		
		$result+="<canvas id=\""+$chartId+"\" data-chart-config=\""+$escapedConfig+"\"></canvas>\n"
		$result+="</div>\n"
	End if 
	
	return $result


Function _extractChartTitle($chartConfig : Object) : Text
	// Extract title from chart configuration
	If ($chartConfig.options#Null)
		If ($chartConfig.options.plugins#Null)
			If ($chartConfig.options.plugins.title#Null)
				If ($chartConfig.options.plugins.title.text#Null)
					return String($chartConfig.options.plugins.title.text)
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
		$thinkStart:=Position("<think>"; $result)
		If ($thinkStart>0)
			$thinkEnd:=Position("</think>"; $result; $thinkStart)
			
			// Determine if thinking is running (like $isToolRunning logic)
			$isThinkRunning:=($thinkEnd=0)  // No closing tag = still thinking
			
			If ($isThinkRunning)
				// Still thinking - show streaming content
				$beforeThink:=Substring($result; 1; $thinkStart-1)
				$thinkContent:=Substring($result; $thinkStart+7)  // Get content after <think>
				
				// Show the actual streaming content, not just "Thinking..."
				$thinkCard:=This._createTag("think"; $thinkContent; True)
				$result:=$beforeThink+$thinkCard
				break  // Exit like tool calls do when running
			Else 
				// Thinking complete - show content (like completed tool calls)
				$beforeThink:=Substring($result; 1; $thinkStart-1)
				$thinkContent:=Substring($result; $thinkStart+7; $thinkEnd-$thinkStart-7)
				$afterThink:=Substring($result; $thinkEnd+8)
				
				// For completed thinking, pass the full content (JavaScript will handle summary)
				$thinkCard:=This._createTag("think"; $thinkContent; False)
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
		$chartMarker:=This._detectChartMarker($result)
		
		If ($chartMarker.found)
			// Use message index + counter for stable IDs across streaming updates
			$chartId:="chart-msg"+String($messageIndex)+"-"+String($chartCounter)
			$chartCounter:=$chartCounter+1
			
			If ($chartMarker.isComplete)
				// Complete chart - parse and render
				$beforeChart:=Substring($result; 1; $chartMarker.startPos-1)
				$chartContent:=Substring($result; $chartMarker.startPos+7; $chartMarker.endPos-$chartMarker.startPos-7)
				$afterChart:=Substring($result; $chartMarker.endPos+8)
				
				$chartHTML:=This._generateChartHTML($chartContent; False; $chartId)
				$result:=$beforeChart+$chartHTML+$afterChart
			Else 
				// Streaming chart - show skeleton
				$beforeChart:=Substring($result; 1; $chartMarker.startPos-1)
				$chartContent:=Substring($result; $chartMarker.startPos+7)
				
				$chartHTML:=This._generateChartHTML($chartContent; True; $chartId)
				$result:=$beforeChart+$chartHTML
				break  // Stop processing when streaming
			End if 
		End if 
	Until (Not($chartMarker.found))
	
	return $result


Function _processRegularContent($content : Text; $messageIndex : Integer) : Text
	// Process content without [PERSONS] marker but check for <think> and <chart> sections
	var $processedContent : Text:=$content
	var $cleanContent : Text
	var $contentHasHTML : Boolean
	
	// Convert literal \n to actual line breaks using centralized function
	$processedContent:=This._normalizeLineBreaks($processedContent)
	
	// Process <think> sections BEFORE any other processing
	If (Position("<think>"; $processedContent)>0)
		$processedContent:=This._processThinkSections($processedContent)
	End if 
	
	// Process <chart> sections BEFORE HTML processing
	If (Position("<chart>"; $processedContent)>0)
		$processedContent:=This._processChartSections($processedContent; $messageIndex)
	End if 
	
	// Then clean markdown and check for HTML tags
	$cleanContent:=This._cleanMarkdownCodeBlocks($processedContent)
	$contentHasHTML:=This._hasHTMLTags($cleanContent)
	
	If ($contentHasHTML)
		// Wrap HTML content - JavaScript cleanupHTML handles incomplete tags
		return "<div class=\"html-content\">"+ $cleanContent+"</div>"
	Else 
		// Escape HTML but preserve line breaks by converting to <br>
		var $escaped : Text:=This._escapeHTML($processedContent)
		$escaped:=Replace string($escaped; Char(Line feed); "<br>"; *)
		return $escaped
	End if


Function _hasIncompleteToolArgs($toolCall : Object) : Boolean
	// Check if tool call has incomplete or missing arguments
	var $args : Text:=$toolCall.function.arguments
	If ($args=Null) || ($args="")
		return True
	End if 
	
	// Try to parse JSON arguments
	var $parsed : Object
	Try
		$parsed:=JSON Parse($args; Is object)
		return ($parsed=Null)
	Catch
		return True  // Parse error means incomplete
	End try


Function _hasToolResponse($toolCall : Object; $messages : Collection; $currentIndex : Integer) : Boolean
	// Check if this tool call has a response by looking ahead in messages array
	If ($toolCall.id=Null) || ($toolCall.id="")
		return False
	End if 
	
	// Look for tool response messages after current message
	For ($j; $currentIndex+1; $messages.length-1)
		var $laterMessage : Object:=$messages[$j]
		If ($laterMessage.role="tool") && ($laterMessage.tool_call_id=$toolCall.id)
			return True
		End if 
	End for 
	
	return False


Function _renderToolCallArgs($toolCall : Object) : Text
	// Render tool call arguments as HTML
	var $argumentsText : Text:=$toolCall.function.arguments
	var $toolArgs : Object
	var $result : Text
	var $argKey : Text
	var $argCount : Integer
	var $argValue : Text
	
	If ($argumentsText=Null) || ($argumentsText="")
		return ""
	End if 
	
	// Try to parse JSON arguments
	Try
		$toolArgs:=JSON Parse($argumentsText; Is object)
	Catch
		// If JSON parsing fails (incomplete stream), show raw arguments
		return "<span class=\"tool-args\">"+This._escapeHTML($argumentsText)+"</span>"
	End try
	
	If ($toolArgs=Null)
		return "<span class=\"tool-args\">"+This._escapeHTML($argumentsText)+"</span>"
	End if 
	
	// Successfully parsed JSON - show as compact key:value pairs
	$result:="<span class=\"tool-args\">"
	$argCount:=0
	For each ($argKey; $toolArgs)
			If ($argCount>0)
				$result+="<span class=\"arg-separator\">,</span>"
			End if 
		$result+="<span class=\"arg-key\">"+This._escapeHTML($argKey)+":</span>"
		// Handle both primitive values and objects/collections
		Case of 
			: (Value type($toolArgs[$argKey])=Is object) || (Value type($toolArgs[$argKey])=Is collection)
				$argValue:=JSON Stringify($toolArgs[$argKey])
			Else 
				$argValue:=String($toolArgs[$argKey])
		End case 
		$result+="<span class=\"arg-value\">"+This._escapeHTML($argValue)+"</span>"
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
		var $isToolRunning : Boolean:=False
		var $toolIcon : Text
		
		// Determine if this specific tool is still running
		If (This._hasIncompleteToolArgs($toolCall))
			$isToolRunning:=True
		Else 
			$isToolRunning:=(This._hasToolResponse($toolCall; $messages; $currentIndex)=False)
		End if 
		
		// Choose icon based on tool status
		If ($isToolRunning)
			$toolIcon:="<span class=\"tool-spinner\"></span>"  // CSS spinner for running tools
		Else 
			$toolIcon:="<span class=\"tool-icon\"><img src=\"../Resources/tool-icon.svg\" alt=\"tool\"></span>"  // Small SVG tool icon for completed tools
		End if 
		
		$result+="<span class=\"tool-call\">"
		$result+="<span class=\"tool-name\">"+$toolIcon+" "+This._escapeHTML($toolCall.function.name)+"</span>"
		$result+=This._renderToolCallArgs($toolCall)
		$result+="</span> "
	End for each 
	
	return $result


Function _generateContentHash($messages : Collection) : Text
	// Generate a simple hash of the messages to detect if content changed
	var $content : Text
	var $message : Object
	
	For each ($message; $messages)
		$content+=$message.role+String($message.content)
		If ($message.tool_calls#Null)
			$content+=JSON Stringify($message.tool_calls)
		End if 
	End for each 
	
	return Generate digest($content; MD5 digest)
	

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
				$result+="<div class=\"message-content\">"+This._escapeHTML($message.content)+"</div>\n"
				$result+="</div>\n\n"
				
			: ($message.role="assistant")
				$result+="<div class=\"message assistant-message\">\n"
				
				// Only show copy button if there's actual content (not just tool calls)
				var $hasContent : Boolean:=(($message.content#Null) && ($message.content#""))
				If ($hasContent)
					$result+="<button class=\"copy-button\" onclick=\"copyMessageContent(this, "+String($i)+")\">Copy</button>\n"
				End if 
				
				$result+="<div class=\"message-content\">\n"
				
				// Handle content if present (show before tool calls)
				If ($message.content#Null) && ($message.content#"")
					$content:=This._processRegularContent($message.content; $i)
					$result+=$content+"\n"
				End if 
				
				// Handle tool calls if present (show after content)
				If ($message.tool_calls#Null) && ($message.tool_calls.length>0)
					$result+=This._processToolCalls($message; $messages; $i)
				End if 
				
				$result+="</div>\n"
				$result+="</div>\n\n"
				
			: ($message.role="tool")
				// Skip tool response messages (they're already handled in assistant messages)
				// But for debugging, let's log that we're skipping them
				
			Else 
				// Debug: log unknown message types
				$result+="<!-- DEBUG: Unknown message role: "+This._escapeHTML(String($message.role))+" -->\n"
		End case 
	End for 
	
	return $result
	
	
Function updateWebAreaWithJS($webAreaName : Text; $messages : Collection)
	// Update web area content via JavaScript without page reload
	var $messagesHTML : Text
	var $jsResult : Text
	
	$messagesHTML:=This.generateMessagesHTML($messages)
	
	// Early exit if no content
	If (Length($messagesHTML)=0)
		return 
	End if 
	
	// Minimal escaping for JavaScript safety - single pass with Replace string *
	$messagesHTML:=Replace string($messagesHTML; "\\"; "\\\\"; *)  // Escape backslashes
	$messagesHTML:=Replace string($messagesHTML; Char(Line feed); " "; *)  // Replace line feeds with spaces
	$messagesHTML:=Replace string($messagesHTML; Char(Carriage return); " "; *)  // Replace carriage returns with spaces
	$messagesHTML:=Replace string($messagesHTML; Char(Tab); " "; *)  // Replace tabs with spaces
	
	WA EXECUTE JAVASCRIPT FUNCTION(*; $webAreaName; "updateMessages"; $jsResult; $messagesHTML)


Function _cleanAndParseJSON($jsonContent : Text) : Object
	// Shared helper to clean and parse JSON content
	var $cleanJSON : Text:=$jsonContent
	var $parsedJSON : Object
	
	// Clean up JSON content in one pass
	$cleanJSON:=Replace string($cleanJSON; Char(Tab); "")
	$cleanJSON:=Replace string($cleanJSON; Char(Line feed); "")
	$cleanJSON:=Replace string($cleanJSON; Char(Carriage return); "")
	$cleanJSON:=Replace string($cleanJSON; "json"+Char(Line feed); "")  // Remove "json" if present
	
	Try
		$parsedJSON:=JSON Parse($cleanJSON)
		return $parsedJSON
	Catch
		return Null
	End try
