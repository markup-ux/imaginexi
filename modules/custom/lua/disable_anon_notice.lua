-----------------------------------
-- Disable Anon Notice
--
-- Informational module:
-- /anon is hard-disabled in core packet/search handling.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('disable_anon_notice')
-----------------------------------

m:addOverride('xi.server.onServerStart', function()
    super()
    printf('[custom] /anon is disabled server-wide.')
end)

return m
