fx_version 'cerulean'
game 'gta5'

description 'Simple Fishing System for FiveM'
author 'qw-scripts'
version '0.1.0'

client_scripts {
    'client/**/*'
}

server_scripts {
    'server/**/*'
}

shared_scripts {
    'shared/**/*',
    '@ox_lib/init.lua'
}

lua54 'yes'
