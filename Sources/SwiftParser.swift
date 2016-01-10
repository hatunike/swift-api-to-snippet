import Foundation

extension NSRegularExpression {
	class func matchesForRegexInText(regex: String!, text: String!) -> [String] {
	    do {
	        let regex = try NSRegularExpression(pattern: regex, options: [])
	        let nsString = text as NSString
	        let results = regex.matchesInString(text,
	            options: [], range: NSMakeRange(0, nsString.length))
	        return results.map { nsString.substringWithRange($0.range)}
	    } catch let error as NSError {
	        print("invalid regex: \(error.localizedDescription)")
	        return []
	    }
	}
}

struct FuncData {
	var name:String
	var params:[String]
	var returnType:String
}

extension String {
	//Constucts
	func classTokens() -> [String] {
		return Array(self.constructTokens("public class"))
	}

	func enumTokens() -> [String] {
		return Array(self.constructTokens("public enum"))
	}

	func structTokens() -> [String] {
		return Array(self.constructTokens("public struct"))
	}

	func extensionTokens() -> [String] {
		return Array(self.constructTokens("extension"))
	}

	func constructTokens(preIdentifer:String) -> Set<String> {
		let rawTokens = NSRegularExpression.matchesForRegexInText("\(preIdentifer) [A-Z]+[a-z || A-Z]*", text: self)
		var returnSet = Set<String>()
		for token in rawTokens {
			returnSet.insert(token.characters.split{$0 == " "}.map(String.init)[preIdentifer.componentsSeparatedByString(" ").count])
		}
		print("tokens - \(returnSet)")

		return returnSet
	}

	//Properties
	func variableTokens() -> [(String, String)] {
		return self.propertyFuncTokens("public var")
	}

	func constantTokens() -> [(String, String)] {
		return self.propertyFuncTokens("public let")
	}

	func propertyFuncTokens(preIdentifier:String) -> [(String, String)] {
		let rawTokens = NSRegularExpression.matchesForRegexInText("\(preIdentifier) +[a-z || A-Z]*((: {1}[A-Z][a-z||A-Z]*))", text: self)
		var returnArray = [(String,String)]()
		for token in rawTokens {
			let key = token.characters.split{$0 == " "}.map(String.init)[2].componentsSeparatedByString(":")[0]
			let value = token.characters.split{$0 == " "}.map(String.init)[3]

			returnArray.append((key, value))
		}
		return returnArray
	}
	
	//Methods
	
	func memberFuncParserTokens() -> [FuncData] {
		return self.funcParserTokens("public func")
	}

	func classFuncTokens() -> [FuncData] {
		return self.funcParserTokens("public class func")
	}

	func staticFuncTokens() -> [FuncData] {
		return self.funcParserTokens("public static func")
	}

	func funcParserTokens(funcIdentifier:String) -> [FuncData] {
		let rawTokens:[String] = NSRegularExpression.matchesForRegexInText("\(funcIdentifier) .*\\{", text: self)
		var returnArray = [FuncData]()

		for token in rawTokens {
			let name: String = token.characters.split{$0 == " "}.map(String.init)[funcIdentifier.componentsSeparatedByString(" ").count].componentsSeparatedByString("(")[0]
			let arguments: [String] = NSRegularExpression.matchesForRegexInText("\\(.*\\)", text:token)[0].componentsSeparatedByString(", ")
			let returnTypes = NSRegularExpression.matchesForRegexInText("->.*\\{", text:token)
			var returnType = "void"
			if returnTypes.count > 0 {
				returnType = returnTypes[0].characters.split{$0 == " "}.map(String.init)[1].stringByReplacingOccurrencesOfString("<", withString: " ").stringByReplacingOccurrencesOfString(">", withString: " ")
			} 
			returnArray.append(FuncData(name:name, params:arguments, returnType:returnType))
		}

		return returnArray
	}

	func initializerTokens() -> [FuncData] {
		var initers = [FuncData]()
		initers += self.initParserTokens("public")
		initers += self.initParserTokens("public convenience")
		initers += self.initParserTokens("public required")
		initers += self.initParserTokens("public required convenience")
		initers += self.initParserTokens("public override")
		initers += self.initParserTokens("public convenience override")
		initers += self.initParserTokens("public required override")
		initers += self.initParserTokens("public required convenience override")
		return initers
	}

	func initParserTokens(initIdentifier:String) -> [FuncData] {
		let rawTokens:[String] = NSRegularExpression.matchesForRegexInText("\(initIdentifier) init.*\\{", text: self)
		var returnArray = [FuncData]()

		for token in rawTokens {
			let name = "\(initIdentifier.stringByReplacingOccurrencesOfString(" ", withString: "-"))-init"
			let arguments: [String] = NSRegularExpression.matchesForRegexInText("\\(.*\\)", text:token)[0].componentsSeparatedByString(", ")
			let returnType = "InstanceType"

			returnArray.append(FuncData(name:name, params:arguments, returnType:returnType))
		}

		return returnArray
	}
	
	func parsePrimaryCodeBlocks() -> [(name:String, code:String)] {
		let eachLetter = self.characters
		var currentBlock:String = ""
		var blocks = [(name:String, code:String)]()
		var curlies = 0
		for character in  eachLetter {
			currentBlock = currentBlock + String(character)
			if character == "{" {
				curlies += 1
			} else if character == "}" {
				curlies -= 1
				if curlies == 0 {
					blocks.append((name:currentBlock.harvestStructClassOrEnum(), code:currentBlock))
					currentBlock = ""
				}
			}
		}
		return blocks
	}

	func harvestStructClassOrEnum() -> String {
		var tokens = [String]()
		tokens += self.classTokens()
		tokens += self.enumTokens()
		tokens += self.structTokens()
		tokens += self.extensionTokens()
		if let returnString = tokens.last {
			return returnString
		}
		return "unknown"
	}

}