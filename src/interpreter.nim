import std/[strformat, tables, terminal]
import ./globals, ./tokens, ./memorytape, ./error

var tape = Tape()

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
        if tape.readValue() == 0:
            loopStack.add(instructionPointer - 1)
        else:
            var index: int64 = instructionPointer
            while programInstructions[index] != loopBracketEnd:
                index.inc()
            instructionPointer = index

    of loopBracketEnd:
        if tape.readValue() != 0: instructionPointer = loopStack.pop()
        else: discard loopStack.pop()

    of inputChar: handleUserInput()
    of outputChar: stdout.write tape.readValue().char()

    of noOperation: discard


proc executeProgram*() =
    ## Executes a set of instructions.
    var executionCicles: int    
    
    programInstructions.add(noOperation)
    try:
        while instructionPointer <= programInstructions.len() - 1:
            let instruction: Token = programInstructions[instructionPointer]
            
            if printDebugInformation:
                echo "---- Cicle " & $executionCicles & " ---- "
                echo "Instruction ID: " & $instructionPointer & "\tInstruction: " & $instruction & "\tLoop stack: " & $loopStack
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


