import Foundation

struct Snippet : Hashable {
	let name:String
	let description:String
	let parameters:[String]
	let snippetType:SnippetType
	var hashValue: Int {
      return "\(name) \(description) \(parameters)".hashValue
  	}	
}

func ==(lhs: Snippet, rhs: Snippet) -> Bool {
  return lhs.hashValue == rhs.hashValue
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

	class func completionSnippet(snippets:Set<Snippet>) -> String {
		var comp = "{\n" + 
						 "\"scope\": \"source.swift\",\n" +
						 "\"completions\":\n [ \n"
			 for snippet in snippets {
			 	switch snippet.snippetType {
			 		case .Constant, .Variable, .ClassToken, .EnumToken, .StructToken:
			 			comp += "{ \"trigger\": \"\(snippet.name.removeParenthesis()) \\t \(snippet.description.removeParenthesis())\", \"contents\": \"\(snippet.name)\" },"
			 		case .InstanceMethod, .ClassMethod, .StaticMethod, .InitializationMethod:
			 			comp += "{ \"trigger\": \"\(snippet.name.removeGreaterThanLessThan().removeParenthesis())"
			 			comp += " \\t \(snippet.description.removeParenthesis())\" ,"
			 			comp += " \"contents\": \"\(snippet.name.removeGreaterThanLessThan().removeParenthesis())("
			 			if snippet.parameters.count == 0 {
							comp = comp + ")\" },"
						} else {
							for index in 1...snippet.parameters.count {
								let param = snippet.parameters[index-1]

								comp = comp + SublimeSnippet.paramSnippet(param, paramNum:index)

								if index != snippet.parameters.count {
									if snippet.parameters.count != 1 {
										comp = comp + ", "
									} else {
										//comp = comp + ""
									}
								} else {
									comp = comp + ")\" },"
								}
							}
						}
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

	class func snippetClassFileName(name:String) -> String {

		return SublimeSnippet.snippetFileName(with: "class", name:name)
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

    class func convertSwiftFilesToSnippets(files:[String], sourcePath:String, outputPath:String) -> Set<Snippet> {
    	var snippets = Set<Snippet>()

    	for swiftFile in files {
            let fullFilePath = "\(sourcePath)/\(swiftFile)"
            if let fileTxt = File.open(fullFilePath) {
                let blocks = fileTxt.parsePrimaryCodeBlocks()
                for (name, code) in blocks {
                	
                	for token in fileTxt.classTokens() {
                		let snip = Snippet(name:token, description:token, parameters:[], snippetType:.ClassToken)
              			snippets.insert(snip)
                    }
                    
                    for token in fileTxt.enumTokens() {
                        let snip = Snippet(name:token, description:token, parameters:[], snippetType:.EnumToken)
              			snippets.insert(snip)
                    }

                    for token in fileTxt.structTokens() {
                        let snip = Snippet(name:token, description:token, parameters:[], snippetType:.StructToken)
              			snippets.insert(snip)
                    }
					
                    for (key, value) in fileTxt.variableTokens() {
                        let snip = Snippet(name:key, description:value, parameters:[], snippetType:.Variable)
              			snippets.insert(snip)
                    }

                    for (key, value) in fileTxt.constantTokens() {
                        let snip = Snippet(name:key, description:value, parameters:[], snippetType:.Constant)
              			snippets.insert(snip)
                    }

                    for funcData:FuncData in code.memberFuncParserTokens() {

                    	let snip = Snippet(name:funcData.name, description:"func \(name) -> \(funcData.returnType)", parameters:funcData.params, snippetType:.InstanceMethod)
              			snippets.insert(snip)         
                    }

                    for funcData:FuncData in code.classFuncTokens() {
                    	let snip = Snippet(name:"\(name).\(funcData.name)", description:"class \(name) -> \(funcData.returnType)", parameters:funcData.params, snippetType:.ClassMethod)
              			snippets.insert(snip)          
                    }
                      
                    for funcData:FuncData in code.staticFuncTokens() {
                    	let snip = Snippet(name:"\(name).\(funcData.name)", description:"static \(name) -> \(funcData.returnType)", parameters:funcData.params, snippetType:.StaticMethod)
              			snippets.insert(snip)          
                    }
					
                    for funcData:FuncData in code.initializerTokens() {
                        let descriptionIdentifier = funcData.params.map({param in "\(SublimeSnippet.harvestParamExternalName(param, isFirstParam:false))"}).joinWithSeparator(" ")
                        let snip = Snippet(name:"\(name)", description:descriptionIdentifier, parameters:funcData.params, snippetType:.InitializationMethod)
              			snippets.insert(snip)
                    } 
                }
            }
        }
    	return snippets
    }

    class func createCompletionFile(filename:String, snippets:Set<Snippet>, sourcePath:String, outputPath:String) {
    	File.save("\(outputPath)/\(filename).sublime-completions", SublimeSnippet.completionSnippet(snippets))
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
		return self.stringByReplacingOccurrencesOfString("<", withString:"\\\\<").stringByReplacingOccurrencesOfString(">", withString:"\\\\>")
	}

	func removeGreaterThanLessThan() -> String {
		return "\(self.stringByReplacingOccurrencesOfString("<", withString: "").stringByReplacingOccurrencesOfString(">", withString: "")))"
	}

	public func removeUnsafeSublimeTextCharacters() -> String {
		return self.stringByReplacingOccurrencesOfString("*", withString:"pointer").stringByReplacingOccurrencesOfString(".", withString:"-").stringByReplacingOccurrencesOfString("=", withString:"equals").stringByReplacingOccurrencesOfString("+", withString:"plus").stringByReplacingOccurrencesOfString("/", withString:"slash").stringByReplacingOccurrencesOfString("_", withString:"-")
	}
}