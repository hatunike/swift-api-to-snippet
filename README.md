# Swift API to Sublime-Completion
A command line tool for parsing swift files in a directory and outputting a `.sublime-completions` file. This json file can then be used by Sublime Text to give completion suggestions.

![Alt text](/sample-images/stringByReplacing.png)

(This is an example of the completion file in action. The completion file here was generated from the open source swift foundation framework)


## Getting Started

`swift build`

`.build/debug/SwiftAPIToSnippet sourcePath`

`sourcePath` here means the absolute url to the folder containing all the `.swift` files that will be processed. Currently only public api will be included in the completion file (see the roadmap below). 

Optionally, you may pass in an outputPath as the 2nd parameter:

`.build/debug/SwiftAPIToSnippet sourcePath outputPath`

The `.sublime-completions` file is similar to the `.sublime-snippet`, but they are different in key ways. The completion file is .json structure intended for facilitating a large number of completions. While the snippet is for a single snippet. The intention is to support outputing both types of files. Currently only `.sublime-completions` are supported.

The completion file will be output to either the "snippets" folder in the project or in the output path provided. This file can then be added to a Sublime Text's package folder. Now you have completion snippets. This utility has been used to parse the [Swift Foundation Framework](https://github.com/apple/swift-corelibs-foundation) and create a [Sublime Text plugin for completion](https://github.com/hatunike/Swift-Foundation-Sublime-Autocomplete-Package) 


### General Format

The completion file generated will look something like this :

    {
      "scope": "source.swift",
      "completions": [
      //tons of trigger/contents for Methods, Declarations & Properties
      ]
    }


### Methods (Class, Static, Instance, Initializer)

public class & static methods will be translated into a snippet like :

    {
      "trigger": "NSURL.fileURLWithPathComponents \t class NSURL -> NSURL?",
      "contents": "NSURL.fileURLWithPathComponents(${1:[String]})"
    }
 
the `trigger` includes the keys for triggering the completion. The `\t` is what determines the hint field in Sublime Text's completion window. Here it shows the class, struct, or enum that the method belongs to as well as the return type of the method. Parameters are tabbed for for ease.

public instance methods will be translated into a snippet like :

    {
      "trigger": "containsString \t func NSString -> Bool",
      "contents": "containsString(${1:String})"
    },

where `\t` shows the class, struct or enum that the method belongs to as well as the return type of the method. Parameters are tabbed for easy autocompletion. Placeholder text is the expected type.

public initializers will be translated into a snippet like :

    {
      "trigger": "NSAttributedString \t string: attributes:",
      "contents": "NSAttributedString(string:${1:String}, attributes:${2:[String })"
    }

where `\t` shows the parameters of the initializers. 

### Declarations (Class, Struct, Enum)

public declarations will be translated into a snippet like :  

    {
      "trigger": "NSDate \t NSDate",
      "contents": "NSDate"
    },

### Properties (Variable, Constant)

public properties will be translated into a snippet like :

    {
      "trigger": "count \t Int",
      "contents": "count"
    }

Where `\t` here refers to the type of the property.


##Version 1.0 Roadmap

* Add .sublime-completion files to be default output (done)
* Add option for specifying .sublime-snippet output format
* Add option for exlusion / inclusion of completion types
* Add option for specifying editor type (Sublime Text, Atom, Textmate, etc)
* Add visual progress indication for processing
* Add Unit Tests for each type of snippet/completion file
* Consider renaming project name
* parse public/private api's for current repository


