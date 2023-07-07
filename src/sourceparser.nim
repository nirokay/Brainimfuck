import std/[os]
import ./globals, ./tokens, ./error

proc parseSourceString*(rawString: string): seq[Token] = 
    return rawString.convertToTokens()

proc parseSourceFile*(filepath: string): seq[Token] =
    var fileContent: string
    if not filepath.fileExists():
        errorNoSourceFileFound.panic()
    
    try:
        fileContent = filepath.readFile()
        return fileContent.parseSourceString()
    except IOError:
        errorCannotOpenSourceFile.panic("Could not read file!")
