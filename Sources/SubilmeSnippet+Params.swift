extension SublimeSnippet {
	public class func harvestParamExternalName(sourceString:String, isFirstParam:Bool) -> String {

		let cleaned = sourceString.removeParenthesis().removeColons()

		if isFirstParam == true {
			let params = cleaned.componentsSeparatedByString(" ")
			if params.count == 3 {
				return params[0] + ":"
			}
			else {
				return ""
			}
		}

		if cleaned.contains(" ") {
			return cleaned.componentsSeparatedByString(" ")[0] + ":"
		} else {
			return cleaned + ":"
		}
	}

	public class func harvestParamType(sourceString:String) -> String {
		if (sourceString.contains(": ")) {
			return sourceString.componentsSeparatedByString(": ")[1].removeParenthesis() 
		}else {
			return ""
		}
	}
}