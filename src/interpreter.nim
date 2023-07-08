import std/[tables, terminal]
import ./globals, ./tokens, ./memorytape

var tape = Tape()


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

    of loopBracketBegin: loopStack.add(instructionPointer - 1)
    of loopBracketEnd:
        if tape.readValue() != 0: instructionPointer = loopStack.pop()
        else: discard loopStack.pop()

    of inputChar: handleUserInput()
    of outputChar: stdout.write tape.readValue().char()



proc executeProgram*() =
    ## Executes a set of instructions.
    var executionCicles: int    
    while instructionPointer <= programInstructions.len() - 1:
        let instruction: Token = programInstructions[instructionPointer]
        
        if printDebugInformation:
            echo "---- Cicle " & $executionCicles & " ---- "
            echo "Instruction ID: " & $instructionPointer & "\tInstruction: " & $instruction & "\tLoop stack: " & $loopStack
            echo tape.table

        instruction.executeInstruction()

        instructionPointer.inc()
        executionCicles.inc()

