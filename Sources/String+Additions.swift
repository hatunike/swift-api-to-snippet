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