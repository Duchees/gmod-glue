Glue = Glue or {}

Glue.version = "v0.0.0-pre-alpha"
Glue.author = "Duchees"

Glue.ExitCodes = {
    SUCCESS = true,
    FAILED = false,
    SKIPPED = 1,
    UNKNOWN_PREFIX = 2,
}

if SERVER then
    AddCSLuaFile("glue/sh_autoloader.lua")
end

include("glue/sh_autoloader.lua")