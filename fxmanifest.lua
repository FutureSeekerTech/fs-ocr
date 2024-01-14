fx_version 'adamant'
game 'gta5'
author 'FutureSeekerTech'
description 'FS OCR [BETA]'

client_scripts {
    'cl_ocr.lua',
}

server_scripts {
    'webhook.lua',
    'sv_ocr.lua',
	'@oxmysql/lib/MySQL.lua',
}


ui_page 'app.html'

files {
	'app.html'
}

dependencies {
    'oxmysql',
    'screenshot-basic'
}
    "yarn",
    "webpack"
}
