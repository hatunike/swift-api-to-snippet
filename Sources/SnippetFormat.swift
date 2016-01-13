class SnippetFormat {

	class func paramSnippet(param:String, paramNum:Int) -> String {
		
		if paramNum == 1 {
			return "\(SublimeSnippet.harvestParamExternalName(param, isFirstParam:true))${\(paramNum):\(SublimeSnippet.harvestParamType(param))}"
		} else {
			return "\(SublimeSnippet.harvestParamExternalName(param, isFirstParam:false))${\(paramNum):\(SublimeSnippet.harvestParamType(param))}"
		}
	}

	class func snippetClassFileName(name:String) -> String {

		return SnippetFormat.snippetFileName(with: "class", name:name)
	}

	class func snippetFileName(with type:String, name:String) -> String {

		return "\(name.stringByReplacingOccurrencesOfString("<", withString: "").stringByReplacingOccurrencesOfString(">", withString: "")).sublime-snippet"
	}

	class func snippet() -> (start:String, end:String) {
		
		return ("<snippet>\n", "</snippet>")
	}

	class func content() -> (start:String, end:String) {
		
		return ("\t<content><![CDATA[\n", "]]></content>\n")
	}

	class func tabTrigger(trigger:String) -> String {
		
		return "\t<tabTrigger>\(trigger)</tabTrigger>\n"
	}

	class func scope() -> String {
		
		return "\t<scope>source.swift</scope>"
	}
	
	class func descriptionText(descriptiveText:String) -> String {
		
		return "\t<description>\(descriptiveText)</description>"
	}
}