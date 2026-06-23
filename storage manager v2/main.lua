
-- // modules
local printc = require("utils.printc")

local pickupBarrel = peripheral.wrap("minecraft:barrel_19")
local arguments = { ... }

local function updateItemList()

    _G.itemList = {}

    local barrels = { peripheral.find("minecraft:barrel") }
    local totalBarrels = 0
    
    for _, Barrel in pairs(barrels) do

        local barrelName = peripheral.getName(Barrel)

        if barrelName == peripheral.getName(pickupBarrel) then
            goto continue
        end

        totalBarrels = totalBarrels + 1

        for Slot,Item in pairs(Barrel.list()) do
            
            local itemName = Item.name 
            local itemCount = Item.count

            if not _G.itemList[itemName] then
                _G.itemList[itemName] = {}
                _G.itemList[itemName].TotalCount = 0
            end

            local ItemData = {}
            ItemData.Container = Barrel
            ItemData.Slot = Slot
            ItemData.Item = Item

            _G.itemList[itemName].TotalCount = _G.itemList[itemName].TotalCount + Item.count

            table.insert(_G.itemList[itemName], ItemData)
            
        end

        ::continue::

    end

    return totalBarrels

end


local function fetchItem(itemName, verbose)

    if not _G.itemList then
        printc("<r>The items cache was not defined!</r> please re-run the command with the update flag!")
        return
    end

    local Items = _G.itemList[itemName]

    if not Items then
        printc( ( "There is no item named '<r>%s</r>' found in your storage."):format(itemName) )
        return
    end

    if verbose then
        printc( ("There are %d of <g>'%s'</g> found in your"):format(Items.TotalCount, itemName) )
        print("storage")
    end

    return Items
    
end

-- this one pulls the item into the pickup barrel
local function getItem(itemName, count)

    local items = fetchItem(itemName)

    local tries = 0
    local amountLeft = count

    if not items then
        return
    end

    if not count then
        count = items.TotalCount
    end

    local function getItem()

        -- // we've gotta
        local newItems = {}

        for Index,Aura in pairs(items) do
            if type(Aura) == "table" then
                newItems[Index] = Aura
                newItems[Index].Index = Index
            end
        end

        if not newItems or #newItems <= 0 then
            return
        end
        
        local randomItem = newItems[math.random(1,#newItems)]

        if not randomItem then
            print("Unable to pick item.")
            return
        end

        local barrels = { peripheral.find("minecraft:barrel") }

        local amountPulled = randomItem.Container.pushItems( peripheral.getName(pickupBarrel) , randomItem.Slot, amountLeft )

        amountLeft = amountLeft - amountPulled
        print( ("Grabbed %d, %d left"):format(amountPulled,amountLeft) )
        table.remove(items,randomItem.Index)

    end

    repeat
        getItem()
        tries = tries + 1
    until tries > 10 or amountLeft <= 0

    print("finished, total tries: " .. tries)
    updateItemList()
    
end

local arguments = { ... }

local argsTable = {
    update = function()
        
        local startTime = os.time(os.date("!*t"))
        printc("Updating item cache...")

        updateItemList()

        printc( ("Succesfully updated the item cache in <g>%d seconds</g>!"):format( os.time(os.date("!*t")) - startTime ) )
    end,

    list = function()
        
        if not _G.itemList then
            updateItemList()
        end

        local itemName = arguments[2]

        if not itemName then
            
            for Name,_ in pairs(_G.itemList) do

                local item = fetchItem(Name,false)

                if not item then
                    goto continue
                end

                print( ("%s : %d"):format(Name,item.TotalCount) )

                ::continue::
            end

            return
        end

        fetchItem(itemName, true)

    end,

    pull = function()
        
        local itemName = arguments[2]
        local count = arguments[3]

        if not itemName or type(itemName) ~= "string" then
            printc("<r>Unable to get item, invalid arguments!</r>")
            return
        end

        getItem(itemName,tonumber(count) or nil)

    end
}

local firstArgument = arguments[1]

if not firstArgument or not argsTable[firstArgument] then
    print("-- Command Help --")
    print("")
    print("- update")
    print("Scans all connected containers and updates item cache.")
    print("")
    print("- list 'item name (optional)' ")
    print("Returns how much of a certain item you have, if no item name is specified this returns a list of every item you have and how much of it you have.")
    print("")
    print("- pull 'item name, count (optional)'")
    print("Pulls a certain amount of a specified item into your pickup barrel, if no count argument is specified all of that item will be grabbed.")
    return
end

argsTable[firstArgument]()
