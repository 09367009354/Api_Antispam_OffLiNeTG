local triggers = {
	'^/(test)$',
	'^/(test)@'..bot.username..'$'
}

local on_each_msg(msg, ln)

end

local action = function(msg, blocks, ln)
	--try your crap here
end

return {
	action = action,
	triggers = triggers,
	on_each_msg = on_each_msg
}