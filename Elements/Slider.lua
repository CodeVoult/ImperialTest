--!nocheck
local SliderModule = {}

function SliderModule.Add(Library, card, lbl, mn, mx, def, cb)
    local T = Library.T
    local UserInputService = game:GetService("UserInputService")

    local row = Library.New("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = T.panel2,
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = card,
    })
    Library.Cor(row, 10)
    Library:Reg(row, "BackgroundColor3", "panel2")

    local valInput = Library.New("TextBox", {
        Position = UDim2.new(0, 12, 0.5, -11),
        Size = UDim2.new(0, 40, 0, 22),
        BackgroundColor3 = T.card,
        BorderSizePixel = 0,
        Text = tostring(def),
        TextColor3 = T.acc,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center,
        ClearTextOnFocus = false,
        ZIndex = 8,
        Parent = row,
    })
    Library.Cor(valInput, 7)
    Library:Reg(valInput, "BackgroundColor3", "card")
    Library:Reg(valInput, "TextColor3", "acc")

    local label = Library.New("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 130, 0, 20),
        BackgroundTransparency = 1,
        Text = lbl,
        TextColor3 = T.text,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 6,
        Parent = row,
    })
    Library:Reg(label, "TextColor3", "text")

    local track = Library.New("Frame", {
        Position = UDim2.new(0, 60, 0.5, -3),
        Size = UDim2.new(1, -210, 0, 6),
        BackgroundColor3 = T.card,
        BorderSizePixel = 0,
        ZIndex = 6,
        Parent = row,
    })
    Library.Cor(track, 3)
    Library:Reg(track, "BackgroundColor3", "card")

    local fill = Library.New("Frame", {
        BackgroundColor3 = T.acc,
        BorderSizePixel = 0,
        Size = UDim2.new((def - mn) / (mx - mn), 0, 1, 0),
        ZIndex = 7,
        Parent = track,
    })
    Library.Cor(fill, 3)
    Library:Reg(fill, "BackgroundColor3", "acc")

    local thumb = Library.New("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((def - mn) / (mx - mn), 0, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 8,
        Parent = track,
    })
    Library.Cor(thumb, 7)

    -- OPTIMIZACION: set directo, sin Tween por frame mientras arrastras
    local lastCb = def
    local function setVal(newVal, skipCb)
        newVal = math.clamp(newVal, mn, mx)
        valInput.Text = tostring(newVal)
        local tt = (newVal - mn) / (mx - mn)
        fill.Size = UDim2.new(tt, 0, 1, 0)
        thumb.Position = UDim2.new(tt, 0, 0.5, 0)
        if not skipCb and cb and newVal ~= lastCb then
            lastCb = newVal
            task.spawn(cb, newVal)
        end
    end

    local dragging = false
    local function update(posX)
        local t = math.clamp((posX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        setVal(math.clamp(math.floor(mn + t * (mx - mn) + 0.5), mn, mx))
    end

    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)

    -- click directo en el track
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    valInput.FocusLost:Connect(function()
        local num = tonumber(valInput.Text)
        if num then setVal(math.round(num)) else setVal(lastCb, true) end
    end)
end

return SliderModule
