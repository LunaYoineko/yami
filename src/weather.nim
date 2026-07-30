import std/[random]

const
    weathers = @[
        "晴れ",
        "曇",
        "雨",
        "雪",
        "雷雨",
        "猫",
        "コーヒー",
        "飴",
        "ナイフ",
        "もの"
    ]
    
    tempranges = @[
        "氷点下で寒すぎる",
        "平年並み",
        "ぽかぽか陽気",
        "サウナ状態",
        "極寒地獄",
        "溶け猫日和",
        "灼熱地獄",
        "暑すぎず寒すぎずちょうど良くもない状態"
    ]
    
    comments = @[
        "外出する時は傘ではなく盾を持って行ったほうがいいかも",
        "洗濯物を干すと虚無空間に消えちゃうから注意だよ",
        "猫を数には最適な気候だね",
        "猫に吸われないように注意してね",
        "人工ブラックホールが大量発生してるみたいだから気をつけてね"
    ]
    
proc generateRandomWeatherNote*(): string =
    randomize()
    let w = sample(weathers)
    let t = sample(tempranges)
    let c = sample(comments)
    return "北海道神々宮町の天気を教えるよ\n天気: " & w & "\n気温感: " & t & "\nやみから一言: " & c