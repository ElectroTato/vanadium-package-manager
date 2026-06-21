
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

-- // Clean up the checkChests function 
storageUtils.getContainerSpace = function()

    -- // constants
    local ContainerIndexSplits = storageUtils.Configuration.ChestIndexSplits
    local Containers = { peripheral.find("inventory") }

    -- // variables
    local TotalContainerSpace = 0
    local CheckStartTime = os.time(os.date("!*t"))

    -- // we will store every chunk of chests here
    local ContainerChunks = {}

    local ProcessedChunks = 1
    local TotalContainers = 0
    local FunctionQueue = {}

    -- // Clear the screen
    TatoLib.clear()

    -- // Set-up local functions
    local function getSizeOf(chest)
        if not chest then
            print("ERROR: No chest argument passed into function.")
            return
        end
        local ChestSize = getChestSize(chest)
        TotalContainerSpace = TotalContainerSpace + ChestSize     
    end

    local function SplitChests(TableToAdd, Chunk)
        local SplitSize = math.floor(#Chunk / ContainerIndexSplits) 
        for i=1,SplitSize do
            table.insert(TableToAdd,Chunk[i])
            table.remove(Chunk,i)
        end
    end
    
    local function GetSizeOfChunk()
        for _, Chest in pairs(ContainerChunks[ProcessedChunks]) do
            getSizeOf(Chest)
        end
        
        ProcessedChunks = ProcessedChunks + 1
    end

    TatoLib.write("Fetching connected containers...",1,3)
    TotalContainers = #Containers

    for i=1,ContainerIndexSplits do
        ContainerChunks[i] = {}
        table.insert(FunctionQueue,GetSizeOfChunk)
        SplitChests(ContainerChunks[i],Containers)
    end

    parallel.waitForAll( table.unpack(FunctionQueue) )

    -- // clear everything and print results
    local TimeTaken = os.time(os.date("!*t")) - CheckStartTime

    TatoLib.clear()

    TatoLib.write("Total Space: " .. TotalContainerSpace, 1,3)
    TatoLib.write("Took " .. TimeTaken .." second(s) for " .. TotalContainers .. " containers.",1,4)

end

return storageUtils
