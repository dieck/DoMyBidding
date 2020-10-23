local L = LibStub("AceLocale-3.0"):NewLocale("DoMyBidding", "enUS", true)

if L then

-- configs

L["Timings"] = "Timings"

L["Bid duration"] = "Bid duration"
L["Initial time for a bid"] = "Initial time for a bid"
L["Bids prolong"] = "Bids prolong"
L["If a new bid came in, prolong time to end if necessary"] = "If a new bid came in, prolong time to end if necessary"

L["Accept bids"] = "Accept bids"

L["Raid"] = "Raid"
L["Accept bidding in party/raidchat"] = "Accept bidding in party/raidchat"
L["Whisper"] = "Whisper"
L["Accept bidding by whisper"] = "Accept bidding by whisper"
L["Only once"] = "Only once"
L["Accept only first bid (disables revocation)"] = "Accept only first bid (disables revocation)"
L["Same amount"] = "Same amount"
L["Accept same amount bids (if disabled: earliest bid wins)"] = "Accept same amount bids (if disabled: earliest bid wins)"
L["Revoke bid"] = "Revoke bid"
L["Allows users to revoke bid (disables only once)"] = "Allows users to revoke bid (disables only once)"


L["Raid announces"] = "Raid announces"

L["Countdown"] = "Countdown"
L["Give Countdown in raid/party chat"] = "Give Countdown in raid/party chat"
L["New max"] = "New max"
L["Announce new max bids to raidchat"] = "Announce new max bids to raidchat"
L["List to Raid"] = "List to Raid"
L["Outputs full list to raid/party on finish (disables output to user)"] = "Outputs full list to raid/party on finish (disables list to you)"


L["Whisper announces"] = "Whisper announces"

L["Received"] = "Received"
L["Whisper to player if bid was received"] = "Whisper to player if bid was received"
L["Accepted"] = "Accepted"
L["Whisper to player if bid was accepted (disables received whisper)"] = "Whisper to player if bid was accepted (disables received whisper)"
L["Not accepted"] = "Not accepted"
L["Whisper to player if bid was not accepted (disables received whisper)"] = "Whisper to player if bid was not accepted (disables received whisper)"
L["Too low"] = "Too low"
L["Whisper to player if bid was lower than current max"] = "Whisper to player if bid was lower than current max"
L["Outbid"] = "Outbid"
L["Whisper to player if another higher bid was received"] = "Whisper to player if another higher bid was received"
L["No rolls"] = "No rolls"
L["Tells the player to bid if he rolls during bidding"] = "Tells the player to bid if he rolls during bidding"

L["Presets"] = "Presets"

L["Open Bidding"] = "Open Auction"
L["Open bidding in raid chat, with max & low announces, same bidding allowed, bid again allowed"] = "Open bidding in raid chat, with max & low announces, same bidding allowed, bid again allowed"
L["Silent Bidding"] = "Silent Bidding"
L["Silent bidding by whisper, no max / low announces, first bid wins"] = "Silent bidding by whisper, no max / low announces, first bid wins"

L["Miscellaneous"] = "Miscellaneous"

L["Enable additional usage of /bid"] = "Enable additional usage of /bid"
L["Enable additional usage of /auction"] = "Enable additional usage of /auction"
L["List to you"] = "List to you"
L["Outputs full list to you on finish (disables output to raid/party)"] = "Outputs full list to you on finish (disables output to raid/party)"

L["Language"] = "Language"
L["Language for outputs"] = "Language for outputs"

L["Debug"] = "Debug"


-- notifications

L["Usage: |cFF00CCFF/dmb |cFFA335EE[Sword of a Thousand Truths]|r to start a bid"] = "Usage: |cFF00CCFF/dmb |cFFA335EE[Sword of a Thousand Truths]|r to start a bid"
L["Usage: |cFF00CCFF/dmb config|r to open the configuration window"] = "Usage: |cFF00CCFF/dmb config|r to open the configuration window"

L["Bidding for itemLink still running, cannot start new bidding now!"] = function(itemLink) return "Bidding for " .. itemLink .. " still running, cannot start new bidding now!" end
L["You don't have assist, so I cannot put out Raid Warnings"] = "You don't have assist, so I cannot put out Raid Warnings"
L["You are not in a party or raid. So here we go: Have fun bidding for itemLink against yourself."] = function(itemLink) return "You are not in a party or raid. So here we go: Have fun bidding for " .. itemLink .. " against yourself." end


-- load default outputs 
for k,v in pairs(DoMyBidding.outputLocales["enUS"]) do L[k] = v end

end -- if L then




