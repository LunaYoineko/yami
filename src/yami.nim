import std/[asyncdispatch, json, options, os, random, sets, times, strutils]
import ws, regex
import dotenv
import nimstr
import function, response, weather, dice, slot, profile

load()

let nsec = getEnv("NOSTR_NSEC")
let targetKeyword = "やみ"
let targetNpub = getEnv("TEST_TARGET_NPUB")

let commandPattern = re2("(?si)" & targetKeyword & r"(?:([,、 \s]+)(.*))?$")
let mentionPattern = re2(r"(?si)^(?:nostr:npub1[a-z0-9]+|@\w+|@[^\s,、 ]+)([,、 \s ]?)(.*)")

var botActive* = true

proc parseEventJson(j: JsonNode): Option[NostrEvent] =
  try:
    if j.kind != JArray: return none(NostrEvent)
    let length = j.len
    if length < 2: return none(NostrEvent)
    if j[0].getStr() != "EVENT": return none(NostrEvent)
    var ev: JsonNode
    if length >= 2 and j[1].kind == JObject:
      ev = j[1]
    elif length >= 3 and j[2].kind == JObject:
      ev = j[2]
    else:
      return none(NostrEvent)
    if ev.kind != JObject: return none(NostrEvent)
    if not ev.hasKey("id") or not ev.hasKey("pubkey") or not ev.hasKey("content"):
      return none(NostrEvent)
    var tags: seq[seq[string]] = @[]
    if ev.hasKey("tags") and ev["tags"].kind == JArray:
      for t in ev["tags"]:
        var row: seq[string] = @[]
        if t.kind == JArray:
          for item in t:
            row.add(item.getStr())
        tags.add(row)
    return some(NostrEvent(
      id: ev["id"].getStr(),
      pubkey: ev["pubkey"].getStr(),
      createdAt: if ev.hasKey("created_at"): ev["created_at"].getInt() else: 0,
      kind: if ev.hasKey("kind"): ev["kind"].getInt() else: 0,
      tags: tags,
      content: ev["content"].getStr(),
      sig: if ev.hasKey("sig"): ev["sig"].getStr() else: ""
    ))
  except:
    return none(NostrEvent)

