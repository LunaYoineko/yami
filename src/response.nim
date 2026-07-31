import std/[random, times]
import profile

let neutral* = [
    "よんだ？、、、",
    "やみ、、、だよ？",
    "呼ばれた気がする、、、",
    "呼んだかな？、、、",
    "はーい",
    "何か用かな？、、、",
    if rand(999) == 0: "にゃん///" else: "なに、かな？"
]

let goodmorning* = [
    "おはよう、" & perseProf.display_name & "、、、",
    perseProf.display_name & "の\n今日がいい一日でありますように",
    "よく眠れた？",
    perseProf.display_name & "\n今日も、、、よろしくね",
    "もう起きてたよ。\n" & perseProf.display_name & "を待ってた",
    "今日は早いね"
]

let hello* = [
    "こんにちは、\n" & perseProf.display_name,
    "待ってた、、、よ？",
    "こんにちは、、、今日は何をしていたのかな？",
    "もう来ないかと思ってた"
]

let currentHour = now().hour
let lateNight = if currentHour >= 0 and currentHour <= 4: "こんばんは\nまだ起きてたんだね" else: "こんばんは\n夜は静かでいいね、、、"

let goodevening* = [
    "こんばんは",
    "1日お疲れ様",
    lateNight
]

let goodnight* = [
    "おやすみ、、、",
    perseProf.display_name & "\nおやすみ",
    "また明日ね",
    "もう寝ちゃうの？、、、\nおやすみ、、、"
]

let tired* = [
    perseProf.display_name & "\nお疲れ様、、、",
    "ゆっくり休んで、、、ね",
    "無理しないでね",
    "お茶、入れてくる"
]

let kyomonan* = [
    "きょうもなんとか",
    "今日も一日頑張ろうね",
    perseProf.display_name & "を応援してるよ、、、",
    "きょもなん！",
    "今日も何とか生き残ろうね、、、"
]

let gogonan* = [
    "ごごもなんとか",
    "午後も頑張ろう",
    "やみはお昼寝するけど、、、" & perseProf.display_name & "は頑張ってね！",
    "ごごなん！",
    "午後も何とか生き残ろうね"
]

let unknown* = [
    "ごめん難しくてよくわからないや、、、\nできることって聞いてくれたら教えてあげるけど、、、",
    "なんかサイコロはNostrの投稿をノイズにしていたらしいんだけど\nただのランダムになっちゃったんだって、、、",
    "ごめんね、、、その問いには答えられないやルナに聞いてみないと、、、",
    "夜を散歩するのが好きだよ、、、ごめんどうでもいいよね、、、"
]

let yatte* = [
    "やみは実態がないからリアルワールドには干渉できないかな、、、",
    "終わったよ！頑張った、、、",
    "ルナ、代わりにやって！",
    "一回につき1000Zapだけどいい？\nまぁもらってもできないけど、、、"
]

let negative* = [
    "えんいー",
    "ごめん、、、\nやみ使えないよね、、、",
    "やっぱりやみ無能なんだ、、、",
    "、、、ごめんなさい"
]