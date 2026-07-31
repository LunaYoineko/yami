import std/[asyncdispatch, options]
import nimstr

var perseProf*: UserProfile

proc getDName*(relay: RelayClient, pubkey: string) {.async.} =
# kind0取得処理
  let profileOpt = await relay.getProfile(pubkey)
  if profileOpt.isSome:
      perseProf = profileOpt.get()
  else:
      perseProf = UserProfile(display_name: "君")
    
  