proc processEvent(relay: RelayClient, event: NostrEvent, myKeypair: NostrKeypair, targetHexPubkey: string) {.async.} =
  if event.pubkey == myKeypair.pubkeyHex:
    return

  let text = event.content
  let myHexPubkey = myKeypair.pubkeyHex

  var isMentioned = false
  for tag in event.tags:
    if tag.len >= 2 and tag[0] == "p" and tag[1] == myHexPubkey:
      isMentioned = true
      break

  var delimiter = ""
  var promptText = ""
  var matched = false
  var m = RegexMatch2()

  if isMentioned:
    if text.strip().match(mentionPattern, m):
      delimiter = text[m.group(0)]
      promptText = text[m.group(1)]
    else:
      delimiter = ""
      promptText = text
    matched = true
  else:
    if text.match(commandPattern, m):
      delimiter = text[m.group(0)]
      promptText = text[m.group(1)]
      matched = true

  if not matched:
    return

  await relay.getProf(event.pubkey)
  
  let cmd = promptText.strip()
  if targetHexPubkey != "" and event.pubkey == targetHexPubkey:
    if "おはよう" in cmd:
      botActive = true
      echo "やみを開始しました"
    elif "おやすみ" in cmd:
      discard

  if not botActive:
    return  

  var replyText = ""
  var replyTags = newJArray()
  var isSayingGoodnight = false
  var replies: seq[string] = @[]

  if cmd == "":
    replyText = neutral.sample()
  else:
    if "サイコロ" in cmd or "ダイス" in cmd or "dice" in cmd:
      if "絵文字無し" in cmd:
          replies.add(rollDice(false))
      else:
          replies.add(rollDice(true))
      
    if "確サイ" in cmd:
      replies.add("サイコロを振ったよ、、、 " & diceNames[(rand(5) + 1) - 1] & " だったよ")
      
    if "チンチロ" in cmd or "ちんちろ" in cmd:
      if "絵文字無し" in cmd:
          replies.add(chinchiro(false))
      else:
          replies.add(chinchiro(true))
  
    if "スロット" in cmd:
      replies.add(playSlot())
      
    if "ランダム" in cmd or "乱数" in cmd:
      replies.add(getNostradomResult(cmd))
      
    if "占い" in cmd or "おみくじ" in cmd or "運勢" in cmd:
      replies.add(tellFortune())

    if "天気" in cmd and "教えて" in cmd:
      replies.add(if rand(100) == 0: "縲仙圏豬ｷ驕鍋･槭?螳ｮ逕ｺ縲代?螟ｩ豌励ｒ謨吶∴繧九ｈ\n螟ｩ豌? 陦??髮ｨ\n豌玲ｸｩ諢? 貂ｩ縺九＞縲√◎縺励※蜀ｷ縺溘＞縲√◎縺励※隱ｰ繧ゅ＞縺ｪ縺?\n繧ｳ繝｡繝ｳ繝? 縺ゅ↑縺溘ｂ豁ｻ縺ｬ縺薙→縺ｫ縺ｪ繧?" else: generateRandomWeatherNote())
      
    let praiseKeywords = ["かわいい", "天才", "すごい", "神", "優秀", "えらい", "好き", "最高"]
    var hasPraise = false
    for kw in praiseKeywords:
      if kw in cmd.toLower():
        hasPraise = true
        break
    if hasPraise:
      replies.add("、、、ありがとう")
      
    let negativeKeywords = ["できてない", "だめ", "使えない", "終わってない", "役に立たない", "きらい", "嫌い", "無能"]
    var hasNegative = false
    for kw in negativeKeywords:
        if kw in cmd.toLower():
            hasNegative = true
            break
            
    if hasNegative:
        replies.add(negative.sample())

    if "選んで" in cmd or "どっち" in cmd or "どれ" in cmd or "ルーレット" in cmd:
      replies.add(chooseOption(cmd))
      
    if "おはよう" in cmd:
      replies.add(goodmorning.sample())
      
    if "こんにちは" in cmd:
      replies.add(hello.sample())
      
    if "こんばんは" in cmd:
      replies.add(goodevening.sample())
      
    if "おやすみ" in cmd:
      replies.add(goodnight.sample() & "\nbotActive: " & $botActive)
      if targetHexPubkey != "" and event.pubkey == targetHexPubkey:
        isSayingGoodnight = true
        
    if "疲れた" in cmd:
      replies.add(tired.sample())
      
    if ("しても" in cmd or "でも" in cmd or "ても" in cmd) and "いい？" in cmd:
      let resp = [
        "いいと思う、、よ？",
        "絶対、、、だめ"
      ]
      replies.add(resp.sample())
      
    if "やって" in cmd or "やっといて" in cmd:
        replies.add(yatte.sample())
      
    if "きょもなん" in cmd:
      replies.add(kyomonan.sample())
      
    if "ごごなん" in cmd:
      replies.add(gogonan.sample())
      
    if "自己紹介" in cmd:
      let resp = "やみです、、、\nあまり役に立てないと思うけど\nよろしくお願いします、、、"
      replies.add(resp)
      
    if "できること" in cmd:
      let resp = "[ダイス]といわれたらサイコロを振るよ\n[占い]といわれたら今日の運勢を占うよ\n最小値と最大値を決めて[ランダム]と言ったらその中からやみが数字を選んであげるよ\n選択肢を[, | 、 | と | か]で区切って指定して[どれ]と言ったらその中から代わりに決めてあげる"
      replies.add(resp)

    if "中身" in cmd or "正体" in cmd or "ソース" in cmd:
      replies.add("恥ずかしいな///\nhttps://github.com/LunaYoineko/yami")
      
    if "プロフ取得" in cmd:
      if "nostr:npub1" in cmd:
        let text = cmd.replace("プロフ取得","").strip()
        let nppattern = re2("(nostr:npub1[02-9ac-hj-np-z]+)")
        var npub: RegexMatch2
        if text.match(nppattern, npub):
            let pubkey = text[npub.group(0)].replace("nostr:","")
            let pubkeyHex = fromBech32(pubkey).hex
            await relay.getProf(pubkeyHex)
      elif "nostr:npub1" notin cmd and "npub1" in cmd:
        let text = cmd.replace("プロフ取得","").strip()
        let nppattern = re2("(npub1[02-9ac-hj-np-z]+)")
        var npub: RegexMatch2
        if text.match(nppattern, npub):
            let pubkey = fromBech32(text[npub.group(0)]).hex
            await relay.getProf(pubkey)    
        
      if perseProf.display_name != "君":
        replies.add("あなたは " & perseProf.display_name & " だね、、、\n")
        replies.add("ユーザー名は " & perseProf.name & " で、\n")
        if perseProf.website != "":
            replies.add(perseProf.website & " を公開していて、、、\n")
        else:
            replies.add("特にウェブサイトは公開していなくて、、、\n")
        if perseProf.lightning_address != "":
            replies.add(perseProf.lightning_address & " が設定されていて、、、\n")
        else:
            replies.add("お金は受け取らないスタンスで、、、\n")
        if perseProf.nip05 != "":
            replies.add(perseProf.nip05 & " を設定していて、、、\n")
        else:
            replies.add("特にNIP05を設定してなくて、、、\n")
        if perseProf.about.len > 100:
            replies.add("自己紹介が長い\n")
        else:
            replies.add("自己紹介が短い\n")
        replies.add("人であってるかな？、、、\n")
        replies.add("間違ってたらごめん、、、")
      else:
        replies.add("ごめん\n君はだれ？、、、")
      
    if replies.len > 0:
      replyText = replies.join("\n")
    else:
      replyText = unknown.sample()

  let triggerType = if isMentioned: "メンション" else: "キーワード"
  echo "[", triggerType, "] 抽出された命令: '", cmd, "' (区切り: '", delimiter, "')\n返答: " & replyText

  if "サイコロ" in cmd or "ダイス" in cmd or "確サイ" in cmd or "dice" in cmd or "チンチロ" in cmd or "ちんちろ" in cmd and "絵文字無し" notin cmd:
      
    for t in diceNames:
        replyTags.add(%*["emoji", t.replace(":",""), "https://awayuki.github.io/emoji/" & t.replace(":","").replace("_","-") & ".png"])
  
  let replyTarget = ReplyTarget(
    eventId: event.id,
    relayUrl: relay.url,
    authorPubkey: event.pubkey
  )
  discard await relay.sendRootReply(myKeypair.seckeyHex, replyText, replyTarget, replyTags)

  if isSayingGoodnight:
    botActive = false
    echo "やみを停止しました"

