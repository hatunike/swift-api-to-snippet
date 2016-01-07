import Foundation

struct Snippet {
	let name:String
	let description:String
	let paramaters:[String]
	let snippetType:SnippetType
}

enum SnippetType {
	case ClassToken
	case StructToken
	case EnumToken
	case Constant
	case Variable
	case InstanceMethod
	case InitializationMethod
	case StaticMethod
	case ClassMethod
}

public class SublimeSnippet {
	class func createSnippetText(with inputText:String, textDescription:String = "") -> String {
		return "\(SublimeSnippet.snippet().start)" +
				"\(SublimeSnippet.content().start)" +
				"\(inputText)\n" +
				"\(SublimeSnippet.content().end)" +
				"\(SublimeSnippet.tabTrigger(inputText))" +
				"\(SublimeSnippet.scope())" + 
				"\(SublimeSnippet.descriptionText(textDescription))" +
				"\(SublimeSnippet.snippet().end)"
				
	}

	class func createFuncSnippetText(with name:String, parameters:[String], returnType:String) -> String {
		//print("starting paramaters = \(parameters)")
		var snippet = "\(SublimeSnippet.snippet().start)" +
					  "\(SublimeSnippet.content().start)" +
					  "\(name.escapeGreaterThanLessThan().removeParenthesis())("
		if parameters.count == 0 {
			snippet = snippet + ")"
		} else {
			for index in 1...parameters.count {
				let param = parameters[index-1]

				snippet = snippet + SublimeSnippet.paramSnippet(param, paramNum:index)

				if index != parameters.count {
					if parameters.count != 1 {
						snippet = snippet + ", "
					} else {
						snippet = snippet + ")"
					}
				} else {
					snippet = snippet + ")"
				}
			}
		}

		snippet = snippet + "\(SublimeSnippet.content().end)" +
				"\(SublimeSnippet.tabTrigger(name.stringByReplacingOccurrencesOfString("<", withString: "").stringByReplacingOccurrencesOfString(">", withString: "")))" +
				"\(SublimeSnippet.scope())" + 
				"\(SublimeSnippet.descriptionText(returnType))" +
				"\(SublimeSnippet.snippet().end)"

		return snippet
	}

	class func completionSnippet(snippets:[Snippet]) -> String {
		var comp = "{\n" + 
						 "\"scope\": \"source.swift\",\n" +
						 "\"completions\":\n [ \n"
			 for snippet in snippets {
			 	switch snippet.snippetType {
			 		case .Constant, .Variable, .ClassToken, .EnumToken, .StructToken:
			 			comp += "{ \"trigger\": \"\(snippet.name)\", \"contents\": \"\(snippet.name)\"},"
			 		default:
			 			break

			 	}
			 }
			 comp = String(comp.characters.dropLast()) //remove unnecessary comma

			comp += "]\n }\n"

		return comp 
	}

	class func paramSnippet(param:String, paramNum:Int) -> String {
		if paramNum == 1 {
			return "\(SublimeSnippet.harvestParamExternalName(param, isFirstParam:true))${\(paramNum):\(SublimeSnippet.harvestParamType(param))}"
		} else {
			return "\(SublimeSnippet.harvestParamExternalName(param, isFirstParam:false))${\(paramNum):\(SublimeSnippet.harvestParamType(param))}"
		}
	}

	class func snippetClassFileName(name:String) -> String{
		return SublimeSnippet.snippetFileName(with: "class", name:name)
	}

	class func snippetFileName(with type:String, name:String) -> String{
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

