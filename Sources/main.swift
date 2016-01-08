import Foundation

let filemanager = NSFileManager.defaultManager()
let sourcePath:String = Process.arguments[1]
let dashedArguments = Process.arguments.filter({$0.hasPrefix("-")}) as [NSString]

if Process.arguments.count == 1 {
    print("use \".build/debug/SwiftAPIToSnippet sourceDirectory outputDirectory\"")
} else if Process.arguments.count == 2 {
    print("parsing sourceDirectory, writing to snippets folder")
    print("-optionally pass in an outputDirectory-")
    let path = NSFileManager.defaultManager().currentDirectoryPath
    let enumerator:NSDirectoryEnumerator = filemanager.enumeratorAtPath(sourcePath)!
    let swiftFiles = enumerator.allObjects.filter(){ $0.pathExtension == "swift" }

    //comment out to stop snippet files
    SublimeSnippet.processSwiftFiles(swiftFiles as! [String], sourcePath:sourcePath, outputPath:"\(path)/snippets/")
    
    /* uncomment to create a single completion file (not finished)
    let snippets = SublimeSnippet.convertSwiftFilesToSnippets(swiftFiles as! [String], sourcePath:sourcePath, outputPath:"\(path)/snippets/")
    SublimeSnippet.createCompletionFile(snippets, sourcePath:sourcePath, outputPath:"\(path)/snippets/")
    */

} else if Process.arguments.count >= 3 {
    print("parsing sourceDirectory, writing to outputDirectory")
    let outputPath = Process.arguments[2]
    let enumerator:NSDirectoryEnumerator = filemanager.enumeratorAtPath(sourcePath)!
    let swiftFiles = enumerator.allObjects.filter(){ $0.pathExtension == "swift" }

    SublimeSnippet.processSwiftFiles(swiftFiles as! [String], sourcePath:sourcePath, outputPath:outputPath)
   
} else {
    print("No directory given")
}






















