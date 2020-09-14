local L = LibStub("AceLocale-3.0"):GetLocale("DoMyBidding", true)

-- Output to Raid chat, Party chat or chat window
function DoMyBidding:CanDoRaidWarning() 
	for i = 1, MAX_RAID_MEMBERS do
		local name, rank = GetRaidRosterInfo(i)
		if name == UnitName("player") then
			return (rank >= 1)
		end
	end
	return false
end

function DoMyBidding:OutputWithWarning(msg)
	if UnitInRaid("player") then
		if DoMyBidding:CanDoRaidWarning() then
			SendChatMessage(msg, "RAID_WARNING")
		else
			SendChatMessage(msg, "RAID")
		end
	else
		if UnitInParty("player") then
			SendChatMessage(msg, "PARTY")
		else
			DoMyBidding:Print(msg)
		end
	end
end

function DoMyBidding:Output(msg)
	if UnitInRaid("player") then
		SendChatMessage(msg, "RAID")
	else
		if UnitInParty("player") then
			SendChatMessage(msg, "PARTY")
		else
			DoMyBidding:Print(msg)
		end
	end
end

function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
     end
     return iter
end

function DoMyBidding:OutputFullList()
	o = nil
	if DoMyBidding.db.profile.outputfull_raid then o = function(txt) DoMyBidding:Output(txt) end end
	if DoMyBidding.db.profile.outputfull_user then o = function(txt) DoMyBidding:Print(txt) end end
	if o == nil then return nil end

	-- transpose table
	bidsbybids = {}
	for player,bid in pairs(DoMyBidding.db.profile.currentbidding.bids) do
		if bidsbybids[bid] == nil then bidsbybids[bid] = {} end
		table.insert(bidsbybids[bid], player)
	end

	for bid,users in pairsByKeys(bidsbybids) do
		players = table.concat(users, ", ")
		o("Bid " .. bid .. " from " .. players)
	end
end

function DoMyBidding:StartBidding(itemLink)
	
	if not (DoMyBidding.db.profile.currentbidding.itemLink == nil) then
		DoMyBidding:Print(L["Bidding for itemLink still running, cannot start new bidding now!"](DoMyBidding.db.profile.currentbidding.itemLink))
		return nil
	end
	
	startnotice = L["Start Bidding now: itemLink"](itemLink)
	
	if UnitInRaid("player") then
	
		if DoMyBidding:CanDoRaidWarning() then
			SendChatMessage(startnotice, "RAID_WARNING")
		else
			if not DoMyBidding.onetimes["assist"] then
				DoMyBidding:Print(L["You don't have assist, so I cannot put out Raid Warnings"])
				DoMyBidding.onetimes["assist"] = true
			end
			SendChatMessage(startnotice, "RAID")
		end

	else
		if UnitInParty("player") then
			SendChatMessage(startnotice, "PARTY")
		else
			DoMyBidding:Print(L["You are not in a party or raid. So here we go: Have fun bidding for itemLink against yourself."](itemLink))
		end
	end
	
	DoMyBidding.db.profile.currentbidding = {}
	DoMyBidding.db.profile.currentbidding["itemLink"] = itemLink
	DoMyBidding.db.profile.currentbidding["endTime"] = time() + DoMyBidding.db.profile.bidduration
	
	DoMyBidding.db.profile.currentbidding["maxBid"] = -1
	DoMyBidding.db.profile.currentbidding["announceNewMaxBid"] = false

	DoMyBidding.db.profile.currentbidding["bids"] = {}
	
	DoMyBidding.biddingTimer = DoMyBidding:ScheduleRepeatingTimer("BidTimerHandler", 1)
	
end

function DoMyBidding:BidTimerHandler()

	if DoMyBidding.db.profile.currentbidding["announceNewMaxBid"] then
		if DoMyBidding.db.profile.shownewmax then 
			DoMyBidding:Output(L["Current highest bid for itemLink is maxbid"](DoMyBidding.db.profile.currentbidding.itemLink, DoMyBidding.db.profile.currentbidding["maxBid"]))
		end
		DoMyBidding.db.profile.currentbidding["announceNewMaxBid"] = false
	end

	-- look if timer expired
	if DoMyBidding.db.profile.currentbidding["endTime"] < time() then
		DoMyBidding:Output(L["Bidding ended!"])
		
		if DoMyBidding.db.profile.currentbidding.maxBid == -1 then
			DoMyBidding:OutputWithWarning(L["No one bid on itemLink"](DoMyBidding.db.profile.currentbidding.itemLink))
		else
		
			local newmax = -1
			local maxplayers = {}
			local singleplayer = true
			
			for name,bid in pairs(DoMyBidding.db.profile.currentbidding.bids) do 
				if bid > newmax then 
					maxplayers = {}
					newmax = bid
				end
				if bid == newmax then
					tinsert(maxplayers, name)
				end
			end

			if #maxplayers == 1 then
				DoMyBidding:OutputWithWarning(L["Congratulations! maxplayers won itemLink for maxbid"](maxplayers,DoMyBidding.db.profile.currentbidding.itemLink,DoMyBidding.db.profile.currentbidding.maxBid))
			else
				DoMyBidding:OutputWithWarning(L["Tie! maxplayers please roll on itemLink for maxbid"](maxplayers,DoMyBidding.db.profile.currentbidding.itemLink,DoMyBidding.db.profile.currentbidding.maxBid))
			end

			
		end
		
		DoMyBidding.db.profile.lastbidding = DoMyBidding.db.profile.currentbidding
		
		DoMyBidding:OutputFullList()
		
		DoMyBidding.db.profile.currentbidding = {}
		DoMyBidding:CancelTimer(DoMyBidding.biddingTimer)
		return nil
	end
	
	-- if timer didn't expire yet, count down the last seconds
	rest = DoMyBidding.db.profile.currentbidding["endTime"] - time() 

	if rest <= 3 then
		if (rest > 0) then
			DoMyBidding:Output(L["Bidding ends in sec"](rest))
		end
		return nil
	end
	
