Glue = Glue or {}

Glue.LoadedFiles = Glue.LoadedFiles or {}
Glue.LoadedModules = Glue.LoadedModules or {}
Glue.LoadedLibs = Glue.LoadedLibs or {}

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

--- Loads a Lua file based on its filename prefix and the current realm.
--- On the server, `sv_` files are included, `sh_` files are sent to clients and included,
--- and `cl_` files are sent to clients without being included. On the client, `sv_` files
--- are skipped, while `sh_` and `cl_` files are included. Include errors are logged.
--- @param path string The path to the Lua file to load.
--- @return number exitCode an exit code indicating success, failure, a skipped file, or an unknown prefix.
function Glue.LoadFile(path)
    local fileName = string.GetFileFromFilename(path)

    if SERVER then
        if string.StartsWith(fileName, "sv_") then
            if safeInclude(path) then
                return Glue.ExitCodes.SUCCESS
            else
                return Glue.ExitCodes.FAILED
            end
        end

        if string.StartsWith(fileName, "sh_") then
            AddCSLuaFile(path)
            if safeInclude(path) then
                return Glue.ExitCodes.SUCCESS
            else
                return Glue.ExitCodes.FAILED
            end
        end

        if string.StartsWith(fileName, "cl_") then
            AddCSLuaFile(path)
            return Glue.ExitCodes.SUCCESS
        end
        
        return Glue.ExitCodes.UNKNOWN_PREFIX
    end

    if CLIENT then
        if string.StartsWith(fileName, "sv_") then
            return Glue.ExitCodes.SKIPPED
        end

        if string.StartsWith(fileName, "cl_") or string.StartsWith(fileName, "sh_") then
            if safeInclude(path) then
                return Glue.ExitCodes.SUCCESS
            else
                return Glue.ExitCodes.FAILED
            end
        end

        return Glue.ExitCodes.UNKNOWN_PREFIX
    end
end