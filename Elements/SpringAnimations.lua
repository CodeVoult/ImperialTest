--!nocheck
-- ================================================================= --
--  ANIMACIONES CON RESORTES (tu animacion original, optimizada)
--  - dt clamp (evita saltos si el executor laggea)
--  - cachea AbsoluteSize (0 lecturas de layout por frame)
--  - early-out cuando todo esta quieto
-- ================================================================= --
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local SpringAnimations = {}

function SpringAnimations.Setup(window, config, Spring)
    if not Spring then
        error("SpringAnimations.Setup: Spring module is nil")
    end

    local targetWidth = config.targetWidth or 640
    local targetHeight = config.targetHeight or 400

    local GUI = window.GUI
    local WinMain = window.WinMain
    local FloatIcon = window.FloatIcon
    local ContentGroup = window.ContentGroup
    local WinScale = window.WinScale
    local WinCorner = window.WinCorner
    local closeTextLabel = window.closeTextLabel
    local borderStroke = window.borderStroke
    local Pages = window.Pages or {}

    local MenuPosXScale   = Spring.new(1.2, 14, 25, 0.5)
    local MenuPosYScale   = Spring.new(1.2, 14, 25, 0.15)
    local MenuSizeXOffset = Spring.new(1.5, 14, 25, 150)
    local MenuSizeYOffset = Spring.new(1.5, 14, 25, 44)
    local MenuCorner      = Spring.new(1.2, 14, 25, 21)

    local springing = false
    local winOpen = false

    -- cache de AbsoluteSize del ScreenGui
    local guiW, guiH = GUI.AbsoluteSize.X, GUI.AbsoluteSize.Y
    GUI:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        guiW, guiH = GUI.AbsoluteSize.X, GUI.AbsoluteSize.Y
    end)

    local function getFloatScalePos()
        if guiW == 0 or guiH == 0 then return 0.5, 0.15 end
        local absPos = FloatIcon.AbsolutePosition
        local absSize = FloatIcon.AbsoluteSize
        return (absPos.X + absSize.X / 2) / guiW, (absPos.Y + absSize.Y / 2) / guiH
    end

    local function openWin()
        if winOpen then return end
        winOpen = true
        springing = true

        closeTextLabel.Visible = false
        closeTextLabel.TextTransparency = 1

        local fx, fy = getFloatScalePos()

        FloatIcon.Visible = false
        WinMain.Visible = true

        MenuPosXScale.x, MenuPosXScale.v, MenuPosXScale.target = fx, 0, 0.5
        MenuPosYScale.x, MenuPosYScale.v, MenuPosYScale.target = fy, 0, 0.5
        MenuSizeXOffset.x, MenuSizeXOffset.v, MenuSizeXOffset.target = 150, 0, targetWidth
        MenuSizeYOffset.x, MenuSizeYOffset.v, MenuSizeYOffset.target = 44, 0, targetHeight
        MenuCorner.x, MenuCorner.v, MenuCorner.target = 21, 0, 32

        WinMain.Position = UDim2.new(fx, 0, fy, 0)
        WinMain.BackgroundTransparency = window.T.bgTrans

        ContentGroup.Visible = false
        ContentGroup.GroupTransparency = 1
        if borderStroke then borderStroke.Transparency = 0.2 end

        task.delay(0.35, function()
            for _, page in ipairs(Pages) do
                if page then pcall(function() page.CanvasPosition = Vector2.zero end) end
            end
        end)
    end

    local function closeWin()
        if not winOpen then return end
        winOpen = false
        springing = true

        ContentGroup.Visible = false
        ContentGroup.GroupTransparency = 1

        local fx, fy = getFloatScalePos()

        closeTextLabel.Position = WinMain.Position
        closeTextLabel.Visible = true
        closeTextLabel.TextTransparency = 0

        MenuPosXScale.x, MenuPosXScale.v, MenuPosXScale.target = WinMain.Position.X.Scale, 0, fx
        MenuPosYScale.x, MenuPosYScale.v, MenuPosYScale.target = WinMain.Position.Y.Scale, 0, fy

        MenuSizeXOffset.target = 150
        MenuSizeYOffset.target = 44
        MenuCorner.target = 21
    end

    local settled = false
    local contentW, contentH = 0, 0

    local renderConnection = RunService.RenderStepped:Connect(function(dt)
        if not WinMain or not WinMain.Parent then return end
        if dt > 1 / 20 then dt = 1 / 20 end -- clamp anti-tiron

        -- Si nada se mueve, no tocamos nada (0 escrituras por frame)
        if not springing and settled then return end

        local currW = MenuSizeXOffset:Update(dt)
        local currH = MenuSizeYOffset:Update(dt)
        local currR = MenuCorner:Update(dt)

        WinMain.Size = UDim2.fromOffset(currW, currH)
        if WinCorner then WinCorner.CornerRadius = UDim.new(0, currR) end

        if window.Sidebar and window.ContentArea then
            local sidebarWidth = math.clamp(currW * 0.32, 50, window.T.tabSize - 30)
            local availH = math.max(0, currH - 62)
            window.Sidebar.Size = UDim2.fromOffset(sidebarWidth, availH)
            window.Sidebar.Position = UDim2.fromOffset(8, 52)

            local cx = sidebarWidth + 14
            contentW = math.max(0, currW - cx - 10)
            contentH = math.max(0, currH - 58)
            window.ContentArea.Size = UDim2.fromOffset(contentW, contentH)
            window.ContentArea.Position = UDim2.fromOffset(cx, 52)
        end

        if winOpen then
            if currW < 300 then
                ContentGroup.Visible = false
                ContentGroup.GroupTransparency = 1
            else
                ContentGroup.Visible = true
                local p = math.clamp((currW - 300) / (targetWidth - 300), 0, 1)
                ContentGroup.GroupTransparency = 1 - p

                if currW > targetWidth - 10 then
                    ContentGroup.GroupTransparency = 0
                    for _, page in ipairs(Pages) do
                        if page and page.Parent == window.ContentArea then
                            page.Size = UDim2.fromOffset(contentW, contentH - 8)
                        end
                    end
                end
            end
        else
            ContentGroup.Visible = false
        end

        if springing then
            local currX = MenuPosXScale:Update(dt)
            local currY = MenuPosYScale:Update(dt)
            WinMain.Position = UDim2.new(currX, 0, currY, 0)

            if not winOpen then closeTextLabel.Position = WinMain.Position end

            if winOpen then
                if math.abs(currW - targetWidth) < 1.5 and math.abs(currH - targetHeight) < 1.5 and math.abs(MenuSizeXOffset.v) < 2 then
                    springing = false
                    settled = true
                end
            else
                if math.abs(currW - 150) < 2 and math.abs(currH - 44) < 2 then
                    springing = false
                    settled = true
                    WinMain.Visible = false
                    FloatIcon.Visible = true

                    TweenService:Create(closeTextLabel, TweenInfo.new(0.15), { TextTransparency = 1 }):Play()
                    task.delay(0.15, function() closeTextLabel.Visible = false end)
                end
            end
        end
    end)

    GUI.Destroying:Connect(function()
        if renderConnection then renderConnection:Disconnect() end
    end)

    FloatIcon.MouseButton1Click:Connect(function()
        if not winOpen then
            settled = false
            openWin()
        end
    end)

    local function makeSmoothDrag(handle, target, scaleObj, clickCallback)
        local dragging = false
        local dragStart, startPos
        local targetX, targetY, currentX, currentY = 0, 0, 0, 0
        local lerpConnection = nil
        local suavizado = 0.15
        local inputBeganTime = 0

        handle.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            if springing then return end
            dragging = true
            window.dragging = true
            inputBeganTime = tick()
            dragStart = input.Position
            startPos = target.Position
            currentX = target.AbsolutePosition.X + (target.AbsoluteSize.X * target.AnchorPoint.X)
            currentY = target.AbsolutePosition.Y + (target.AbsoluteSize.Y * target.AnchorPoint.Y)
            targetX, targetY = currentX, currentY

            if scaleObj then TweenService:Create(scaleObj, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Scale = 1.01 }):Play() end

            if not lerpConnection then
                lerpConnection = RunService.RenderStepped:Connect(function()
                    if dragging or math.abs(currentX - targetX) > 0.1 or math.abs(currentY - targetY) > 0.1 then
                        currentX = currentX + (targetX - currentX) * suavizado
                        currentY = currentY + (targetY - currentY) * suavizado
                        target.Position = UDim2.new(0, math.round(currentX), 0, math.round(currentY))
                    else
                        lerpConnection:Disconnect()
                        lerpConnection = nil
                    end
                end)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                local originX = (guiW * startPos.X.Scale) + startPos.X.Offset
                local originY = (guiH * startPos.Y.Scale) + startPos.Y.Offset
                targetX = originX + delta.X
                targetY = originY + delta.Y
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            if dragging then
                dragging = false
                window.dragging = false
                if scaleObj then TweenService:Create(scaleObj, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Scale = 1 }):Play() end

                if guiW > 0 and guiH > 0 then
                    target.Position = UDim2.new(currentX / guiW, 0, currentY / guiH, 0)
                end

                local duration = tick() - inputBeganTime
                if duration < 0.25 and clickCallback then clickCallback() end
            end
        end)
    end

    if window.titleBar then
        makeSmoothDrag(window.titleBar, WinMain, WinScale, closeWin)
    end

    return {
        Open = function() settled = false openWin() end,
        Close = closeWin,
        Toggle = function()
            settled = false
            if winOpen then closeWin() else openWin() end
        end,
        IsOpen = function() return winOpen end,
        Springing = function() return springing end,
        RenderConnection = renderConnection,
    }
end

return SpringAnimations
