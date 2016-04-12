local triggers = {
	'^/(flood) (%d%d?)$',
	'^/(flood) (on)$',
	'^/(flood) (off)$',
	'^/(flood) (kick)$',
	'^/(flood) (ban)$',
	'^(flood)$'
}

local action = function(msg, blocks, ln)
	
	--ceck if admin here
	
	--if msg.chat.type == 'private' then
	    --sendMessage(msg.chat.id, lang[ln].pv)
	    --return
	--end
	if not blocks[2] then
		
	else
		if blocks[2] == '%d%d?' then
	    	local new = tonumber(blocks[2])
	    	local old = tonumber(client:hget('chat:'..msg.chat.id..':flood', 'MaxFlood')) or 5
	    	print(old, new)
	    	if new == old then
	        	sendReply(msg.chat.id, make_text(lang[ln].floodmanager.not_changed, new))
	    	else
	        	client:hset('chat:'..msg.chat.id..':flood', 'MaxFlood', new)
	        	sendReply(msg, make_text(lang[ln].floodmanager.changed, old, new))
	    	end
		else
			--yes/no = disabled, so: yes->yes, disabled, no->no, not diabled
        	if blocks[2] == 'on' then
            	client:hset('chat:'..msg.chat.id..':settings', 'Flood', 'no')
            	sendReply(msg, lang[ln].floodmanager.enabled)
        	elseif blocks[2] == 'off' then
            	client:hset('chat:'..msg.chat.id..':settings', 'Flood', 'yes')
            	sendReply(msg, lang[ln].floodmanager.disabled)
        	elseif blocks[2] == 'ban' then
            	client:hset('chat:'..msg.chat.id..':flood', 'ActionFlood', 'ban')
            	sendReply(msg, lang[ln].floodmanager.ban)
        	elseif blocks[2] == 'kick' then
            	client:hset('chat:'..msg.chat.id..':flood', 'ActionFlood', 'kick')
            	sendReply(msg, lang[ln].floodmanager.kick)
        	end
        end
    end
    
	
	mystat('floodmanager') --save stats
end

return {
	action = action,
	triggers = triggers
}