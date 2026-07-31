import std/[algorithm, random]

let diceNames* = [
    ":mahjong_dice1:",
    ":mahjong_dice2:",
    ":mahjong_dice3:",
    ":mahjong_dice4:",
    ":mahjong_dice5:",
    ":mahjong_dice6:"
]

proc rollDice*(mode: bool = true): string =
    let resp = [
      if mode:
          "サイコロを振ったよ: " & diceNames[(rand(5) + 1) - 1] & " だった、、、よ"
      else:
          "サイコロを振ったよ: [" & $(rand(5) + 1) & "] だった、、、よ" ,
      "サイコロを振ったよ、、、ごめん机の下に入っちゃた、、、",
      "サイコロ「今日は非番やで」",
      "サイコロなくしちゃった、、、",
      "サイコロテーブルの下でかくれんぼしてるみたい",
      "サイコロ「6やで」",
      "サイコロ「ピンゾロやで」",
      "サイコロを振ったよ:[" & $(rand(1023) + 1) & "]だったよ"
    ]
    return resp.sample()
    
proc chinchiro*(mode: bool = true): string =
    var dice = [
        rand(5) + 1,
        rand(5) + 1,
        rand(5) + 1
    ]
    dice.sort()
    let a = dice[0]
    let b = dice[1]
    let c = dice[2]
    
    if dice == [1, 1, 1]:
      if mode:
          return "出目は " & diceNames[0] & diceNames[0] & diceNames[0] & "\nピンゾロだったよ！"
      else:
          return "出目は🎲🎲🎲 \nピンゾロだったよ！"
          
    elif a == b and b == c:
      if mode:
          return "出目は" & diceNames[a - 1] & " " & diceNames[b - 1] & " " & diceNames[c - 1] & " \nゾロ目だよ"
      else:
          return "出目は[" & $a & "][" & $b & "][" & $c & "]\nゾロ目だよ"
          
    elif dice == [4, 5, 6]:
      if mode:
          return "出目は " & diceNames[a - 1] & " " & diceNames[b - 1] & " " & diceNames[c - 1] & " \nシゴロだよ、、、"
      else:
          return "出目は[" & $a & "][" & $b & "][" & $c & "]\nシゴロだよ、、、"
      
    elif dice == [1, 2, 3]:
      if mode:
          return "出目は " & diceNames[a - 1] & " " & diceNames[b - 1] & " " & diceNames[c - 1] & " \nヒフミだったよ"
      else:
          return "出目は[" & $a & "][" & $b & "][" & $c & "]\nヒフミだったよ"
          
    elif a == b:
      if mode:
          return "出目は " & diceNames[a - 1] & " " & diceNames[b - 1] & " " & diceNames[c - 1] & " \n " & diceNames[c - 1] & " の目、、、"
      else:
          return "出目は[" & $a & "][" & $b & "][" & $c & "]\n " & $c & " の目、、、"
          
    elif b == c:
      if mode:
          return "出目は " & diceNames[a - 1] & " " & diceNames[b - 1] & " " & diceNames[c - 1] & " \n " & diceNames[a - 1] & " の目、、、"
      else:
          return "出目は[" & $a & "][" & $b & "][" & $c & "]\n " & $a & " の目、、、"
          
    else:
      if mode:
          return "出目は " & diceNames[a - 1] & " " & diceNames[b - 1] & " " & diceNames[c - 1] & " \nだったよ、、、\n役無し、、、だね"
      else:
          return "出目は[" & $a & "][" & $b & "][" & $c & "]\nだったよ、、、\n役無し、、、だね"