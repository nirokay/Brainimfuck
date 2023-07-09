import std/[os, parseopt, strutils]
import ./globals, ./tokens, ./sourceparser, ./interpreter, ./error
export globals, tokens, sourceparser, interpreter

const
    NAME: string = "brainimfuck"
    VERSION: string = "1.0.0"


# Binary stuff: ---------------------------------------------------------------

when isMainModule:
    # Variables:
    var
        sourceFilePath: string
        commands: seq[tuple[nameLong, nameShort, desc: string, call: proc(args: string)]]

    # Command procs:
    proc helpCommand(_: string) =
        var cmds: seq[string]
        for command in commands:
            var cmd: string = alignLeft("  -" & command.nameShort & ", --" & command.nameLong, 32, ' ') & command.desc
            cmds.add(cmd)

        echo NAME & " - v" & VERSION
        echo cmds.join("\n")

    # User commands:
    commands = @[
        (
            nameLong: "help", nameShort: "h",
            desc: "Displays this help message.",
            call: proc(args: string) {.closure.} = helpCommand(args); quit(0)
        ),
        (
            nameLong: "version", nameShort: "v",
            desc: "Prints version number.",
            call: proc(args: string) {.closure.} = echo NAME & " - v" & VERSION; quit(0)
        ),
        (
            nameLong: "stats", nameShort: "s",
            desc: "Prints statistics about runtime at the end of the execution.",
            call: proc(args: string) {.closure.} = printStatsAfterExecution = true
        ),
        (
            nameLong: "debug", nameShort: "d",
            desc: "Prints useful debug information.",
            call: proc(args: string) {.closure.} = printDebugInformation = true
        ),
        (
            nameLong: "unsafe-run", nameShort: "u",
            desc: "Skips syntax checking and run potentially unsafe/incorrect code.",
            call: proc(args: string) {.closure.} = runWithoutChecks = true
        )
    ]


    # Parse commandline arguments:
    var p = initOptParser(commandLineParams())
    for kind, key, value in p.getopt():
        case kind:

        of cmdEnd: break

        of cmdArgument:
            sourceFilePath = key

        of cmdLongOption, cmdShortOption:
            for cmd in commands:
                if key == cmd.nameShort or key == cmd.nameLong: cmd.call(value)

    # Check source file:
    if sourceFilePath == "": errorNoSourceFileGiven.panic("No source file!")

    # Parse source to tokens:
    programInstructions = sourceFilePath.parseSourceFile()

    # Check syntax:
    if not runWithoutChecks:
        if not checkProgramSyntax(): quit(1)

    # Run commands:
    executeProgram()










