import std/[unittest]
import ../src/tokens

test "Token Parser":
    let
        expectedSource: string = "<>[+-.,]"
        expectedTokens: seq[Token] = @[
            moveTapePointerLeft, moveTapePointerRight, loopBracketBegin,
            increaseTapeData, decreaseTapeData, outputChar, inputChar,
            loopBracketEnd
        ]
    
    check expectedSource.convertToTokens() == expectedTokens
    check expectedTokens.convertToString() == expectedSource


