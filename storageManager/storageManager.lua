
-- // Libraries
local TatoLib = require("modules.tatolib")
local StorageUtils = require("modules.storageUtils")

-- // Main setup
local Monitor = peripheral.wrap("right")

if not Monitor then
    print("Unable to load application, no monitors found!")
    return
end

-- // init
TatoLib.Init(Monitor)
TatoLib.topbarPrint("Inventory Manager", {Height = 1})

StorageUtils.getContainerSpace()
