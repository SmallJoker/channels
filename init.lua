channels = {}
channels.huds = {}
channels.players = {}

-- workaround for settings:get*() defaults not working
local function notnil_or(d,v)
    if v == nil then
        return d
    end

    return v
end

channels.allow_global_channel = notnil_or(true, minetest.settings:get_bool("channels.allow_global_channel") )
channels.disable_private_messages = notnil_or(false, minetest.settings:get_bool("channels.disable_private_messages") )
channels.suggested_channel = minetest.settings:get_bool("channels.suggested_channel")

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

channels.remind_global_off = function()
    -- Can be called by other mods

    if not channels.allow_global_channel and channels.suggested_channel then
        channels.say_chat("*server*", "<announcement from *server*> Out-of-channel chat is off. (try '/channel join "..channels.suggested_channel.."' ?)")
    end
end

if not channels.allow_global_channel then
    local global_inhibition_counter = 0 -- local to the file

    minetest.register_globalstep(function(dtime)
        global_inhibition_counter = global_inhibition_counter + dtime
        if global_inhibition_counter > 5*60 then
            global_inhibition_counter = 0
        else
            return
        end

        channels.remind_global_off()
    end)
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
