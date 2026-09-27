--!nocheck
local DropdownModule = {}

function DropdownModule.Add(Library, card, lbl, options, defaultIdx, cb)
    local T = Library.T
    local currIdx = defaultIdx or 1
    local dropdownOpen = false

    local row = Library.New("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = T.panel2,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 5,
        Parent = card,
    })
    Library.Cor(row, 10)
    Library:Reg(row, "BackgroundColor3", "panel2")

    local header = Library.New("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        ZIndex = 6,
        Parent = row,
    })

    local label = Library.New("TextLabel", {
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = lbl,
        TextColor3 = T.text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
        Parent = header,
    })
    Library:Reg(label, "TextColor3", "text")

    local selectBtn = Library.New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 120, 0, 26),
        BackgroundColor3 = T.card,
        BorderSizePixel = 0,
        Text = (options[currIdx] or "") .. "  v",
        TextColor3 = T.acc,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        ZIndex = 6,
        Parent = header,
    })
    Library.Cor(selectBtn, 8)
    Library:Reg(selectBtn, "BackgroundColor3", "card")
    Library:Reg(selectBtn, "TextColor3", "acc")

    local optionsHolder = Library.New("ScrollingFrame", {
        Position = UDim2.new(0, 10, 0, 44),
        Size = UDim2.new(1, -20, 0, 110),
        BackgroundTransparency = 1,
        CanvasSize = UDim2.new(0, 0, 0, (#options * 32) + 6),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.acc,
        ZIndex = 6,
        Parent = row,
    })
    Library.List(optionsHolder, Enum.FillDirection.Vertical, 6)
    Library.Pad(optionsHolder, 2, 2, 2, 2)

    local optButtons = {}

    local function refreshOpts()
        for i, b in ipairs(optButtons) do
            local sel = (i == currIdx)
            b.BackgroundColor3 = sel and T.acc or T.card
            b.TextColor3 = sel and Color3.fromRGB(255, 255, 255) or T.sub
        end
    end

    for i, opt in ipairs(options) do
        local optBtn = Library.New("TextButton", {
            Size = UDim2.new(0.96, 0, 0, 26),
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 0),
            BackgroundColor3 = T.card,
            BorderSizePixel = 0,
            Text = opt,
            TextColor3 = T.sub,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            ZIndex = 7,
            Parent = optionsHolder,
        })
        Library.Cor(optBtn, 8)
        table.insert(optButtons, optBtn)

        optBtn.MouseButton1Click:Connect(function()
            currIdx = i
            refreshOpts()
            dropdownOpen = false
            selectBtn.Text = options[currIdx] .. "  v"
            Library.Tween(row, 0.3, { Size = UDim2.new(1, 0, 0, 40) })
            if cb then task.spawn(cb, opt) end
        end)
    end
    refreshOpts()

    selectBtn.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        local contentHeight = (#options * 32) + 12
        local holderHeight = math.min(contentHeight, 110)
        optionsHolder.Size = UDim2.new(1, -20, 0, holderHeight)
        selectBtn.Text = options[currIdx] .. (dropdownOpen and "  ^" or "  v")
        Library.Tween(row, 0.3, { Size = UDim2.new(1, 0, 0, dropdownOpen and (48 + holderHeight + 8) or 40) })
    end)
end

return DropdownModule
