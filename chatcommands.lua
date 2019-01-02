local function tablejoin(t, i, j)
	local s = ""
	local k

	if not i then i = 1 end
	if not j then j = #t end

	for k=i,j do
		s = s.." "..t[k]
	end

	return s
end

minetest.register_chatcommand("channel", {
	description = "Manages chat channels",
	privs = {
		interact = true, 
		shout = true
	},
	func = function(name, param)
		if param == "" then
			minetest.chat_send_player(name, "Online players: /channel online")
			minetest.chat_send_player(name, "Join/switch:    /channel join <channel>")
			minetest.chat_send_player(name, "Leave channel:  /channel leave")
			minetest.chat_send_player(name, "Invite to channel:  /channel invite <playername>")
			return

		elseif param == "online" then
			channels.command_online(name)
			return

		elseif param == "leave" then
			channels.command_leave(name)
			return
		end


		local args = param:split(" ")

		if args[1] == "join" and #args >= 2 then
			channels.command_set(name, args[2])
			return

        elseif args[1] == "invite" and #args == 2 then
            channels.command_invite(name, args[2])
            return

		elseif args[1] == "wall" and #args >= 2 then
			channels.command_wall(name, tablejoin(args,2) )
			return
		end

		minetest.chat_send_player(name, "Error: Please check again '/channel' for correct usage.")
	end,
})

function channels.say_chat(name, message, channel)
    -- message must already have '<player name>' at start if from a player
	minetest.log("action","CHAT: #"..tostring(channel or "no channel").." "..message)

    local all_players = minetest.get_connected_players()

    for _,player in ipairs(all_players) do
        local playername = player:get_player_name()
        if channels.players[playername] == channel then -- if nil then send to players in global chat
            minetest.chat_send_player(playername, message)
        end
    end
end

function channels.command_invite(hoster,guest)
    local channelname = channels.players[hoster]
    if not channelname then
        channelname = "the global chat"
    else
        channelname = "the '"..channelname.."' chat channel."
    end

    minetest.chat_send_player(guest, hoster.." invites you to join "..channelname)
    minetest.chat_send_player(hoster, guest.." was invited to join "..channelname)
end

function channels.command_wall(name, message)
	local playerprivs = minetest.get_player_privs(name)
	if not playerprivs.basic_privs then
		minetest.chat_send_player(name, "Error - require 'basic_privs' privilege.")
		return
	end

	minetest.chat_send_all("(Announcement from "..name.."): "..message)
end

function channels.command_online(name)
	local channel = channels.players[name]
	local players = "You"
	if channel then
		for k,v in pairs(channels.players) do
			if v == channel and k ~= name then
				players = players..", "..k
			end
		end
	else
		local oplayers = minetest.get_connected_players()
		for _,player in ipairs(oplayers) do
			local p_name = player:get_player_name()
			if not channels.players[p_name] and p_name ~= name then
				players = players..", "..p_name
			end
		end
		return
	end
	
	minetest.chat_send_player(name, "Online players in this channel: "..players)
end

function channels.command_set(name, param)
	if param == "" then
		minetest.chat_send_player(name, "Error: Empty channel name")
		return
	end
	
	local channel_old = channels.players[name]
	if channel_old then
		if channel_old == param then
			minetest.chat_send_player(name, "Error: You are already in this channel")
			return
		end
		channels.say_chat(name, "# "..name.." left the channel", channel_old)
	else
		local oplayers = minetest.get_connected_players()
		for _,player in ipairs(oplayers) do
			local p_name = player:get_player_name()
			if not channels.players[p_name] and p_name ~= name and channels.allow_global_channel then
				minetest.chat_send_player(p_name, "# "..name.." left the global chat")
			end
		end
	end
	
	local player = minetest.get_player_by_name(name)
	if not player then
		return
	end
	
	if channels.huds[name] then
		player:hud_remove(channels.huds[name])
	end
	
	channels.players[name] = param
	channels.huds[name] = player:hud_add({
		hud_elem_type	= "text",
		name		= "Channel",
		number		= 0xFFFFFF,
		position	= {x = 0.6, y = 0.03},
		text		= "Channel: "..param,
		scale		= {x = 200,y = 25},
		alignment	= {x = 0, y = 0},
	})
	channels.say_chat("", "# "..name.." joined the channel", param)
end

function channels.command_leave(name)
	local player = minetest.get_player_by_name(name)
	if not player then
		channels.players[name] = nil
		channels.huds[name] = nil
		return
	end
	
	if not (channels.players[name] and channels.huds[name]) then
		minetest.chat_send_player(name, "Please join a channel first to leave it")
		return
	end
	
	if channels.players[name] then
		channels.say_chat("", "# "..name.." left the channel", channels.players[name])
		channels.players[name] = nil
	end
	
	if channels.huds[name] then
		player:hud_remove(channels.huds[name])
		channels.huds[name] = nil
	end
end
