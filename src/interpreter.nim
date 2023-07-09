import std/[strformat, tables, terminal, times]
import ./globals, ./tokens, ./memorytape, ./error, ./loopstack as loopstack_file

var
    tape = Tape()
    loopStack = LoopStack()

# -----------------------------------------------------------------------------
# Syntax Checks:
# -----------------------------------------------------------------------------

proc checkProgramSyntax*(): bool =
    ## Checks program syntax for errors. Returns `true` if no errors have been found
    var
        instructionPosition: int
        bracketStack: seq[int]
        errorPositions: seq[int]
    
    proc warn(position: int, msg: string) =
        errorSyntax.warn(&"*Position {position}*:\t" & msg & "\n")

    for token in programInstructions:
        var error: bool

        # Bracket counting:
        if token == loopBracketBegin:
            bracketStack.add(instructionPosition)
        if token == loopBracketEnd:
            try:
                discard bracketStack.pop()
            except IndexDefect:
                warn(instructionPosition, &"Closing bracket without corresponding opening one!")
                error = true

        # Remember error position and loop over again:
        if error:
            errorPositions.add(instructionPosition)
            result = true
        instructionPosition.inc()
    
    # Warn about lone opening brackets:
    for error in bracketStack:
        errorPositions.add(error)
        warn(error, &"Opening bracket without corresponding closing one! Forgot to close?")

    # Display source with highlighting or exit if no errors found:
    if errorPositions.len() == 0: return false

    var
        instructions: string = programInstructions.convertToString()
        lastError: int

    stderr.styledWriteLine styleUnderscore, "Error trace:"

    for error in errorPositions:
        # Print good code:
        if error != lastError + 1 and error != 0:
            stderr.styledWrite fgDefault, instructions[lastError + 1 .. error - 1]

        # Print naughty code:
        stderr.styledWrite fgRed, $instructions[error], fgDefault
        lastError = error
    if lastError != instructions.len() - 1:
        stderr.styledWrite fgDefault, instructions[lastError + 1 .. ^1]
    stderr.write "\n"



# -----------------------------------------------------------------------------
# Execution stuff:
# -----------------------------------------------------------------------------

proc handleUserInput() =
    if printDebugInformation:
        stdout.writeLine "\nEnter a character as input: "
        stdout.flushFile()

    tape.writeValue(uint8 getch())

    if printDebugInformation:
        stdout.write "\n"
        stdout.flushFile()


proc executeInstruction*(instruction: Token) =
    ## Executes a single instruction.
    case instruction:
    of moveTapePointerLeft: tape.moveLeft()
    of moveTapePointerRight: tape.moveRight()

    of increaseTapeData: tape.increaseCurrentCell()
    of decreaseTapeData: tape.decreaseCurrentCell()

    of loopBracketBegin:
        if tape.readValue() == 0: instructionPointer.jumpForwards(loopStack)

    of loopBracketEnd:
        if tape.readValue() != 0: instructionPointer.jumpBackwards(loopStack)

    of inputChar: handleUserInput()
    of outputChar: stdout.write tape.readValue().char()

    of noOperation: discard


proc executeProgram*() =
    ## Executes a set of instructions.
    let timeInitExecutionBegin: Time = getTime()
    var executionCicles: int
    programInstructions.add(noOperation)

    # Put all brackets into "stack":
    try:
        loopStack.add(programInstructions)
    except CatchableError, Defect:
        errorSyntax.panic("Invalid amount of brackets found, run in safe mode to see more details! Error:\n" & getCurrentExceptionMsg())

    let timeRunningBegin: Time = getTime()
    try:
        while instructionPointer <= programInstructions.len() - 1:
            let instruction: Token = programInstructions[instructionPointer]
            
            if printDebugInformation:
                echo "---- Cicle " & $executionCicles & " ---- "
                echo "Instruction ID: " & $instructionPointer & "\tInstruction: " & $instruction & "\tLoop stack: " & $loopStack.stack
                echo "Tape pointer: " & $tape.pointerPosition & "\nCurrent tape value: " & $tape.readValue()
                echo "Tape: " & $tape.table

            instruction.executeInstruction()

            instructionPointer.inc()
            executionCicles.inc()
    except CatchableError, Defect:
        let instructions: string = programInstructions.convertToString()
        stderr.styledWriteLine fgDefault, styleUnderscore, "\nTraceback:"
        # Print beginning good code:
        if instructionPointer != 0:
            if instructionPointer == 1:
                stderr.styledWrite fgDefault, $instructions[0]
            else:
                stderr.styledWrite fgDefault, $instructions[0..instructionPointer - 1]
        # Print naughty code:
        stderr.styledWrite fgRed, $instructions[instructionPointer], fgDefault

        # Print ending good code:
        if instructionPointer != instructions.len() - 1:
            stderr.styledWrite fgDefault, $instructions[instructionPointer + 1 .. ^1]
        stderr.write "\n\n"

        errorSyntax.panic("Runtime error, causing interpreter error: " & getCurrentExceptionMsg())
    finally:
        stdout.flushFile()

        if printStatsAfterExecution:
            stderr.write "\n"
            stderr.flushFile()

            # Execution cicles and instructions:
            stderr.styledWriteLine styleUnderscore, styleBright, "Instructions:"
            stderr.styledWriteLine "Execution cicles: " & $executionCicles & "\nInstructions: " & $(programInstructions.len() - 1)

            # Execution Time:
            let
                timeEnd:  Time     = getTime()
                execDur:  Duration = timeEnd - timeRunningBegin
                totalDur: Duration = timeEnd - timeInitExecutionBegin
                initDur:  Duration = totalDur - execDur

            stderr.styledWriteLine styleUnderscore, styleBright, "\nTimers:"
            stderr.styledWriteLine "Initialisation Time:  " & $initDur
            stderr.styledWriteLine "Execution Time:       " & $execDur
            stderr.styledWriteLine "---"
            stderr.styledWriteLine "Total time:           " & $totalDur



