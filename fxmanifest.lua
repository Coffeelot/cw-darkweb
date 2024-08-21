fx_version 'cerulean'
game 'gta5'

author 'Coffeelot'
description 'cw-darkweb II'
version '1.0.0'

shared_scripts {
    'locales/*.lua',
    'config.lua',
    '@ox_lib/init.lua',
}

client_script {
    'client/client.lua',
}
server_script {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
    'server/accounts.lua',
    'server/playerAds.lua',
}

files {
    "html/dist/index.html",
    "html/dist/assets/*.*",
}

ui_page {
    "html/dist/index.html"
}

lua54 'yes'
