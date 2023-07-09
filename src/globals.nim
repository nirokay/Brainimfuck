import ./tokens, ./memorytape, ./loopstack
export tokens, memorytape, loopstack

# Instructions: ---------------------------------------------------------------

var
    programInstructions*: seq[Token]
    instructionPointer* {.global.}: int64

    printStatsAfterExecution*: bool
    printDebugInformation*: bool
    runWithoutChecks*: bool
