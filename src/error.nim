import std/[terminal]

type ErrorType* = enum
    errorNoSourceFileGiven = "No source/input file has been declared."
    errorNoSourceFileFound = "No source/input file with that name exits."
    errorCannotOpenSourceFile = "Source/Input file cannot be read."
    errorTrailingBracket = "Syntax error: Trailing bracket found in source."

proc panic*(error: ErrorType, msg: string = "") =
    ## *Handles** an error by panicing!
    stderr.styledWriteLine fgRed, styleUnderscore, "Runtime Panic", resetStyle, fgDefault
    stderr.writeLine msg
    # stderr.styledWriteLine 
