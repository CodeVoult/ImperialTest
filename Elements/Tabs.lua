--!nocheck
local TabsModule = {}

function TabsModule.Create(Library, name, iconId)
    local T = Library.T

    local tabBtn = Library.New("TextButton", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = T.panel2,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 4,
        Parent = Library.Sidebar,
    })
    Library.Cor(tabBtn, 10)

    -- barra indicadora izquierda
    local accentBar = Library.New("Frame", {
        Position = UDim2.new(0, 0, 0.5, -12),
        Size = UDim2.new(0, 3, 0, 24),
        BackgroundColor3 = T.acc,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 6,
        Parent = tabBtn,
    })
    Library.Cor(accentBar, 2)
    Library:Reg(accentBar, "BackgroundColor3", "acc")

    local icon = Library.New("ImageLabel", {
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, 12, 0.5, -11),
        BackgroundTransparency = 1,
        Image = iconId or "",
        ImageColor3 = T.sub,
        ZIndex = 5,
        Parent = tabBtn,
    })

    local txt = Library.New("TextLabel", {
        Size = UDim2.new(1, -46, 1, 0),
        Position = UDim2.new(0, 42, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = T.sub,
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
        Parent = tabBtn,
    })

    local page = Library.New("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        ClipsDescendants = true,
        BackgroundTransparency = 1,
        Visible = false,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.acc,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = Library.ContentArea,
    })
    Library:Reg(page, "ScrollBarImageColor3", "acc")
    local pageList = Library.List(page, Enum.FillDirection.Vertical, 8)
    Library.Pad(page, 8, 8, 8, 8)

    pageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if page and page.Parent then
            page.CanvasSize = UDim2.fromOffset(0, pageList.AbsoluteContentSize.Y + 10)
        end
    end)

    local entry = { btn = tabBtn, bar = accentBar, txt = txt, icon = icon }

    local function selectTab()
        for _, t in pairs(Library.Tabs) do
            Library.Tween(t.btn, 0.2, { BackgroundTransparency = 1 })
            Library.Tween(t.bar, 0.2, { BackgroundTransparency = 1 })
            t.txt.TextColor3 = T.sub
            t.icon.ImageColor3 = T.sub
        end
        for _, p in pairs(Library.Pages) do
            p.Visible = false
        end
        Library.Tween(tabBtn, 0.2, { BackgroundTransparency = 0 })
        Library.Tween(accentBar, 0.2, { BackgroundTransparency = 0 })
        txt.TextColor3 = Color3.fromRGB(255, 255, 255)
        icon.ImageColor3 = Color3.fromRGB(255, 255, 255)

        page.Visible = true
        page.Position = UDim2.new(0, 0, -0.08, 0)
        page.Size = UDim2.new(1, 0, 1.16, 0)
        Library.Tween(page, 0.55, {
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
        }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

        Library.ActivePage = page
        task.delay(0.1, function()
            if page and page.Parent then
                page.CanvasPosition = Vector2.zero
            end
        end)
    end

    tabBtn.MouseButton1Click:Connect(selectTab)

    table.insert(Library.Tabs, entry)
    table.insert(Library.Pages, page)

    if not Library.ActivePage then
        selectTab()
    end

    return page
end

return TabsModule
