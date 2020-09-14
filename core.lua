local L = LibStub("AceLocale-3.0"):GetLocale("DoMyBidding", true)

local defaults = {
  profile = {
    debug = false,
	handle_bid = false,
	handle_auction = false,
	bidduration = 15,
	bidprolong = 5,
	acceptraid = true,
	acceptwhisper = true,
	acceptonce = true,
	acceptsame = true,
	acceptrevoke = true,
	showcountdown = true,
	shownewmax = true,
	whisperreceived = true,
	whisperaccepted = true,
	whispernotaccepted = true,
	whispertoolow = true,
	whisperoutbid = true,
	whispernoroll = true,
	outputfull_raid = false,
	outputfull_user = true,
  }
}

DoMyBidding.dmbOptionsTable = {
  type = "group",
  args = {
	txttime = { type = "header", name = "Timings", order = 100},
	
	duration = {
		name = L["Bid duration"],
		desc = L["Initial time for a bid"],
		type = "range",
		min = 0,
		softMax = 60,
		step = 1,
		order = 110,
		set = function(info,val) DoMyBidding.db.profile.bidduration = val end,
		get = function(info) return DoMyBidding.db.profile.bidduration end,
	},
	newline111 = { name="", type="description", order=111 },

	prolong = {
		name = L["Bids prolong"],
		desc = L["If a new bid came in, prolong time to end if necessary"],
		type = "range",
		min = 0,
		softMax = 30,
		step = 1,
		order = 120,
		set = function(info,val) DoMyBidding.db.profile.bidprolong = val end,
		get = function(info) return DoMyBidding.db.profile.bidprolong end,
	},
	newline121 = { name="", type="description", order=121 },

	txtaccepts = { type = "header", name = "Accept bids", order = 200 },
	
	bidraid = {
		name = "Raid",
		desc = "Accept bidding in party/raidchat",
		type = "toggle",
		order = 210,
		set = function(info,val)
			DoMyBidding.db.profile.acceptraid = val 
			if not DoMyBidding.db.profile.acceptraid then DoMyBidding.db.profile.acceptwhisper = true end
		end,
		get = function(info) return DoMyBidding.db.profile.acceptraid end,
	},
	newline211 = { name="", type="description", order=211 },

	bidwhisper = {
		name = "Whisper",
		desc = "Accept bidding by whisper",
		type = "toggle",
		order = 220,
		set = function(info,val)
			DoMyBidding.db.profile.acceptwhisper = val
			if not DoMyBidding.db.profile.acceptwhisper then DoMyBidding.db.profile.acceptraid = true end
		end,
		get = function(info) return DoMyBidding.db.profile.acceptwhisper end,
	},
	newline221 = { name="", type="description", order=221 },

	bidagain = {
		name = "Only once",
		desc = "Accept only first bid (disables revocation)",
		type = "toggle",
		order = 230,
		set = function(info,val) 
			DoMyBidding.db.profile.acceptonce = val 
			if not DoMyBidding.db.profile.acceptonce then DoMyBidding.db.profile.acceptrevoke = false end
		end,
		get = function(info) return DoMyBidding.db.profile.acceptonce end,
	},
	newline231 = { name="", type="description", order=231 },

	bidsame = {
		name = "Same amount",
		desc = "Accept same amount bids (if disabled: earliest bid wins)",
		type = "toggle",
		order = 240,
		set = function(info,val) DoMyBidding.db.profile.acceptsame = val end,
		get = function(info) return DoMyBidding.db.profile.acceptsame end,
	},
	newline241 = { name="", type="description", order=241 },

	revoke = {
		name = "Revoke bid",
		desc = "Allows users to revoke bid (disables only once)",
		type = "toggle",
		order = 250,
		set = function(info,val) 
			DoMyBidding.db.profile.acceptrevoke = val
			if not DoMyBidding.db.profile.acceptrevoke then DoMyBidding.db.profile.acceptonce = false end
		end,
		get = function(info) return DoMyBidding.db.profile.acceptrevoke end,
	},
	newline251 = { name="", type="description", order=251 },

	txtoutput = { type = "header", name = "Raid announces", order = 300 },
	
	countdown = {
		name = "Countdown",
		desc = "Give Countdown in raid/party chat",
		type = "toggle",
		order = 310,
		set = function(info,val) DoMyBidding.db.profile.showcountdown = val end,
		get = function(info) return DoMyBidding.db.profile.showcountdown end,
	},
	newline311 = { name="", type="description", order=311 },
	
	newmax = {
		name = "New max",
		desc = "Announce new max bids to raidchat",
		type = "toggle",
		order = 320,
		set = function(info,val) DoMyBidding.db.profile.shownewmax = val end,
		get = function(info) return DoMyBidding.db.profile.shownewmax end,
	},
	newline321 = { name="", type="description", order=321 },

	outputfullraid = {
		name = "List to Raid",
		desc = "Outputs full list to raid/party on finish (disables output to user)",
		type = "toggle",
		order = 330,
		set = function(info,val)
			DoMyBidding.db.profile.outputfull_raid = val 
			if DoMyBidding.db.profile.outputfull_raid then DoMyBidding.db.profile.outputfull_user = false end
		end,
		get = function(info) return DoMyBidding.db.profile.outputfull_raid end,
	},
	newline331 = { name="", type="description", order=331 },
	
	txtwhispers = { type = "header", name = "Whisper announces", order = 400 },

	received = {
		name = "Received",
		desc = "Whisper to player if bid was received",
		type = "toggle",
		order = 410,
		set = function(info,val) DoMyBidding.db.profile.whisperreceived = val end,
		get = function(info) return DoMyBidding.db.profile.whisperreceived end,
	},
	newline411 = { name="", type="description", order=411 },

	accepted = {
		name = "Accepted",
		desc = "Whisper to player if bid was accepted (disables received whisper)",
		type = "toggle",
		order = 420,
		set = function(info,val) 
			DoMyBidding.db.profile.whisperaccepted = val 
			if DoMyBidding.db.profile.whisperaccepted then DoMyBidding.db.profile.whisperreceived = false end
		end,
		get = function(info) return DoMyBidding.db.profile.whisperaccepted end,
	},
	newline421 = { name="", type="description", order=421 },
	
	notaccepted = {
		name = "Not accepted",
		desc = "Whisper to player if bid was not accepted (disables received whisper)",
		type = "toggle",
		order = 430,
		set = function(info,val)
			DoMyBidding.db.profile.whispernotaccepted = val 
			if DoMyBidding.db.profile.whispernotaccepted then DoMyBidding.db.profile.whisperreceived = false end
			if not DoMyBidding.db.profile.whispernotaccepted then DoMyBidding.db.profile.whispertoolow = false end
		end,
		get = function(info) return DoMyBidding.db.profile.whispernotaccepted end,
	},
	toolow = {
		name = "Too low",
		desc = "Whisper to player if bid was lower than current max",
		type = "toggle",
		order = 435,
		set = function(info,val) 
			DoMyBidding.db.profile.whispertoolow = val
			if DoMyBidding.db.profile.whispertoolow then DoMyBidding.db.profile.whispernotaccepted = true end
		end,
		get = function(info) return DoMyBidding.db.profile.whispertoolow end,
	},
	newline439 = { name="", type="description", order=439 },


	outbid = {
		name = "Outbid",
		desc = "Whisper to player if another higher bid was received",
		type = "toggle",
		order = 440,
		set = function(info,val) DoMyBidding.db.profile.whisperoutbid	= val end,
		get = function(info) return DoMyBidding.db.profile.whisperoutbid end,
	},
	newline441 = { name="", type="description", order=441 },

	norolls = {
		name = "No rolls",
		desc = "Tells the player to bid if he rolls during bidding",
		type = "toggle",
		order = 450,
		set = function(info,val) DoMyBidding.db.profile.whispernoroll = val end,
		get = function(info) return DoMyBidding.db.profile.whispernoroll end,
	},
	newline451 = { name="", type="description", order=451 },

	txtpresets = { type = "header", name = "Presets", order = 800 },
	
	openbiddings = {
		name = "Open Bidding",
		desc = "Open bidding in raid chat, with max & low announces, same bidding allowed, bid again allowed",
		type = "execute",
		order = 810,
		func = function() 
			DoMyBidding.db.profile.acceptraid = true
			DoMyBidding.db.profile.acceptwhisper = false
			DoMyBidding.db.profile.acceptonce = false
			DoMyBidding.db.profile.acceptsame = true
			DoMyBidding.db.profile.acceptrevoke = true
			DoMyBidding.db.profile.showcountdown = true
			DoMyBidding.db.profile.shownewmax = true
			DoMyBidding.db.profile.whisperaccepted = true
			DoMyBidding.db.profile.whispernotaccepted = true
			DoMyBidding.db.profile.whispertoolow = true
			DoMyBidding.db.profile.whisperoutbid = true
			DoMyBidding.db.profile.outputfull_raid = false
			DoMyBidding.db.profile.outputfull_user = true
		end,
	},
	newline811 = { name="", type="description", order=811 },

	silentbiddings = {
		name = "Silent Bidding",
		desc = "Silent bidding by whisper, no max / low announces, first bid wins",
		type = "execute",
		order = 820,
		func = function() 
			DoMyBidding.db.profile.acceptraid = false
			DoMyBidding.db.profile.acceptwhisper = true
			DoMyBidding.db.profile.acceptonce = true
			DoMyBidding.db.profile.acceptsame = false
			DoMyBidding.db.profile.acceptrevoke = false
			DoMyBidding.db.profile.showcountdown = true
			DoMyBidding.db.profile.shownewmax = false
			DoMyBidding.db.profile.whisperreceived = true
			DoMyBidding.db.profile.whisperaccepted = false
			DoMyBidding.db.profile.whispernotaccepted = false
			DoMyBidding.db.profile.whispertoolow = false
			DoMyBidding.db.profile.whisperoutbid = false
			DoMyBidding.db.profile.outputfull_raid = false
			DoMyBidding.db.profile.outputfull_user = true
		end,
	},
	newline821 = { name="", type="description", order=821 },

	txtdebug = { type = "header", name = "Miscellaneous", order = 900 },
	
    bidhandler = {
      name = "/bid",
      type = "toggle",
      order = 910,
      set = function(info,val)
		DoMyBidding.db.profile.handle_bid = val 
		if DoMyBidding.db.profile.handle_bid then
			DoMyBidding:RegisterChatCommand('bid', 'ChatCommandDMB');
		else
			DoMyBidding:UnregisterChatCommand('bid');
		end

	  end,
      get = function(info) return DoMyBidding.db.profile.handle_bid end,
    },
	newline911 = { name="", type="description", order=911 },

    auctionhandler = {
      name = "/auction",
      type = "toggle",
      order = 920,
      set = function(info,val)
		DoMyBidding.db.profile.handle_auction = val 
		if DoMyBidding.db.profile.handle_auction then
			DoMyBidding:RegisterChatCommand('auction', 'ChatCommandDMB');
		else
			DoMyBidding:UnregisterChatCommand('auction');
		end

	  end,
      get = function(info) return DoMyBidding.db.profile.handle_auction end,
    },
	newline921 = { name="", type="description", order=921 },

	outputfulluser = {
		name = "List to User",
		desc = "Outputs full list to user on finish (disables output to raid/party)",
		type = "toggle",
		order = 930,
		set = function(info,val)
			DoMyBidding.db.profile.outputfull_user = val 
			if DoMyBidding.db.profile.outputfull_user then DoMyBidding.db.profile.outputfull_raid = false end
		end,
		get = function(info) return DoMyBidding.db.profile.outputfull_user end,
	},
	newline931 = { name="", type="description", order=931 },


    debugging = {
      name = L["Debug"],
      type = "toggle",
      order = 990,
      set = function(info,val) DoMyBidding.db.profile.debug = val end,
      get = function(info) return DoMyBidding.db.profile.debug end,
    },
	newline991 = { name="", type="description", order=991 },

  }
}

