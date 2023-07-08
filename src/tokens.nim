import std/[options]

type
    Token* = enum
        moveTapePointerLeft, moveTapePointerRight
        increaseTapeData, decreaseTapeData
        loopBracketBegin, loopBracketEnd
        outputChar, inputChar

proc convertToToken(raw: char): Option[Token] =
    case raw:
    of '<': return some moveTapePointerLeft
    of '>': return some moveTapePointerRight
    of '+': return some increaseTapeData
    of '-': return some decreaseTapeData
    of '[': return some loopBracketBegin
    of ']': return some loopBracketEnd
    of '.': return some outputChar
    of ',': return some inputChar
    else:   return none Token


proc convertToTokens*(rawString: string): seq[Token] =
    for character in rawString:
        let token: Option[Token] = character.convertToToken()
        if token.isSome(): result.add(token.get())
