import std/[sequtils, random, strutils]
import regex
import profile

proc tellFortune*(): string =
    let comments = [
      ("大吉", "最高の一日になりそう！"),
      ("吉", "いいことがありそう"),
      ("中吉", "穏やかに過ごせます。"),
      ("小吉", "ささやかな幸せがあるかも"),
      ("末吉", "焦らずマイペースに行きましょう。"),
      ("凶", "無理せず省エネモードで過ごしましょう。"),
      ("大凶", "寝ていたほうがいいかも"),
      ("つねきち", "詐欺にあうかもしれません"),
      ("たぬきち", "ローン上乗せの被害にあいます")
    ]
    let luckyItems = [
        "コーヒー",
        "ミントタブレット",
        "青いペン",
        "散歩",
        "好きな音楽",
        "猫の動画",
        "1億円",
        "nostr",
        "神様"
    ]
    
    let (omikuji, comment) = comments.sample()
    let item = luckyItems.sample()
    return "今日のやみ占いだよ！\n" & perseProf.display_name & "の運勢は、、、\n【" & omikuji & "】\n" & comment & "\nラッキーアイテム: " & item
    
proc chooseOption*(t: string): string =
    var cleanText = t.multiReplace([("選んで", ""), ("どれ", ""), ("どっち", ""), ("ルーレット", ""), ("決めて", ""), ("choice", ""), ("?", "")])
    let items = cleanText.split(re2"[,、 とか\s]+").filter(proc(x: string): bool = x.strip() != "")
    if items.len < 2:
      return "選択肢がなくて決めれないよ、、、\n,か、で区切って選択肢を頂戴、、、"
    let selected = items.sample()
    return "う～ん、、、『" & selected & "』かな？、、、"
    
proc getNostradomResult*(t: string): string =
    var cleanText = t.multiReplace([("ランダム", ""), ("乱数", "")])
    let items = cleanText.split(re2"[,、 \s]+").filter(proc(x: string): bool = x.strip() != "")
    if items.len < 2:
      return "最小値と最大値を決めてくれたら\nやみがそこから選んであげるよ？"
    elif items.len > 2:
      return "最小値と最大値以外はいらない、、、かな"
    
    try:
      let a = parseInt(items[0])
      let b = parseInt(items[1])
      if a > b:
        return "最小値が最大値よりも大きいんだけど、、、\nやみのいない間に世界が変わったのかな？、、、"
      elif b == 0:
        return "最大値が0になってるよ！？\n無限の中から決めたらいいのかな？、、、"
    
      let val = rand(a..b)
      let resps = [
        $val & " かな？、、、",
        $val & " を選んでみたよ、、、",
        $val & " の気分、、、"
      ]
      return resps.sample()
    except ValueError:
      return "数字として読み取れなかったよ、、、"