function DoMyBidding:OnInitialize()
  -- Code that you want to run when the addon is first loaded goes here.
  self.db = LibStub("AceDB-3.0"):New("DoMyBiddingDB", defaults)

  LibStub("AceConfig-3.0"):RegisterOptionsTable("DoMyBidding", self.dmbOptionsTable)
  self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DoMyBidding", "DoMyBidding")
  
  -- interaction from raid members
  self:RegisterEvent("CHAT_MSG_WHISPER")
  self:RegisterEvent("CHAT_MSG_PARTY")
  self:RegisterEvent("CHAT_MSG_PARTY_LEADER")
  self:RegisterEvent("CHAT_MSG_RAID")
  self:RegisterEvent("CHAT_MSG_RAID_LEADER")
  self:RegisterEvent("CHAT_MSG_RAID_WARNING")
  self:RegisterEvent("CHAT_MSG_SYSTEM")
 
  self:RegisterChatCommand("dmb", "ChatCommandDMB")
  
  if self.db.profile.handle_bid then
	self:RegisterChatCommand("bid", "ChatCommandDMB");
  end

  if self.db.profile.handle_auction then
	self:RegisterChatCommand("auction", "ChatCommandDMB");
  end
  
  self.onetimes = {}
  
  -- resetting possible old rolls
  self.db.profile.currentbidding = {}
  
