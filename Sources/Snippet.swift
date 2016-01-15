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



















