channels = {}
channels.huds = {}
channels.players = {}

local function nil_or(d,v)
    if v == nil then
        return d
    end

    return v
end

channels.allow_global_channel = nil_or(true, minetest.settings:get_bool("channels.allow_global_channel") )
channels.disable_private_messages = nil_or(false, minetest.settings:get_bool("channels.disable_private_messages") )

dofile(minetest.get_modpath("channels").."/chatcommands.lua")

if channels.disable_private_messages then
    minetest.register_chatcommand("msg", {
        params = "",
        description = "?",
        privs = nil,
        func = function(name, param)
            return true, "(private messages disabled)"
        end,
    })
end

minetest.register_on_chat_message(function(name, message)
	local pl_channel = channels.players[name]

	if pl_channel == "" then
		channels.players[name] = nil
        pl_channel = nil
	end

	if not pl_channel then
        if not channels.allow_global_channel then
            minetest.chat_send_player(name, "No channel selected. Run '/channel' for more info")
            -- return true to prevent subsequent/global handler from kicking in
            return true
        else
            -- return false to indicate we have not handled the chat
            return false
        end
	end
	
	channels.say_chat(name, "<"..name.."> "..message, pl_channel)
	return true
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	channels.players[name] = nil
	channels.huds[name] = nil
end)
