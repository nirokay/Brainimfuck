import std/tables
import ./tokens

type LoopStack* = object
    stack*: Table[int64, int64]

using
    stack: var LoopStack
    instructionPointer: var int64

proc add*(stack; instructions: seq[Token]) =
    var tempStack: seq[int64]
    for index, instruction in instructions:
        if instruction notin @[loopBracketBegin, loopBracketEnd]: continue
        if instruction == loopBracketBegin:
            tempStack.add(index)
        if instruction == loopBracketEnd:
            stack.stack[tempStack.pop()] = index


proc jumpForwards*(instructionPointer, stack) =
    instructionPointer = stack.stack[instructionPointer]


proc jumpBackwards*(instructionPointer, stack) =
    for beginning, ending in stack.stack:
        if ending == instructionPointer:
            instructionPointer = beginning
