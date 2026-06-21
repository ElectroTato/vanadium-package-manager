
local storageUtils = {}
storageUtils.__index = storageUtils
storageUtils.Configuration = {
    ChestIndexSplits = 8,
}

local TatoLib = require("modules.tatolib")

local function getChestSize(Chest)

    if not Chest then
        TatoLib.write("ERROR while getting chest size, no chest argument passed into function.",1,3)
        return 0
    end
    
    local total = 0
    for i = 1, Chest.size() do
        total = total + Chest.getItemLimit(i)
    end

    return total

end

-- Creates a grey topbar at the top of the passed monitor with the Text argument 
storageUtils.checkChests = function()
  
    local splitSize = storageUtils.Configuration.ChestIndexSplits
    local totalSpace = 0
    local startTime = os.time(os.date("!*t"))

    -- // split chests into 2 chunks that we read at the same time
    local splitChests = { {},{} }

    local chunksProcessed = 1
    local totalContainers = 0

    local getTotalSizeFuncs = {}

    TatoLib.clear()
    print(startTime)

    local function addToTotalSize(chest)
        
        if not chest then
            TatoLib.write("No chest found!",1,3)
            return            
        end

        -- // we've will calculate the max amount of items this chest can hold
        local ChestSize = getChestSize(chest)

        totalSpace = totalSpace + ChestSize

    end

    local function addChestsTo(tableToAdd,chunk)
        for i=1,math.floor(#chunk / splitSize) do
            table.insert(tableToAdd,chunk[i])
            table.remove(chunk,i)
        end
    end

    local function getTotalSizeFromChunk()

        for Index, Chest in pairs(splitChests[chunksProcessed]) do
            addToTotalSize(Chest)
        end

        chunksProcessed = chunksProcessed + 1
    end

    local chests = { peripheral.find("inventory") }
    TatoLib.write("Calculating total chest space... ",1,3)

    totalContainers = #chests

    for i=1,splitSize do
        splitChests[i] = {}
        table.insert(getTotalSizeFuncs,getTotalSizeFromChunk)
        addChestsTo(splitChests[i],chests)
    end

    parallel.waitForAll(table.unpack(getTotalSizeFuncs))

    local endTime = os.time(os.date("!*t"))

    print(endTime)

    TatoLib.clear()

    TatoLib.write("Total Space: " .. totalSpace, 1,3)
    TatoLib.write("Took " .. endTime - startTime .." second(s) for " .. totalContainers .. " containers.",1,4)
    

end

return storageUtils
