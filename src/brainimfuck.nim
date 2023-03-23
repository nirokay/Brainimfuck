import strutils, strformat, terminal, segfaults, times

# ---------------------------------------- VARIABLES ---------------------------------------- #

let charset: array[8, char] = ['+', '-', '>', '<', '[', ']', '.', ',']
var
    tapePointer: int
    instructionPointer: int
    instructionStack: seq[int]
    tape: array[30000, int]  # simulates 30.000 byte tape ( 30_000 / 8 == 3_750 )

type RuntimeError = enum
    NoLoadedProgram, TrailingBracket, InternalException


# ---------------------------------------- FUNCTIONS ---------------------------------------- #

proc runtimeException(program: string, error: RuntimeError, msg: string) =
    styledEcho fgRed, "\n'", $error, "' Runtime Exception\n", fgDefault, msg

    # Display exact position of error:
    if program.len() != 0:
        var before, problem, after: string
        problem = $program[instructionPointer]
        if instructionPointer != 0:
            before = program[0..instructionPointer-1]
        if instructionPointer != program.len() - 1:
            after = program[instructionPointer+1..program.len() - 1]
        styledEcho fgYellow, "\nBacktrace:\n",
            fgDefault, before,
            fgRed, styleBlink, problem,
            resetStyle, fgDefault, after

    quit(1)

proc getRawProgramInstructions(): string =
    var text: string = stdin.readLine().strip()
    for c in text:
        if not charset.contains(c): continue
        result.add(c)
    return result

proc run(program: string) =
    let instruction: char = program[instructionPointer]
    case instruction:
    # Cell value change:
    of '+': tape[tapePointer].inc
    of '-': tape[tapePointer].dec

    # Pointer movement:
    of '>': tapePointer.inc
    of '<': tapePointer.dec

    # I/O:
    of '.': stdout.write(tape[tapePointer].char())
    of ',':
        try:
            tape[tapePointer] = getch().int()
        except EOFError as e:
            program.runtimeException(InternalException, &"Could not read from input due to '{e.name}' ({e.msg})...")

    # Loop:
    of '[':
        instructionStack.add(instructionPointer)
    of ']':
        if instructionStack.len() == 0: program.runtimeException(TrailingBracket, "Closing bracket without matching opening one!")
        if tape[tapePointer] == 0:
            discard instructionStack.pop()
        else:
            instructionPointer = instructionStack[^1]

    # Should never happen, but the compiler would cry, if i did not cover all cases:
    else: discard

    # Pointer wrapping:
    if tapePointer < 0:
        tapePointer = tape.len() - 1
    if tapePointer >= tape.len():
        tapePointer = 0

    # Tape value wrapping:
    if tape[tapePointer] < 0:
        tape[tapePointer] = 255
    if tape[tapePointer] > 255:
        tape[tapePointer] = 0

    instructionPointer.inc

    # Debugging:
    # echo &"[{instructionPointer}/{program.len} ({instruction})]  |  pointer on {tapePointer}  |  {tape[0..15]}..."


# ---------------------------------------- MAIN LOOP ---------------------------------------- #

proc main() =
    let program: string = getRawProgramInstructions()
    if program == "": program.runtimeException(NoLoadedProgram, "The program you provided did not have any valid brainfuck instructions.")

    let begin: DateTime = now()
    while instructionPointer < program.len():
        program.run()
    let executionTime: Duration = (now() - begin)
    echo "\nExecution took ", executionTime.inMicroseconds(), " μs."


when isMainModule:
    main()
