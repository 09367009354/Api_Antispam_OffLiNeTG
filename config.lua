return {
	bot_api_key = '',
	yandex_api_key = '',
	time_offset = 0,
	cli_port = 4567,
	admin = 23646077,
	admin_name = 'Big Dick Is Back To Town',
	channel = '',

	errors = {
		connection = 'Connection error.',
		results = 'No results found.',
		argument = 'Invalid argument.',
		syntax = 'Invalid syntax.',
		not_admin = 'This command must be run by an administrator.'
	},
	plugins = {
		'admin.lua',
		'mod.lua',
		'credits.lua',
		'ping.lua',
		'tell.lua',
		'help.lua',
		'setrules.lua',
		'settings.lua',
		'setabout.lua',
		'report.lua',
		'flag.lua',
		'redisinfo.lua',
		'redisbackup.lua',
		'service.lua',
		'links.lua',
		'warn.lua',
		'extra.lua',
		'setlang.lua',
		'banhammer.lua',
		'floodmanager.lua',
		'mediasettings.lua'
		
	},
	available_languages = {
		'en',
		--'it',
		--'br'
		--more to come
	},
	settings = {
		'Rules',
		'About',
		'Flag',
		'Modlist',
		'Welcome',
		'Extra',
		'Kicklist',
		'Video',
		'Gif',
		'Photo',
		'Sticker'
		}
}
