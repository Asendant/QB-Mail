fx_version 'cerulean'
game 'gta5'

description 'QB Civilian Mail Job'
version '1.0.0'

client_scripts {
    'cl_mail.lua'
}

server_scripts {
    'sv_mail.lua'
}

shared_scripts {
    'config.lua'
}

ui_page 'html/index.html'

files {
    'html/app.js',
    'html/styles.css',
    'html/index.html',
}

lua54 'yes'