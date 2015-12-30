# Swift API To Snippet
A command line tool for parsing swift files in a directory and outputting autocompletion snippets

## Getting Started

`swift build`

`.build/debug/SwiftAPIToSnippet /Path/To/SwiftFolder/`

Optionally,

`.build/debug/SwiftAPIToSnippet /Path/To/SwiftFolder/ Path/To/DesiredOutputFolder`

The tool finds all .swift files in the given directory, it then parses the files, generating snippet files for all public facing api's.

The snippets can then be added to Sublime Text's package folder for autocompletion. This utility has been used to parse the [Swift Foundation Framework](https://github.com/apple/swift-corelibs-foundation) and create a [Sublime Text plugin for autocompletion](https://github.com/hatunike/Swift-Foundation-Sublime-Autocomplete-Package) 

## Public API
Only public api's are converted to Snippets.

### Methods (Class, Static, Instance, Initializer)

public class & static methods will be translated into a snippet like :

    <snippet>
        <content><![CDATA[
    NSCalendar.currentCalendar(${1:})]]></content>
        <tabTrigger>NSCalendar.currentCalendar</tabTrigger>
        <scope>source.swift</scope> <description>class NSCalendar -> NSCalendar</description></snippet>
 
where description shows the class, struct, or enum that the method belongs to as well as the return type of the method. Parameters are tabbed for easy autocompletion.

public instance methods will be translated into a snippet like :

    <snippet>
        <content><![CDATA[
    containsString(${1:String})]]></content>
        <tabTrigger>containsString</tabTrigger>
        <scope>source.swift</scope> <description>func NSString -> Bool</description></snippet>

where description shows the class, struct or enum that the method belongs to as well as the return type of the method. Parameters are tabbed for easy autocompletion. Placeholder text is the expected type.

public initializers will be translated into a snippet like :

    <snippet>
        <content><![CDATA[
    NSAttributedString(string:${1:String}, attributes:${2:[String })]]></content>
        <tabTrigger>NSAttributedString</tabTrigger>
        <scope>source.swift</scope> <description>string: attributes:</description></snippet>

where description shows the parameters of the initializers. 

### Declarations (Class, Struct, Enum)

public declarations will be translated into a snippet like :  

    <snippet>
        <content><![CDATA[
    NSDate
    ]]></content>
        <tabTrigger>NSDate</tabTrigger>
        <scope>source.swift</scope>
        <description></description>
    </snippet>

### Properties (Variable, Constant)

public properties will be translated into a snippet like :

    <snippet>
        <content><![CDATA[
    count
    ]]></content>
        <tabTrigger>count</tabTrigger>
        <scope>source.swift</scope> <description>Int</description></snippet>

Where description here refers to the type of the property.


##Version 1.0 Roadmap


