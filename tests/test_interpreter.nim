import std/[unittest]
import ../src/brainimfuck

proc loadSource(filename: string) =
    programInstructions = @[]
    programInstructions = parseSourceFile("tests/brainfuck/" & filename)

test "Hello World - Long":
    loadSource("helloworld.bf")
    check checkProgramSyntax() == true
    executeProgram()

test "Hello World - Short":
    loadSource("helloworld_short.bf")
    check checkProgramSyntax() == true
    executeProgram()

test "Error highlighter":
    loadSource("error.bf")
    # This program syntax should error:
    check checkProgramSyntax() == false
