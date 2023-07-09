import std/[terminal]

type ErrorType* = enum
    errorNoSourceFileGiven = "No source/input file has been declared."
    errorNoSourceFileFound = "No source/input file with that name exits."
    errorCannotOpenSourceFile = "Source/Input file cannot be read."
    errorSyntax = "Syntax error."


proc warn*(error: ErrorType, msg: string = "") =
    stderr.styledWriteLine fgYellow, styleUnderscore, "Runtime Warning", resetStyle, fgDefault
    stderr.writeLine msg

proc panic*(error: ErrorType, msg: string = "") =
    ## **Handles** an error by panicing!
    stderr.styledWriteLine fgRed, styleUnderscore, "Runtime Panic", resetStyle, fgDefault
    stderr.writeLine msg
    quit(1)

