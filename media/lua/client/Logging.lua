-- Simple logging tool to help make messages from the mod stand out among others.

Logging = {}

Logging.__index = Logging

---Prefixes printed log with easily identifiable string
---@param log any
function Logging.print(log)
    print("[MOD DEBUG] " .. tostring(log))
end