end

function DoMyBidding:existsBid(compareBid)
	for name,bid in pairs(DoMyBidding.db.profile.currentbidding.bids) do 
		if bid == compareBid then return true end
	end
	return false
end

-- different times of incoming messages
function DoMyBidding:CHAT_MSG_WHISPER(event, text, sender)		if DoMyBidding.db.profile.acceptwhisper then	DoMyBidding:IncomingChat(text, sender) end end
function DoMyBidding:CHAT_MSG_PARTY(event, text, sender)		if DoMyBidding.db.profile.acceptraid then 		DoMyBidding:IncomingChat(text, sender) end end
function DoMyBidding:CHAT_MSG_PARTY_LEADER(event, text, sender)	if DoMyBidding.db.profile.acceptraid then 		DoMyBidding:IncomingChat(text, sender) end end
function DoMyBidding:CHAT_MSG_RAID(event, text, sender)			if DoMyBidding.db.profile.acceptraid then 		DoMyBidding:IncomingChat(text, sender) end end
function DoMyBidding:CHAT_MSG_RAID_LEADER(event, text, sender)	if DoMyBidding.db.profile.acceptraid then 		DoMyBidding:IncomingChat(text, sender) end end
function DoMyBidding:CHAT_MSG_RAID_WARNING(event, text, sender)	if DoMyBidding.db.profile.acceptraid then 		DoMyBidding:IncomingChat(text, sender) end end

