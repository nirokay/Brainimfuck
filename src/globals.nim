#import std/tables
import ./tokens, ./memorytape
export tokens, memorytape

# Instructions: ---------------------------------------------------------------

var
    programInstructions*: seq[Token]
    instructionPointer*: int64
    loopStack*: seq[int64]

    printStatsAfterExecution*: bool
    printDebugInformation*: bool
    runWithoutChecks*: bool
