local colorMap = {
    r = colors.red,
    g = colors.green,
    b = colors.blue,
    w = colors.white,
    y = colors.yellow,
    c = colors.cyan,
    m = colors.magenta,
    o = colors.orange,
    l = colors.lime,
    p = colors.pink,
    n = colors.lightGray,
    d = colors.gray,
    x = colors.black,
    a = colors.lightBlue,
    e = colors.brown,
    u = colors.purple,
}

return function(text, defaultColor)
    defaultColor = defaultColor or colors.white

    local stack = { defaultColor }
    local currentColor = defaultColor

    term.setTextColor(currentColor)

    local i = 1
    local buffer = ""

    local function flush()
        if buffer ~= "" then
            term.write(buffer)
            buffer = ""
        end
    end

    while i <= #text do
        local ch = text:sub(i, i)

        if ch == "<" then
            local close = text:find(">", i, true)

            if close then
                flush()

                local tag = text:sub(i + 1, close - 1)

                if tag == "br" then
                    term.write("\n")

                elseif tag:sub(1, 1) == "/" then
                    if #stack > 1 then
                        table.remove(stack)
                    end
                    currentColor = stack[#stack]
                    term.setTextColor(currentColor)

                elseif colorMap[tag] then
                    currentColor = colorMap[tag]
                    table.insert(stack, currentColor)
                    term.setTextColor(currentColor)
                end

                i = close + 1
            else
                buffer = buffer .. ch
                i = i + 1
            end

        else
            buffer = buffer .. ch
            i = i + 1
        end
    end

    flush()

    local x, y = term.getCursorPos()
    local w, h = term.getSize()

    if y >= h then
        term.scroll(1)
        term.setCursorPos(1, h)
    else
        term.setCursorPos(1, y + 1)
    end

    term.setTextColor(defaultColor)
end
