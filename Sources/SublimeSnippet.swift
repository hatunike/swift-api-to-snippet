import Foundation

public class SublimeSnippet {
	class func createSnippetText(with inputText:String, textDescription:String = "") -> String {
		return "\(SnippetFormat.snippet().start)" +
				"\(SnippetFormat.content().start)" +
				"\(inputText)\n" +
				"\(SnippetFormat.content().end)" +
				"\(SnippetFormat.tabTrigger(inputText))" +
				"\(SnippetFormat.scope())" + 
				"\(SnippetFormat.descriptionText(textDescription))" +
				"\(SnippetFormat.snippet().end)"				
	}

	class func createFuncSnippetText(with name:String, parameters:[String], returnType:String) -> String {
		var snippet = "\(SnippetFormat.snippet().start)" +
					  "\(SnippetFormat.content().start)" +
					  "\(name.escapeGreaterThanLessThan().removeParenthesis())("
		if parameters.count == 0 {
			snippet = snippet + ")"
		} else {
			for index in 1...parameters.count {
				let param = parameters[index-1]

				snippet = snippet + SnippetFormat.paramSnippet(param, paramNum:index)

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

		snippet = snippet + "\(SnippetFormat.content().end)" +
				"\(SnippetFormat.tabTrigger(name.removeGreaterThanLessThan()))" +
				"\(SnippetFormat.scope())" + 
				"\(SnippetFormat.descriptionText(returnType))" +
				"\(SnippetFormat.snippet().end)"

		return snippet
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
}

// Mark: Text Snippets



