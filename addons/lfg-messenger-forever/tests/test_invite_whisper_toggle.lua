local Q = {}
assert(loadfile("addons/lfg-messenger-forever/addon/Core.lua"))("LFGMessengerForever", Q)

LFGMessengerForeverDB = {}
Q.InitializeDB()
Q.Print = function() end
Q.GetResultPlayer = function()
    return {name = "Helpfulplayer", role = "DPS", info = {}}
end
Q.GetResultActivity = function() return "Deadmines" end

local invites, whispers = 0, 0
local invitedName, whisperedRole
local function invite(name)
    invites = invites + 1
    invitedName = name
    return true
end
Q.SendInviteWhisper = function(_, _, role)
    whispers = whispers + 1
    whisperedRole = role
    return true
end

assert(Q.db.inviteWhispers == true, "invite follow-up whispers should default on")
assert(Q.InviteResult(1, invite), "an enabled invite should succeed")
assert(invites == 1 and whispers == 1, "an enabled invite should send one follow-up whisper")
assert(invitedName == "Helpfulplayer", "the exact clicked player's name should be invited")
assert(whisperedRole == "DPS", "the whisper should use the clicked player's actual role")

Q.db.inviteWhispers = false
assert(Q.InviteResult(1, invite), "an invite should still succeed when follow-up whispers are off")
assert(invites == 2 and whispers == 1, "the opt-out should suppress only the invite follow-up whisper")

assert(Q.WhisperForResult(1), "Quick Whisper should remain available")
assert(whispers == 2, "Quick Whisper should not be disabled by the invite setting")

print("Looking for Group invite-whisper toggle tests passed")
