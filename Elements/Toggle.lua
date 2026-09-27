--!nocheck
local ToggleModule = {}

function ToggleModule.Add(Library, card, lbl, def, cb)
    local T = Library.T

    local row = Library.New("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = T.panel2,
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = card,
    })
    Library.Cor(row, 10)
    Library:Reg(row, "BackgroundColor3", "panel2")

    local label = Library.New("TextLabel", {
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -80, 1, 0),
        BackgroundTransparency = 1,
        Text = lbl,
        TextColor3 = T.text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
        Parent = row,
    })
    Library:Reg(label, "TextColor3", "text")

    local switchBg = Library.New("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 52, 0, 28),
        BackgroundColor3 = def and T.acc or T.switchOff,
        BorderSizePixel = 0,
        ZIndex = 6,
        Parent = row,
    })
    Library.Cor(switchBg, 14)
    Library:Reg(switchBg, "BackgroundColor3", "switchOff")

    local knob = Library.New("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 22, 0, 22),
        Position = def and UDim2.new(1, -25, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 7,
        Parent = switchBg,
    })
    Library.Cor(knob, 11)

    local click = Library.New("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 9,
        Parent = row,
    })

    click.MouseButton1Click:Connect(function()
        def = not def
        Library.Tween(knob, 0.28, {
            Position = def and UDim2.new(1, -25, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        }, Enum.EasingStyle.Back)
        Library.Tween(switchBg, 0.25, { BackgroundColor3 = def and T.acc or T.switchOff })
        Library:Notify(lbl, def)
        if cb then task.spawn(cb, def) end
    end)

    -- color inicial correcto si def = true
    if def then switchBg.BackgroundColor3 = T.acc end
end

return ToggleModule
