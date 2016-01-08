import Foundation

class File {
    class func open(path: String, utf8: NSStringEncoding = NSUTF8StringEncoding) -> String? {
        do {
             return try NSFileManager().fileExistsAtPath(path) ? String(contentsOfFile: path, encoding: utf8) : "file doesn't exist at \(path)"
        } catch _ {
            return "failed to load file"
        }
    }

	class func save(path: String, _ content: String, utf8: NSStringEncoding = NSUTF8StringEncoding) -> Bool {
        do {
             try content.writeToFile(path, atomically: true, encoding: utf8)
             //print("Wrote to file \(path)")
             return true
        } catch _ {
        	print("Failed to write to \(path)")
            return false
        } 
    }

    class func filePathForNewFile(basePath:String, fileName:String) -> String {
        return "\(basePath)/\(SublimeSnippet.snippetClassFileName(fileName).removeUnsafeSublimeTextCharacters())"
    }

    class func filePathForCompletionFile(basePath:String) -> String {
        return "\(basePath)/Testing.snippet-completion"
    }

}
