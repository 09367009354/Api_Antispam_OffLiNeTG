local triggers = {
	'^/(link)$',
	'^/(link)@groupbutler_bot$',
	'^/(setlink) https://telegram%.me/joinchat/(.*)',
	'^/(setlink) (no)',
	'^/(poll)$',
	'^/(setpoll) (.*) telegram%.me/PollBot%?start=(.*)',
	'^/(setpoll) (no)$'
}

local action = function(msg, blocks, ln)
	
	--return nil if wrote in private
    if msg.chat.type == 'private' then
        print('PV links.lua, '..msg.from.first_name..' ['..msg.from.id..'] --> not valid')
        local out = make_text(lang[ln].pv)
        api.sendMessage(msg.from.id, out)
    	return nil
    end
	
	--initialize the hash
	local hash = 'chat:'..msg.chat.id..'links'
	local text
	
	if blocks[1] == 'link' then
		
		print('\n/link', msg.from.first_name..' ['..msg.from.id..']')
		
		--ignore if not mod
		if not is_mod(msg) then
			print('\27[31mNil: not mod\27[39m')
			return
		end
		
		local key = 'link'
		local link = client:hget(hash, key)
		
		--check if link is nil or nul
		if link == 'no' or link == nil then
			text = make_text(lang[ln].links.no_link)
		else
			text = make_text(lang[ln].links.link, msg.chat.title, link)
		end
		
		mystat('link') --save stats
		api.sendReply(msg, text, true)
	end
	
	if blocks[1] == 'setlink' then
		
		print('\n/setlink', msg.from.first_name..' ['..msg.from.id..']')
		
		--ignore if not owner
		if not is_owner(msg) then
			print('\27[31mNil: not the owner\27[39m')
			return
		end
		
		--warn if the link has not the right lenght
		if string.len(blocks[2]) ~= 22 and blocks[2] ~= 'no' then
			print('\27[31mNil: wrong link\27[39m')
			local out = make_text(lang[ln].links.link_invalid)
			api.sendReply(msg, out, true)
			return
		end
		
		local link = 'https://telegram.me/joinchat/'..blocks[2]
		local key = 'link'
		
		--set to nul the link, or update/set it
		if blocks[2] == 'no' then
			client:hset(hash, key, 'no')
			text = make_text(lang[ln].links.link_unsetted)
		else
			local succ = client:hset(hash, key, link)
			if succ == false then
				text = make_text(lang[ln].links.link_updated, msg.chat.title, link)
			else
				text = make_text(lang[ln].links.link_setted, msg.chat.title, link)
			end
		end
			
		mystat('setlink') --save stats
		api.sendReply(msg, text, true)
	end
	
	if blocks[1] == 'setpoll' then
		
		print('\n/setpoll', msg.from.first_name..' ['..msg.from.id..']')
		
		--ignore if not owner
		if not is_mod(msg) then
			print('\27[31mNil: not a mod\27[39m')
			return
		end
		
		--warn if the link has not the right lenght
		if blocks[2] ~= 'no' and string.len(blocks[3]) ~= 36 then
			print('\27[31mNil: wrong link\27[39m')
			local out = make_text(lang[ln].links.link_invalid)
			sendReply(msg, out, true)
			return
		end
		
		local key = 'poll'
		
		--set to nul the poll, or update/set it
		if blocks[2] == 'no' then
			client:hset(hash, key, 'no')
			text = make_text(lang[ln].links.poll_unsetted)
		else
			local link = 'telegram.me/PollBot?start='..blocks[3]
			local succ = client:hset(hash, key, link)
			local description = blocks[2]
			
			--save description of the poll in redis
			client:hset(hash, 'polldesc', description)
			if succ == false then
				text = make_text(lang[ln].links.poll_updated, description, link)
			else
				text = make_text(lang[ln].links.poll_setted, description, link)
			end
		end
			
		mystat('setpoll') --save stats
		api.sendReply(msg, text, true)
		
end

	if blocks[1] == 'poll' then
		
		print('\n/poll', msg.from.first_name..' ['..msg.from.id..']')
		
		--ignore if not mod
		if not is_mod(msg) then
			print('\27[31mNil: not mod\27[39m')
			return
		end
		
		local key = 'poll'
		local link = client:hget(hash, key)
		local description = client:hget(hash, 'polldesc')
		
		--check if link is nil or nul
		if link == 'no' or link == nil then
			text = make_text(lang[ln].links.no_poll)
		else
			text = make_text(lang[ln].links.poll, description, link)
		end
		
		mystat('poll') --save stats
		api.sendReply(msg, text, true)
		
	end
end

return {
	action = action,
	triggers = triggers
}