type
  SharedState = ref object
    startTime: int64
    seenIds: HashSet[string]

proc readRelayMessages(relay: RelayClient, myKeypair: NostrKeypair, targetHexPubkey: string, state: SharedState) {.async.} =
  while relay.connected:
    try:
      let raw = await relay.ws.receiveStrPacket()
      if raw.len == 0 or raw[0] != '[':
        continue
      let j = parseJson(raw)
      let eventOpt = parseEventJson(j)
      if eventOpt.isSome:
        let evt = eventOpt.get()
        if evt.pubkey == myKeypair.pubkeyHex:
          continue
        if evt.createdAt < state.startTime:
          continue
        if evt.id in state.seenIds:
          continue
        state.seenIds.incl(evt.id)
        echo "[", relay.url, "] ", evt.content[0 .. min(evt.content.len - 1, 40)]
        await processEvent(relay, evt, myKeypair, targetHexPubkey)
    except CatchableError as e:
      echo "[", relay.url, "] エラー: ", e.msg
      break

proc main() {.async.} =
  randomize()
  let myKeypair = keypairFromSecret(nsec)
  
  var targetHexPubkey = ""
  try:
    if targetNpub != "":
      let decoded = fromBech32(targetNpub)
      targetHexPubkey = decoded.hex
      echo "npubが指定されました: ", targetHexPubkey
  except Exception:
    targetHexPubkey = ""

  let relayUrls = @["wss://relay.yoinekodo.jp", "wss://yabu.me"]
  let pool = newRelayPool(relayUrls)
  await pool.connectAll()

  let filter = NostrFilter(kinds: @[1])
  await pool.subscribeAll("yami_sub", filter)

  let state = SharedState(startTime: getTime().toUnix())

  echo "やみ起床中... (npub: ", myKeypair.npub, ")"

  var futs: seq[Future[void]] = @[]
  for r in pool.relays:
    if r.connected:
      futs.add(readRelayMessages(r, myKeypair, targetHexPubkey, state))

  await all(futs)
  await pool.closeAll()

when isMainModule:
  waitFor(main())
