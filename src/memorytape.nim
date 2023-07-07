import std/[tables]


type Tape* = object
    table*: Table[int64, uint8]
    pointerPosition*: int64

using
    tape: var Tape

proc initCell(tape; cellId: int64) =
    if not tape.table.hasKey(cellId): tape.table[cellId] = 0

proc moveLeft*(tape) =
    tape.pointerPosition.dec()

proc moveRight*(tape) =
    tape.pointerPosition.inc()

proc readValue*(tape): uint8 =
    if not tape.table.hasKey(tape.pointerPosition): return 0
    return tape.table[tape.pointerPosition]

proc writeValue*(tape; value: uint8) =
    tape.table[tape.pointerPosition] = value

proc increaseCurrentCell*(tape) =
    tape.initCell(tape.pointerPosition)
    tape.table[tape.pointerPosition].inc()

proc decreaseCurrentCell*(tape) =
    tape.initCell(tape.pointerPosition)
    tape.table[tape.pointerPosition].dec()