	class func processSwiftFiles(files:[String], sourcePath:String, outputPath:String) {
        for swiftFile in files {
            let fullFilePath = "\(sourcePath)/\(swiftFile)"
            if let fileTxt = File.open(fullFilePath) {
                let blocks = fileTxt.parsePrimaryCodeBlocks()
                for (name, code) in blocks {
                    //print("processing \(name) : \(fullFilePath)")

                    for token in fileTxt.classTokens() {
                        let fileName = File.filePathForNewFile(outputPath, fileName:token)
                        File.save(fileName, SublimeSnippet.createSnippetText(with:token))
                    }

                    for token in fileTxt.enumTokens() {
                        let fileName = "\(outputPath)/\(SublimeSnippet.snippetClassFileName(token).removeUnsafeSublimeTextCharacters())"
                        File.save(fileName, SublimeSnippet.createSnippetText(with:token))
                    }

                    for token in fileTxt.structTokens() {
                        let fileName = "\(outputPath)/\(SublimeSnippet.snippetClassFileName(token).removeUnsafeSublimeTextCharacters())"
                        File.save(fileName, SublimeSnippet.createSnippetText(with:token))
                    }

                    for (key, value) in fileTxt.variableTokens() {
                        let fileName = "\(outputPath)/\(SublimeSnippet.snippetClassFileName(key).removeUnsafeSublimeTextCharacters())"
                        File.save(fileName, SublimeSnippet.createSnippetText(with:key, textDescription:value))
                    }

                    for (key, value) in fileTxt.constantTokens() {
                        let fileName = "\(outputPath)/\(SublimeSnippet.snippetClassFileName(key).removeUnsafeSublimeTextCharacters())"
                        File.save(fileName, SublimeSnippet.createSnippetText(with:key, textDescription:value))
                    }

                    for funcData:FuncData in code.memberFuncParserTokens() {
                        let fileName = "\(outputPath)/\(SublimeSnippet.snippetClassFileName("\(name)-\(funcData.name.removeUnsafeSublimeTextCharacters())"))"
                        File.save(fileName, SublimeSnippet.createFuncSnippetText(with:funcData.name, parameters:funcData.params, returnType:"func \(name) -> \(funcData.returnType)"))          
                    }

                    for funcData:FuncData in code.classFuncTokens() {
                        let fileName = "\(outputPath)/\(SublimeSnippet.snippetClassFileName("\(name)-\(funcData.name.removeUnsafeSublimeTextCharacters())"))"
                        File.save(fileName, SublimeSnippet.createFuncSnippetText(with:"\(name).\(funcData.name)", parameters:funcData.params, returnType:"class \(name) -> \(funcData.returnType)"))          
                    }

                    for funcData:FuncData in code.staticFuncTokens() {
                        let fileName = "\(outputPath)/\(SublimeSnippet.snippetClassFileName("\(name)-\(funcData.name.removeUnsafeSublimeTextCharacters())"))"
                        File.save(fileName, SublimeSnippet.createFuncSnippetText(with:"\(name).\(funcData.name)", parameters:funcData.params, returnType:"static \(name) -> \(funcData.returnType)"))          
                    }

                    for funcData:FuncData in code.initializerTokens() {
                        let unsafeChars = NSCharacterSet.alphanumericCharacterSet().invertedSet
                        let paramIdentifer = funcData.params.joinWithSeparator("-").componentsSeparatedByCharactersInSet(unsafeChars).joinWithSeparator("")
                        let descriptionIdentifier = funcData.params.map({param in "\(SublimeSnippet.harvestParamExternalName(param, isFirstParam:false))"}).joinWithSeparator(" ")
                        let fileName = "\(outputPath)/\(SublimeSnippet.snippetClassFileName("\(name)-\(funcData.name.removeUnsafeSublimeTextCharacters())-\(paramIdentifer.removeUnsafeSublimeTextCharacters())"))"
                        File.save(fileName, SublimeSnippet.createFuncSnippetText(with:"\(name)", parameters:funcData.params, returnType:"\(descriptionIdentifier)"))         
                    }

                }
            } else {
                print("failed to open file \(swiftFile)")
            }
        }
    }

    class func convertSwiftFilesToSnippets(files:[String], sourcePath:String, outputPath:String) -> [Snippet] {
    	return []
    }

    class func createCompletionFile(snippets:[Snippet], sourcePath:String, outputPath:String) {

    }
}

extension String {

    func contains(find: String) -> Bool{
       return self.rangeOfString(find) != nil
     }

    func removeParenthesis() -> String {
		return self.stringByReplacingOccurrencesOfString("(", withString:"").stringByReplacingOccurrencesOfString(")", withString:"")
	}

	func removeColons() ->String {
		return self.stringByReplacingOccurrencesOfString(":", withString:"")
	}

	func escapeGreaterThanLessThan() -> String {
		return self.stringByReplacingOccurrencesOfString("<", withString:"\\<").stringByReplacingOccurrencesOfString(">", withString:"\\>")
	}

	public func removeUnsafeSublimeTextCharacters() -> String {
		return self.stringByReplacingOccurrencesOfString("*", withString:"pointer").stringByReplacingOccurrencesOfString(".", withString:"-").stringByReplacingOccurrencesOfString("=", withString:"equals").stringByReplacingOccurrencesOfString("+", withString:"plus").stringByReplacingOccurrencesOfString("/", withString:"slash").stringByReplacingOccurrencesOfString("_", withString:"-")
	}
}