function DoMyBidding:IncomingChat(text, sender)
	
	-- playerName may contain "-REALM"
	sender = strsplit("-", sender)
	
	if DoMyBidding.db.profile.currentbidding.itemLink == nil then
		-- no current bidding
		return nil
	end
	
	if text == "-" and DoMyBidding.db.profile.acceptrevoke then
		DoMyBidding.db.profile.currentbidding.bids[sender] = nil 
		SendChatMessage(L["You passed on itemLink"](DoMyBidding.db.profile.currentbidding.itemLink), "WHISPER", nil, sender)
		
		-- if I was max bid, need to set new maxbid
		local newmax = -1
		for name,bid in pairs(DoMyBidding.db.profile.currentbidding.bids) do 
			if bid > newmax then newmax = bid end
		end
		DoMyBidding.db.profile.currentbidding.maxBid = newmax
		return
	end
	
	trimmed = strtrim(text)
	if not string.match(trimmed, '^%d+$') then
		-- not a number, ignoring
		return nil
	end
	
	bid = tonumber(trimmed)
	
	
	if DoMyBidding.db.profile.whisperreceived then
		SendChatMessage(L["Received your bid bid for itemLink"](bid, DoMyBidding.db.profile.currentbidding.itemLink), "WHISPER", nil, sender)
	end
	
	
	-- if re-bidding not allowed, stop here
	if DoMyBidding.db.profile.acceptonce and not DoMyBidding.db.profile.currentbidding.bids[sender] == nil then
		DoMyBidding:Debug("User " .. sender .. " has bid before and bidding again is not allowed")
		if DoMyBidding.db.profile.whispernotaccepted then
			SendChatMessage(L["You already bid bid for itemLink"](DoMyBidding.db.profile.currentbidding.bids[sender], DoMyBidding.db.profile.currentbidding.itemLink), "WHISPER", nil, sender)
		end
		return nil
	end
	
	-- prolong also if someone matches max bid
	if DoMyBidding.db.profile.currentbidding.maxBid <= bid then
		-- prolong if needed
		if DoMyBidding.db.profile.currentbidding["endTime"] < time() + DoMyBidding.db.profile.bidprolong then
			DoMyBidding.db.profile.currentbidding["endTime"] = time() + DoMyBidding.db.profile.bidprolong
		end
	end	

	if DoMyBidding.db.profile.currentbidding.maxBid < bid then
		DoMyBidding.db.profile.currentbidding.maxBid = bid
		DoMyBidding.db.profile.currentbidding.announceNewMaxBid = true
	end	
	

	if DoMyBidding.db.profile.currentbidding.bids[sender] then
		-- this user has already given a bid
	
		DoMyBidding:Debug("A - User has bid before")

		if DoMyBidding.db.profile.currentbidding.bids[sender] < bid then
			DoMyBidding:Debug("B - Previous Bid was lower")

			-- find if somehas has bid that value already and if you can actually bid the same
			if (not DoMyBidding.db.profile.acceptsame) and DoMyBidding:existsBid(bid) then
				
				DoMyBidding:Debug("C - Someone else has that bid and we do not accept same bids")
				if DoMyBidding.db.profile.whispernotaccepted then
					SendChatMessage("Can not accept your bid " .. bid .. " for " .. DoMyBidding.db.profile.currentbidding.itemLink, "WHISPER", nil, sender)
				end
			
			else
			
				DoMyBidding:Debug("D - Same bids allowed or no one has entered that bid yet")
				DoMyBidding.db.profile.currentbidding.bids[sender] = bid
				if DoMyBidding.db.profile.whisperaccepted then
					SendChatMessage(L["Accepted your bid bid for itemLink"](bid, DoMyBidding.db.profile.currentbidding.itemLink), "WHISPER", nil, sender)
				end
			
			end
	
		else
			
			DoMyBidding:Debug("E - User has already bidded higher before")
			if DoMyBidding.db.profile.whispernotaccepted then
				SendChatMessage(L["You already bid bid for itemLink"](DoMyBidding.db.profile.currentbidding.bids[sender], DoMyBidding.db.profile.currentbidding.itemLink), "WHISPER", nil, sender)
			end
		end

	else
		-- first bid for this user
		DoMyBidding:Debug("F - User has NOT bid before")
		
		-- find if somehas has bid that value already and if you can actually bid the same
		if (not DoMyBidding.db.profile.acceptsame) and DoMyBidding:existsBid(bid) then
		
			DoMyBidding:Debug("G - Someone else has that bid and we do not accept same bids")
			if DoMyBidding.db.profile.whispernotaccepted then
				SendChatMessage("Can not accept your bid " .. bid .. " for " .. DoMyBidding.db.profile.currentbidding.itemLink, "WHISPER", nil, sender)
			end

		else

			DoMyBidding:Debug("H - Same bids allowed or no one has entered that bid yet")
			DoMyBidding.db.profile.currentbidding.bids[sender] = bid
			if DoMyBidding.db.profile.whisperaccepted then
				SendChatMessage(L["Accepted your bid bid for itemLink"](bid, DoMyBidding.db.profile.currentbidding.itemLink), "WHISPER", nil, sender)
			end
			
		end
		
	end
	
	if DoMyBidding.db.profile.currentbidding.bids[sender] < DoMyBidding.db.profile.currentbidding.maxBid and DoMyBidding.db.profile.whispertoolow then
		SendChatMessage(L["LOW BID! Your bid of bid for itemLink is NOT current max bid!"](DoMyBidding.db.profile.currentbidding.bids[sender],DoMyBidding.db.profile.currentbidding.itemLink), "WHISPER", nil, sender)
	end
	
end

function DoMyBidding:OutputRules()

	r = {}
	
	table.insert(r, "Bidding runs " .. DoMyBidding.db.profile.bidduration .. "sec")
	if DoMyBidding.db.profile.bidprolong > 0 then table.insert(r, "Bids extend time by " .. DoMyBidding.db.profile.bidprolong .. "sec") end
	
	table.insert(r, "Bids accepted " .. DoMyBidding:GetRulesWhere())
	
	if DoMyBidding.db.profile.acceptonce 	then table.insert(r, "Single bid per user (no increase)")	else table.insert(r, "Full auction, increases allowed")	end
	if DoMyBidding.db.profile.acceptsame 	then table.insert(r, "Same bids allowed") 					else table.insert(r, "No same bids allowed (first bid counts)") end
	if DoMyBidding.db.profile.acceptrevoke 	then table.insert(r, "Revoke by - possible") 				else table.insert(r, "No revocation of bids") end

	DoMyBidding:Output("Rules: " .. table.concat(r, " / "))
end

function DoMyBidding:GetRulesWhere()
	if DoMyBidding.db.profile.acceptraid and DoMyBidding.db.profile.acceptwhisper then
		return "in Chat or by Whisper to " .. UnitName("player") 
	else 
		if DoMyBidding.db.profile.acceptraid then 
			return "only in Chat"
		end
		if DoMyBidding.db.profile.acceptwhisper then 
			return "only by Whisper to " .. UnitName("player")
		end
	end	
end

function DoMyBidding:CHAT_MSG_SYSTEM (event, text )
	if DoMyBidding.db.profile.whispernoroll then 
		-- seems there is a problem with the german Umlaut
		if GetLocale() == 'deDE' then RANDOM_ROLL_RESULT = "%s w\195\188rfelt. Ergebnis: %d (%d-%d)" end
		local pattern = RANDOM_ROLL_RESULT:gsub( "%%s", "(.+)" ):gsub( "%%d %(%%d%-%%d%)", ".*" )
		local sender = text:match(pattern)
		
		if sender and not (DoMyBidding.db.profile.currentbidding.itemLink == nil) then
			SendChatMessage("We are bidding, not rolling. Please state your bid " .. DoMyBidding:GetRulesWhere(), "WHISPER", nil, sender)
		end
	end
end

