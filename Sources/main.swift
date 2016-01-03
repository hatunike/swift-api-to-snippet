import Foundation

let filemanager = NSFileManager.defaultManager()
let sourcePath:String = Process.arguments[1]

if Process.arguments.count == 1 {
    print("use \".build/debug/SwiftAPIToSnippet sourceDirectory outputDirectory\"")
} else if Process.arguments.count == 2 {
    print("parsing sourceDirectory, writing to snippets folder")
    print("-optionally pass in an outputDirectory-")
    let path = NSFileManager.defaultManager().currentDirectoryPath
    let enumerator:NSDirectoryEnumerator = filemanager.enumeratorAtPath(sourcePath)!
    let swiftFiles = enumerator.allObjects.filter(){ $0.pathExtension == "swift" }

    SublimeSnippet.processSwiftFiles(swiftFiles as! [String], sourcePath:sourcePath, outputPath:"\(path)/snippets/")
    
} else if Process.arguments.count == 3 {
    print("parsing sourceDirectory, writing to outputDirectory")
} else {
    print("No directory given")
}









