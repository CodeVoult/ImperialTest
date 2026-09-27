--!nocheck
-- Boton CHAMFERED estilo gaming (esquinas mochadas, como tus fotos)
local ButtonModule = {}

function ButtonModule.Add(Library, card, lbl, cb)
    local T = Library.T

    local row = Library.New("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = T.acc,
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = card,
    })
    Library.Chamfer(row, 11, T.card, 6)
    Library:Reg(row, "BackgroundColor3", "acc")

    local grad = Library.AccGradient(row, 20)
    Library:Reg(grad, "Color", "@grad")

    -- brillo que cruza al hacer hover
    local shine = Library.New("Frame", {
        Size = UDim2.new(0.45, 0, 1, 0),
        Position = UDim2.new(-0.5, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.86,
        BorderSizePixel = 0,
        ZIndex = 7,
        Parent = row,
    })
    Library.New("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Parent = shine,
    })

    local btn = Library.New("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = lbl,
        TextColor3 = T.text,
        Font = Enum.Font.GothamBlack,
        TextSize = 13,
        ZIndex = 9,
        Parent = row,
    })
    Library:Reg(btn, "TextColor3", "text")

    btn.MouseEnter:Connect(function()
        Library.Tween(shine, 0.45, { Position = UDim2.new(1.05, 0, 0, 0) }, Enum.EasingStyle.Quad)
        Library.Tween(row, 0.15, { Size = UDim2.new(1, 0, 0, 44) })
    end)
    btn.MouseLeave:Connect(function()
        Library.Tween(row, 0.15, { Size = UDim2.new(1, 0, 0, 42) })
    end)

    btn.MouseButton1Click:Connect(function()
        Library.Tween(row, 0.08, { BackgroundColor3 = T.acc2 })
        task.delay(0.09, function()
            if row and row.Parent then
                Library.Tween(row, 0.2, { BackgroundColor3 = T.acc })
            end
        end)
        if cb then task.spawn(cb) end
    end)
end

return ButtonModule
