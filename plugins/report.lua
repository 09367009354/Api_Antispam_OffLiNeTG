local triggers = {
	'^/(c)$', --warn if not input
	'^/(c) (.*)',
	'^/(reply)$', --warn if not input
	'^/(reply) (.*)'
}

local action = function(msg, blocks, ln)
    
    -- ignore if the chat is a group or a supergroup
    if msg.chat.type ~= 'private' then
    	print('NO PV report.lua, '..msg.from.first_name..' ['..msg.from.id..'] --> not valid')
        return nil
    end
    
    if blocks[1] == 'c' then
    	
    	print('\n/c', msg.from.first_name..' ['..msg.from.id..']')
        
        local receiver = config.admin
        local input = blocks[2]
        
        --allert if not feedback
        if not input then
        	print('\27[31mNil: no text\27[39m')
        	local out = make_text(lang[ln].report.no_input)
            sendMessage(msg.from.id, out)
            return nil
        end
        
        local last_name = ''
        --if msg.from.last_name then
            --last_name = '\n*Last*: '..msg.from.last_name
        --end
        --local text = '*First*: '..msg.from.first_name..last_name..'\n*Username*: @'..msg.from.username..' ('..msg.from.id..')\n\n'..input
	    --sendMessage(receiver, text, true, false, true)
	    local target = msg.message_id
	    
	    mystat('c') --save stats
	    forwardMessage (receiver, msg.from.id, target)
	    local out = make_text(lang[ln].report.sent, input)
	    sendMessage(msg.from.id, out, true, false, true)
	end
	
	if blocks[1] == 'reply' then
		
		print('\n/reply', msg.from.first_name..' ['..msg.from.id..']')
		
	    --ignore if not admin
	    if msg.from.id ~= config.admin then
	    	print('\27[31mNil: not admin\27[39m')
	        return nil
	    end
	    
	    --ignore if no reply
	    if not msg.reply_to_message then
	    	print('\27[31mNil: no reply\27[39m')
	    	local out = make_text(lang[ln].report.reply)
            sendReply(msg, out, false)
			return nil
		end
		
		local input = blocks[2]
		
		--ignore if not imput
		if not input then
			print('\27[31mNil: no input text\27[39m')
			local out = make_text(lang[ln].report.reply_no_input)
            sendMessage(msg.from.id, out)
            return nil
        end
		
		msg = msg.reply_to_message
		local name = msg.forward_from.first_name
		local receiver = msg.forward_from.id
		local feed = msg.text:sub(4, 14)
		local out = make_text(lang[ln].report.feedback_reply, name, feed, input)
		
		sendMessage(receiver, out, true, false, true)
		sendMessage(config.admin, make_text(lang[ln].report.reply_sent, input), true, false, true)
	end
end

return {
	action = action,
	triggers = triggers
}