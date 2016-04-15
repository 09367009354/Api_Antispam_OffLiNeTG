
local triggers = {
	'^###(botadded)',
	'^###(added)',
	'^###(botremoved)'
}

local function remove_from_kicked_list(chat, user)
    local hash = 'kicked:'..chat
    client:hdel(hash, user)
end

local action = function(msg, blocks, ln)
	
	--vardump(msg)
	
	--if the bot join the chat
	if blocks[1] == 'botadded' then
		
		print('Bot added to '..msg.chat.title..' ['..msg.chat.id..']')
		
		local uname = ''
		
		--check if the owner has a username, and save it. If not, use the name
		local jsoname = msg.from.first_name
		if msg.from.username then
			jsoname = '@'..tostring(msg.from.username)
		end
		
		--save group data in the json
		groups = load_data('groups.json')
		groups[tostring(msg.chat.id)] = {
			rules = nil,
			about = nil,
			flag_blocked = {},
		}
		
		save_data('groups.json', groups)
		
		--add owner as moderator
		local hash = 'bot:'..msg.chat.id..':mod'
        local user = tostring(msg.from.id)
        client:hset(hash, user, jsoname)
        
        --add owner as owner
        hash = 'bot:'..msg.chat.id..':owner'
        client:hset(hash, user, jsoname)
		
		--default settings
		hash = 'chat:'..msg.chat.id..':settings'
		--disabled for users:yes / disabled fo users:no
		client:hset(hash, 'Rules', 'no')
		client:hset(hash, 'About', 'no')
		client:hset(hash, 'Modlist', 'no')
		client:hset(hash, 'Flag', 'yes')
		client:hset(hash, 'Welcome', 'no')
		client:hset(hash, 'Extra', 'no')
		client:hset(hash, 'Rtl', 'no')
		client:hset(hash, 'Arab', 'no')
		client:hset(hash, 'Flood', 'no')--flood
		--flood
		hash = 'chat:'..msg.chat.id..':flood'
		client:hset(hash, 'MaxFlood', 5)
		client:hset(hash, 'ActionFlood', 'kick')
		--warn
		client:set('warns:'..msg.chat.id..':max', 5)
		client:set('warns:'..msg.chat.id..':action', 'ban')
		--media moderation don't need to be setted up
		--set the default welcome type
		hash = 'chat:'..msg.chat.id..':welcome'
		client:hset(hash, 'wel', 'no')
		
		--save stats
		hash = 'bot:general'
        local num = client:hincrby(hash, 'groups', 1)
        print('Stats saved', 'Groups: '..num)
        local out = make_text(lang[ln].service.new_group, msg.from.first_name)
		sendMessage(msg.chat.id, out, true, false, true)
	end
	
	--if someone join the chat
	if blocks[1] == 'added' then
		
		remove_from_kicked_list(msg.chat.id, msg.added.id)
		
		--basic text
		text = make_text(lang[ln].service.welcome, msg.added.first_name, msg.chat.title)
		--text = 'Hi '..msg.new_chat_participant.first_name..', and welcome to *'..msg.chat.title..'*!'
		
		--ignore if welcome is locked
		if is_locked(msg, 'Welcome') then
			print('\27[31mNil: welcome diabled\27[39m')
			return nil
		end
		
		groups = load_data('groups.json')
		
		--retrive welcome settings 
		local wlc_sett = client:hget('chat:'..msg.chat.id..':welcome', 'wel')
		
		local abt = groups[tostring(msg.chat.id)]['about']
		local rls = groups[tostring(msg.chat.id)]['rules']
		local mods
		
		--check if the group has a decription
		if not abt then
            abt = lang[ln].service.welcome_abt
        end
		
		--check if the group has rules
		if not rls then
            rls = lang[ln].service.welcome_rls
        end		
		
		--build the modlist
		local hash = 'bot:'..msg.chat.id..':mod'
    	local mlist = client:hvals(hash) --the array can't be empty: there is always the owner in the modlist
    	local mods = lang[ln].service.welcome_modlist
    	for i=1, #mlist do
        	mods = mods..'*'..i..'* - '..mlist[i]..'\n'
    	end
		
		--read welcome settings and build the message
		if wlc_sett == 'a' then
			text = text..lang[ln].service.abt..abt
		elseif wlc_sett == 'r' then
			text = text..lang[ln].service.rls..rls
		elseif wlc_sett == 'm' then
			text = text..mods
		elseif wlc_sett == 'ra' then
			text = text..lang[ln].service.abt..abt..lang[ln].service.rls..rls
    	elseif wlc_sett == 'am' then
			text = text..lang[ln].service.abt..abt..mods
    	elseif wlc_sett == 'rm' then
			text = text..lang[ln].service.rls..rls..mods
		elseif wlc_sett == 'ram' then
			text = text..lang[ln].service.abt..abt..lang[ln].service.rls..rls..mods
		end
		
		sendMessage(msg.chat.id, text, true, false, true)
	end
	
	--if the bot is removed from the chat
	if blocks[1] == 'botremoved' then
		
		print('Bot left '..msg.chat.title..' ['..msg.chat.id..']')
		
		--clean the modlist and the owner. If the bot is added again, the owner will be who added the bot and the modlist will be empty (except for the new owner)
		clean_owner_modlist(msg.chat.id)
		
		--save stats
        local num = client:hincrby('bot:general', 'groups', -1)
        print('Stats saved', 'Groups: '..num)
        local out = make_text(lang[ln].service.bot_removed, msg.chat.title)
		sendMessage(msg.remover.id, out, true, false, true)
	end

end

return {
	action = action,
	triggers = triggers
}
