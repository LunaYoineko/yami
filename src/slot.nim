import std/[random]

let reel* = [
    "7",
    "B",
    "🍒",
    "🍇",
    "🤡",
    "🔔",
    "R"
]

proc playSlot*(): string =
    var slot = [
        reel.sample(),
        reel.sample(),
        reel.sample()
    ]
    let a = slot[0]
    let b = slot[1]
    let c = slot[2]

    if a == b and b == c:
        return "[ " & a & " | " & b & " | " & c & " ]\n" & a & " がそろったよ！"
    
    elif a == b or a == c or b == c:
        return "[ " & a & " | " & b & " | " & c & " ]\n惜しかったね、、、" 
        
    else:
        return "[ " & a & " | " & b & " | " & c & " ]"