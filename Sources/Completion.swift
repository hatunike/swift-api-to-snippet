class Completion {

	class func createCompletionFile(filename:String, snippets:Set<Snippet>, sourcePath:String, outputPath:String) {
    	File.save("\(outputPath)/\(filename).sublime-completions", Completion.completionSnippet(snippets))
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

								comp = comp + SnippetFormat.paramSnippet(param, paramNum:index)

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
}