end

function DoMyBidding:OnEnable()
    -- Called when the addon is enabled
end

function DoMyBidding:OnDisable()
    -- Called when the addon is disabled
end


function DoMyBidding:ChatCommandDMB(inc)

	if strtrim(inc) == "" then
		DoMyBidding:Print(L["Usage: |cFF00CCFF/dmb |cFFA335EE[Sword of a Thousand Truths]|r to start a bid"])
		DoMyBidding:Print(L["Usage: |cFF00CCFF/dmb config|r to open the configuration window"])
		return nil
	end

	if strlower(inc) == "config" then
		LibStub("AceConfigDialog-3.0"):Open("DoMyBidding")
		return nil
	end

	if strlower(inc) == "rules" then
		DoMyBidding:OutputRules()
		return nil
	end


	-- if inc is itemLink: start bidding
	local d, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId, linkLevel, specializationID, reforgeId, unknown1, unknown2 = strsplit(":", inc)		
	if itemId then
		DoMyBidding:StartBidding(inc)
		return nil
	end
	
end


function DoMyBidding:Debug(t) 
	if (DoMyBidding.db.profile.debug) then
		DoMyBidding:Print("DoMyBidding DEBUG: " .. t)
	end
end


-- for debug outputs
function tprint (tbl, indent)
  if not indent then indent = 0 end
  local toprint = string.rep(" ", indent) .. "{\r\n"
  indent = indent + 2 
  for k, v in pairs(tbl) do
    toprint = toprint .. string.rep(" ", indent)
    if (type(k) == "number") then
      toprint = toprint .. "[" .. k .. "] = "
    elseif (type(k) == "string") then
      toprint = toprint  .. k ..  "= "   
    end
    if (type(v) == "number") then
      toprint = toprint .. v .. ",\r\n"
    elseif (type(v) == "string") then
      toprint = toprint .. "\"" .. v .. "\",\r\n"
    elseif (type(v) == "table") then
      toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
    else
      toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
    end
  end
  toprint = toprint .. string.rep(" ", indent-2) .. "}"
  return toprint
end
