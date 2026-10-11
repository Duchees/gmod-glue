Glue = Glue or {}

Glue.LoadedFiles = {}
Glue.LoadedModules = {}
Glue.LoadedLibs = {}
Glue.LoadedHooks = {}

--- Safely includes a Lua file and logs any runtime errors without stopping execution.
--- @param path string The path to the Lua file to include.
--- @return boolean true if the file was included successfully, false otherwise.
local function safeInclude(path)
    local ok, err = xpcall(include, debug.traceback, path)

    if not ok then
        ErrorNoHalt("[Glue] Failed to include file: " .. path .. "\n" .. tostring(err) .. "\n")
        return false
    end

    return true
end

function Glue.LoadFile(path)
    local fileName = string.GetFileFromFilename(path)

    if SERVER then
        if string.StartsWith(fileName, "sv_") then
            return safeInclude(path)
        end

        if string.StartsWith(fileName, "sh_") then
            AddCSLuaFile(path)
            return safeInclude(path)
        end

        if string.StartsWith(fileName, "cl_") then
            AddCSLuaFile(path)
            return true
        end
    end

    if CLIENT then
        if string.StartsWith(fileName, "cl_") or string.StartsWith(fileName, "sh_") then
            return safeInclude(path)
        end
    end

    return false
end