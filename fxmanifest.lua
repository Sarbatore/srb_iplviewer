game "rdr3"
fx_version "adamant"
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."
lua54 "yes"

author "Sarbatore"
description ""
version "1.0.1"

files {
    "data/ipls.json"
}

shared_scripts {
    "config.lua",
    "shared/*.lua"
}

client_scripts {
    "client/*.lua",
}

server_scripts {
    "server/*.lua",
}