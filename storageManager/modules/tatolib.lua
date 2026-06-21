
local tatolib = {}
tatolib.Monitor = nil
tatolib.CurrentTopbarMeta = {}

tatolib.__index = tatolib

-- Default config for topbarPrint
local DefaultConfig = {}
DefaultConfig.Height = 1
DefaultConfig.TextColor = "White"
DefaultConfig.BackgroundColor = "Gray"

local ColorMap = {
    White = "0",
    Orange = "1",
    Magenta = "2",
    LightBlue = "3",
    Yellow = "4",
    Lime = "5",
    Pink = "6",
    Gray = "7",
    LightGray = "8",
    Cyan = "9",
    Purple = "a",
    Blue = "b",
    Brown = "c",
    Green = "d",
    Red = "e",
    Black = "f",
}

-- // Initializes our thingamabob and sets the global monitor
tatolib.Init = function(Monitor)
    
    if not Monitor then
        return
    end

    Monitor.setBackgroundColor(colors.white)
    Monitor.setTextColor(colors.black)

    tatolib.Monitor = Monitor

end

-- Creates a grey topbar at the top of the passed monitor with the Text argument 
tatolib.topbarPrint = function(Text, Config)

    if not tatolib.Monitor then
        print("Unable to call topbarPrint because Monitor is either nil or wasn't passed into function.")
        return
    end

    local Monitor = tatolib.Monitor

    if not Config then
        Config = DefaultConfig
    else
        for PropertyName,Property in pairs(DefaultConfig) do
            if not Config[PropertyName] then
                Config[PropertyName] = Property
            end
        end
    end
    
    local sx,sy = Monitor.getSize()
    Monitor.setCursorPos(1,Config and Config.Height or 1)

    local topbarText = Text 

    local topbarSize = string.rep(" ",sx - string.len(topbarText) )

    local topbarTextColor = string.rep(ColorMap[Config.TextColor], sx)
    local topbarColor = string.rep(ColorMap[Config.BackgroundColor], sx)

    Monitor.blit(topbarText .. topbarSize, topbarTextColor, topbarColor)	

    tatolib.CurrentTopbarMeta = {
        Text = Text,
        Config = Config,
    }

    
end

tatolib.write = function(Text, CursorX, CursorY)

    if not tatolib.Monitor then
        print("Unable to call topbarPrint because Monitor is either nil or wasn't passed into function.")
        return
    end

    local Monitor = tatolib.Monitor
    
    if not Text then
        return
    end

    Monitor.clear()

    tatolib.topbarPrint(tatolib.CurrentTopbarMeta.Text,tatolib.CurrentTopbarMeta.Config)
    Monitor.setCursorPos(CursorX or 1, CursorY or 2)

    Monitor.write(Text)

end

return tatolib
