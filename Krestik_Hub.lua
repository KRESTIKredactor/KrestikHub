local _cloneref = (typeof(cloneref) == "function") and cloneref or function(obj) return obj end
local function getSafeService(name)
    local ok, svc = pcall(function()
        return _cloneref(game:GetService(name))
    end)
    if ok and svc then
        return svc
    end
    local okRaw, rawSvc = pcall(function()
        return game:GetService(name)
    end)
    return okRaw and rawSvc or nil
end

local Players = getSafeService("Players")
local RunService = getSafeService("RunService")
local UserInputService = getSafeService("UserInputService")
local TweenService = getSafeService("TweenService")
local SoundService = getSafeService("SoundService")
local Workspace = getSafeService("Workspace")
local HttpService = getSafeService("HttpService")
local TeleportService = getSafeService("TeleportService")
local ReplicatedStorage = getSafeService("ReplicatedStorage")
local Lighting = getSafeService("Lighting")
local ProximityPromptService = getSafeService("ProximityPromptService")
local CollectionService = getSafeService("CollectionService")
local LogService = getSafeService("LogService")
local ScriptContext = getSafeService("ScriptContext")
local Stats = getSafeService("Stats")
local LocalPlayer = Players.LocalPlayer

local running = true
local connections = {}
local threads = {}
local currentBind = Enum.KeyCode.RightShift
local menuOpen = true

local FeatureBinds = {}
local ConfigKeyToBindName = {}

local Config = {
    Language = "RU", 
    AntiAFK = true,
    AntiCheatBypass = true,
    ActiveGameMode = "None", 

    ThemeColor = Color3.fromRGB(79, 70, 229),
    ThemeAccent = Color3.fromRGB(99, 102, 241),
    BGColor = Color3.fromRGB(24, 25, 32),
    PanelColor = Color3.fromRGB(33, 35, 45),
    BorderColor = Color3.fromRGB(48, 52, 67),

    SpeedOn = false,
    SpeedPower = 48,
    SpeedMethod = "Natural Velocity",
    AdaptiveSpeed = true,
    FlyOn = false,
    FlySpeed = 70,
    NoClipOn = false,
    SmartNoClip = true,
    InfJumpOn = false,
    JumpOn = false,
    JumpPower = 90,
    AntiRagdoll = false,
    AntiSlip = false,

    AutoClickerOn = false,
    AutoClickerCPS = 15,
    AutoClickerButton = "LMB",

    -- Настройки транспорта (Без проседания и поломки подвески)
    VehicleSpeedOn = false,
    VehicleSpeedMethod = "Suspension Safe",
    VehicleSpeed = 65,
    VehicleJumpOn = false,
    VehicleJumpPower = 65,
    VehicleFlyOn = false,
    VehicleFlySpeed = 100,
    VehicleNoFlip = false,
    VehicleInstantBrake = false,

    AimbotOn = false,
    AimbotPart = "Head",
    AimbotSmoothness = 0,
    AimbotFOV = 150,
    AimbotTeamCheck = true,
    AimbotWallCheck = true,
    AimbotPrediction = false,
    AimbotPredictionPower = 1.2,
    AimbotBind = "MouseButton2",
    AimbotMethod = "Camera CFrame",
    AimbotJitter = false,
    Triggerbot = false,

    ESPOn = false,
    ESPTagsOn = true,
    ESPShowHP = true,
    ESPBoxesOn = false,
    ESPTracers = false,
    ESPTeamCheck = false,
    ESPDistanceLimit = 1500,
    ShowFOV = false,
    Fullbright = false,

    TweenTP = false,
    TweenTPSpeed = 120,
    ClickTP = false,

    -- Настройки Driving Empire
    DERaceSelect = "Drag Race (Vine Hill)",
    DERecordSeconds = 6,
    DELapsCount = 0,
    DEHoverHeight = 6,
    DERecordActive = false,
    DEAutoLoop = false,
    DEShowCheckpointsESP = false,

    -- Настройки Steal or Die
    StealItemsESP = false,
    StealMinRarity = "All (Common+)",
    StealMonsterESP = false,
    StealExitESP = false,
    StealLootHUD = false,
    StealAutoCollect = false,

    -- Настройки UNO
    UnoAutoUno = false,
    UnoAutoCatch = false,
    UnoAutoColor = false,
    UnoShowCards = false,
    UnoSmartHint = false,
    UnoAutoPlay = false,

    SpinBot = false,
    SpinSpeed = 20,
    LowGravity = false,
    GravityValue = 35,
    InstantInteract = false,
    ChatSpam = false,
    SpamText = "KRESTIK HUB V0.9",
    JesusWalk = false,
    SitSpam = false,
    RagdollSelf = false
}

-----------------------------------------------------------
-- НАСТРОЙКИ СИСТЕМЫ КЛЮЧЕЙ (KEY SYSTEM)
-----------------------------------------------------------
local KeySystemConfig = {
    Enabled = true,
    SaveKey = true,
    SaveFileName = "KrestikHub_Key.dat",
    GitHubTokenFile = "KrestikHub_GitHubToken.dat",
    GitHubRepoOwner = "KRESTIKredactor",
    GitHubRepoName = "KrestikHub",
    GitHubFilePath = "keys.json",
    GetKeyLink = "https://discord.gg/krestikhub",
    RemoteKeysUrl = "https://raw.githubusercontent.com/KRESTIKredactor/KrestikHub/refs/heads/main/keys.json",

    -- Резервные встроенные ключи формата KRESTIK-........... (11 случайных символов)
    LocalKeys = {
        ["KRESTIK-FREE24H0001"] = { durationHours = 24,      label = "Free (24 часа)" },
        ["KRESTIK-VIP7DAYS001"] = { durationHours = 24 * 7,  label = "VIP (7 дней)" },
        ["KRESTIK-PRO30DAYS01"] = { durationHours = 24 * 30, label = "PRO (30 дней)" },
        ["KRESTIK-OWNER999999"] = { durationHours = 0,       label = "Owner / Lifetime (Навсегда)", isAdmin = true }
    }
}

-- База редкостей предметов для Steal or Die (строго по возрастанию редкости)
local StealRarityOrder = {
    ["Common"]    = {rank = 1, label = "COMMON",    color = Color3.fromRGB(185, 192, 204), hex = "#B9C0CC"},
    ["Uncommon"]  = {rank = 2, label = "UNCOMMON",  color = Color3.fromRGB(34, 197, 94),   hex = "#22C55E"},
    ["Rare"]      = {rank = 3, label = "RARE",      color = Color3.fromRGB(59, 130, 246),  hex = "#3B82F6"},
    ["Epic"]      = {rank = 4, label = "EPIC",      color = Color3.fromRGB(168, 85, 247),  hex = "#A855F7"},
    ["Mythic"]    = {rank = 5, label = "MYTHIC",    color = Color3.fromRGB(239, 68, 68),   hex = "#EF4444"},
    ["Legendary"] = {rank = 6, label = "LEGENDARY", color = Color3.fromRGB(245, 158, 11),  hex = "#F59E0B"},
    ["Secret"]    = {rank = 7, label = "SECRET",    color = Color3.fromRGB(255, 0, 230),   hex = "#FF00E6"}
}

local StealMinRankMap = {
    ["All (Common+)"] = 1,
    ["Uncommon+"]     = 2,
    ["Rare+"]         = 3,
    ["Epic+"]         = 4,
    ["Mythic+"]       = 5,
    ["Legendary+"]    = 6,
    ["Secret Only"]   = 7
}

local Translations = {
    EN = {
        Title = "KRESTIK HUB V0.9",
        TabMovement = "Movement",
        TabCombat = "Combat",
        TabVehicle = "Vehicle",
        TabVisuals = "Visuals",
        TabTeleport = "Teleport",
        TabDynamic = "Game Mode", 
        TabUtilities = "Utilities",
        TabSystem = "System",
        LangLabel = "Language",
        ActiveGameModeLabel = "Active Game Mode",
        AntiAfk = "Anti-AFK",
        AntiCheatBypass = "Roblox Anti-Cheat Bypass (Full Shield)",
        ACShieldStatusLabel = "Roblox AC Shield: ACTIVE | Intercepted: ",
        ACShieldOffLabel = "Roblox AC Shield: DISABLED",
        ACReapplyBtn = "Refresh AC Bypass & Clean Hooks",
        KeyResetBtn = "Reset Saved Key",
        KeyGenCategory = "Key Category Preset",
        KeyGenCustomLabel = "Custom Category Name",
        KeyGenCustomLabelPh = "e.g. YouTuber / VIP",
        KeyGenHours = "Duration (Hours, 0=Lifetime)",
        KeyGenAmount = "Keys Count (1-50)",
        KeyGenUserId = "Lock to UserId (0=Any)",
        KeyGenCopyJsonBtn = "Generate Keys & Copy JSON",
        KeyGenGitHubToken = "GitHub Token (Auto-Upload)",
        KeyGenGitHubTokenPh = "ghp_xxxxxxxxxxxx",
        KeyGenPushGitHubBtn = "Generate & Push to GitHub keys.json",
        MenuBind = "Menu Key",
        FpsBoost = "Ultra FPS Boost (Potato PC)",
        Discord = "Copy Discord Link",
        Unload = "Unload Hub",
        SpeedOn = "Speed Hack (Anti T-Pose)",
        SpeedMethod = "Speed Bypass Method",
        SpeedPower = "Speed Power",
        AdaptiveSpeed = "Wall & Step Slide Radar",
        FlyOn = "Stealth Fly (No Instances)",
        FlySpeed = "Fly Speed",
        NoClipOn = "Persistent NoClip",
        SmartNoClip = "Floor Guard (Prevent Falling)",
        InfJumpOn = "Infinite Jump",
        JumpOn = "Jump Power",
        JumpPower = "Jump Height",
        AntiRagdoll = "Anti-Ragdoll",
        AntiSlip = "Anti-Slip",

        AutoClickerOn = "Auto Clicker",
        AutoClickerCPS = "Click Speed (CPS)",
        AutoClickerButton = "Click Button",

        VehicleSpeedOn = "Vehicle Boost (No Suspension Bug)",
        VehicleSpeedMethod = "Vehicle Boost Mode",
        VehicleSpeed = "Acceleration Power",
        VehicleJumpOn = "Vehicle Jump",
        VehicleJumpPower = "Vehicle Jump Height",
        VehicleFlyOn = "Vehicle Fly",
        VehicleFlySpeed = "Vehicle Fly Speed",
        VehicleNoFlip = "Safe Auto-Flip (Suspension Safe)",
        VehicleInstantBrake = "Instant Brake (Key B)",

        AimbotOn = "Aimbot",
        AimbotPart = "Target Part",
        AimbotMethod = "Aimbot Method",
        AimbotBind = "Activation Key",
        AimbotFOV = "Aimbot FOV",
        AimbotSmoothness = "Smoothness",
        AimbotJitter = "Jitter Aim",
        AimbotTeamCheck = "Team Check",
        AimbotWallCheck = "Wall Check",
        AimbotPrediction = "Prediction",
        AimbotPredictionPower = "Prediction Power",
        Triggerbot = "Triggerbot",
        ESPOn = "ESP Highlight Enabled",
        ESPTagsOn = "Name & Distance Tags",
        ESPShowHP = "Show Health (HP) in Tags",
        ESPBoxesOn = "3D ESP Boxes",
        ESPTracers = "Tracers",
        ShowFOV = "Show FOV Circle",
        ESPTeamCheck = "Hide Teammates",
        ESPDistanceLimit = "ESP Max Distance",
        Fullbright = "Fullbright (Night Vision)",
        TweenTP = "Tween Teleport",
        TweenTPSpeed = "Tween Speed",
        ClickTP = "Click Teleport (Ctrl + LMB)",
        CoordsInput = "Target Coords",
        CoordsPlaceholder = "120, 45, -340",
        WarpCoordsBtn = "Teleport to Coords",
        SaveCoordsBtn = "Save Position",
        WarpSavedBtn = "Teleport Saved Position",
        WarpRandomBtn = "Teleport to Random",
        WarpClosestBtn = "Teleport to Closest",
        RejoinBtn = "Rejoin Server",
        HopEmptyServerBtn = "Join Lowest Player Server",
        SavedLocLabel = "Saved Location: ",
        None = "None",

        -- Driving Empire EN
        DERaceSelect = "Select Race Track",
        DERecordSeconds = "Desired Record (Seconds)",
        DELapsCount = "Laps Count (0 = Auto by Track)",
        DEHoverHeight = "Flight Height Above Road",
        DERecordActive = "Fly Route & Set Record (Auto)",
        DEAutoLoop = "Auto-Repeat Race (Money Farm)",
        DEShowCheckpointsESP = "Race Checkpoints ESP",
        DEShowTracksBtn = "Tracks, WR & Min Time Table",
        DENotInCarAlert = "Sit in a vehicle before starting a race!",
        DEMinClampAlert = "Time raised to safe track minimum: ",

        -- Steal or Die EN
        StealScanBtn = "Refresh Loot & Monster Scan",
        StealItemsESP = "ESP Items",
        StealMinRarity = "Min Rarity Filter",
        StealMonsterESP = "ESP Monster / AI Entity",
        StealExitESP = "ESP Exit & Vents",
        StealLootHUD = "Loot Radar (HUD)",
        StealAutoCollect = "Auto-Steal Nearby Items",
        StealTpBestBtn = "Teleport to Rarest Item",
        StealTpClosestBtn = "Teleport to Closest Item",
        StealTpExitBtn = "Teleport to Escape Exit",
        StealNoItemAlert = "No matching items found on map!",
        StealNoExitAlert = "Escape Exit not found yet!",

        -- UNO EN
        UnoAutoUno = "Instant Auto-UNO",
        UnoAutoCatch = "Instant Auto-Catch & Challenge",
        UnoAutoColor = "Auto Pick Best Wild Color",
        UnoShowCards = "Opponent Cards & Deck Tracker HUD",
        UnoSmartHint = "Highlight Best Move in Hand",
        UnoAutoPlay = "Auto Play Best Card",

        SpinBot = "SpinBot",
        SpinSpeed = "Spin Speed",
        LowGravity = "Custom Gravity",
        GravityValue = "Gravity Value",
        InstantInteract = "Instant Interact (0s Hold E)",
        ChatSpam = "Chat Spam",
        JesusWalk = "Jesus Walk",
        SitSpam = "Sit Spam",
        RagdollSelf = "Ragdoll Self",
        GetTpTool = "Get TP Tool",
        ModalTitle = "Key Configurator",
        ModalDesc = "Press key for",
        ModalClear = "Clear Key",
        ModalCancel = "Cancel",
        ModalStatusBound = "Bound to: ",
        ModalStatusNone = "No key bound"
    },
    RU = {
        Title = "KRESTIK HUB V0.9",
        TabMovement = "Движение",
        TabCombat = "Бой",
        TabVehicle = "Транспорт",
        TabVisuals = "Визуалы",
        TabTeleport = "Навигация",
        TabDynamic = "Режим игры", 
        TabUtilities = "Утилиты",
        TabSystem = "Система",
        LangLabel = "Язык интерфейса",
        ActiveGameModeLabel = "Активный режим игры",
        AntiAfk = "Защита от отключения (Anti-AFK)",
        AntiCheatBypass = "Обход анти-чита Roblox (Полная защита)",
        ACShieldStatusLabel = "Щит Roblox AC: АКТИВЕН | Перехвачено: ",
        ACShieldOffLabel = "Щит Roblox AC: ОТКЛЮЧЕН",
        ACReapplyBtn = "Обновить обход и очистить ловушки AC",
        KeyResetBtn = "Сбросить сохранённый ключ",
        KeyGenCategory = "Категория ключа",
        KeyGenCustomLabel = "Своё название категории",
        KeyGenCustomLabelPh = "Напр: VIP / Спонсор / Тестер",
        KeyGenHours = "Срок в часах (0 = Навсегда)",
        KeyGenAmount = "Кол-во ключей за раз (1-50)",
        KeyGenUserId = "Привязка к UserId (0 = Все)",
        KeyGenCopyJsonBtn = "Создать ключи (Скопировать JSON)",
        KeyGenGitHubToken = "GitHub Token (Авто-заливка)",
        KeyGenGitHubTokenPh = "ghp_xxxxxxxxxxxx",
        KeyGenPushGitHubBtn = "Создать и залить в GitHub keys.json",
        MenuBind = "Клавиша консоли управления",
        FpsBoost = "Макс. FPS Boost (Для слабых ПК)",
        Discord = "Скопировать ссылку Discord",
        Unload = "Полностью выгрузить хаб",
        SpeedOn = "Скоростной режим (Без T-Pose)",
        SpeedMethod = "Метод обхода скорости",
        SpeedPower = "Скорость движения",
        AdaptiveSpeed = "Умное скольжение вдоль стен",
        FlyOn = "Скрытый полет (Без объектов)",
        FlySpeed = "Скорость перемещения в полете",
        NoClipOn = "Усиленный NoClip (Анти-сброс)",
        SmartNoClip = "Защита от провала под пол",
        InfJumpOn = "Бесконечный прыжок",
        JumpOn = "Модификатор импульса прыжка",
        JumpPower = "Высота импульса прыжка",
        AntiRagdoll = "Исключить падение (Anti-Ragdoll)",
        AntiSlip = "Подавление скольжения (Anti-Slip)",

        AutoClickerOn = "Авто-кликер (Auto Clicker)",
        AutoClickerCPS = "Кликов в секунду (CPS)",
        AutoClickerButton = "Кнопка клика",

        VehicleSpeedOn = "Ускорение машины (Без проседания)",
        VehicleSpeedMethod = "Режим ускорения тачки",
        VehicleSpeed = "Сила разгона тачки",
        VehicleJumpOn = "Прыжок машины",
        VehicleJumpPower = "Высота прыжка тачки",
        VehicleFlyOn = "Полет на машине",
        VehicleFlySpeed = "Скорость полета тачки",
        VehicleNoFlip = "Мягкий авто-переворот (Без бага подвески)",
        VehicleInstantBrake = "Мгновенный тормоз (Клавиша B)",

        AimbotOn = "Автоматическая наводка (Aimbot)",
        AimbotPart = "Приоритетная часть тела",
        AimbotMethod = "Метод наведения прицела",
        AimbotBind = "Клавиша активации аима",
        AimbotFOV = "Радиус захвата цели (FOV)",
        AimbotSmoothness = "Сглаживание наводки",
        AimbotJitter = "Микро-дрожание прицела (Jitter)",
        AimbotTeamCheck = "Исключать союзников из целей",
        AimbotWallCheck = "Проверка преград (Raycast)",
        AimbotPrediction = "Предугадывание движения цели",
        AimbotPredictionPower = "Множитель предугадывания",
        Triggerbot = "Автоматический выстрел (Trigger)",
        ESPOn = "Подсветка игроков (Highlight)",
        ESPTagsOn = "Имена, дистанция и статус",
        ESPShowHP = "Отображать здоровье (HP)",
        ESPBoxesOn = "3D Границы объектов (Боксы)",
        ESPTracers = "Линии до целей (Трассеры)",
        ShowFOV = "Отображать радиус захвата аима",
        ESPTeamCheck = "Скрывать союзников",
        ESPDistanceLimit = "Макс. дальность прорисовки ESP",
        Fullbright = "Ночное зрение (Fullbright)",
        TweenTP = "Безопасный телепорт (Tween)",
        TweenTPSpeed = "Скорость безопасного телепорта",
        ClickTP = "Телепорт по клику (Ctrl+ЛКМ)",
        CoordsInput = "Координаты вектора (X, Y, Z)",
        CoordsPlaceholder = "Пример: 120, 45, -340",
        WarpCoordsBtn = "Телепортироваться по вектору",
        SaveCoordsBtn = "Запомнить текущие координаты",
        WarpSavedBtn = "Телепорт на сохраненную точку",
        WarpRandomBtn = "Телепорт к случайному игроку",
        WarpClosestBtn = "Телепорт к ближайшему игроку",
        RejoinBtn = "Перезайти на текущий сервер",
        HopEmptyServerBtn = "Найти пустой сервер (1 человек)",
        SavedLocLabel = "Сохраненная точка: ",
        None = "Отсутствует",

        -- Driving Empire RU
        DERaceSelect = "Выбор гонки",
        DERecordSeconds = "Желаемый рекорд (в секундах)",
        DELapsCount = "Кол-во кругов (0 = Авто)",
        DEHoverHeight = "Высота полета над дорогой",
        DERecordActive = "Полет по чекпоинтам (Рекорд)",
        DEAutoLoop = "Авто-повтор гонки (Фарм денег)",
        DEShowCheckpointsESP = "Подсветка чекпоинтов гонки (ESP)",
        DEShowTracksBtn = "Таблица гонок, WR и минимумов",
        DENotInCarAlert = "Сядьте в машину перед запуском рекорда!",
        DEMinClampAlert = "Время поднято до безопасного минимума трассы: ",

        -- Steal or Die RU
        StealScanBtn = "Обновить скан лута и монстра",
        StealItemsESP = "ESP Предметов",
        StealMinRarity = "Мин. редкость для ESP",
        StealMonsterESP = "ESP Монстра (ИИ)",
        StealExitESP = "ESP Выхода и Вентиляций",
        StealLootHUD = "Радар лута (HUD)",
        StealAutoCollect = "Авто-кража предметов рядом",
        StealTpBestBtn = "Телепорт к самому редкому предмету",
        StealTpClosestBtn = "Телепорт к ближайшему предмету",
        StealTpExitBtn = "Телепорт к Выходу (Побег)",
        StealNoItemAlert = "Подходящие предметы на карте не найдены!",
        StealNoExitAlert = "Выход с карты пока не найден!",

        -- UNO RU
        UnoAutoUno = "Мгновенный Auto-UNO",
        UnoAutoCatch = "Авто-подлов и челлендж (+4 / UNO)",
        UnoAutoColor = "Авто-выбор лучшего цвета (Wild)",
        UnoShowCards = "Карты игроков и счетчик колоды (HUD)",
        UnoSmartHint = "Подсветка лучшего хода в руке",
        UnoAutoPlay = "Авто-ход лучшей картой",

        SpinBot = "Вращение корпуса (SpinBot)",
        SpinSpeed = "Угловая скорость вращения",
        LowGravity = "Переопределение гравитации",
        GravityValue = "Сила гравитации плейса",
        InstantInteract = "Мгновенное действие (Без зажатия E)",
        ChatSpam = "Автоматический спам в чат",
        JesusWalk = "Хождение по поверхности воды",
        SitSpam = "Быстрое приседание (T-Bag)",
        RagdollSelf = "Симулировать перелом костей",
        GetTpTool = "Выдать инструмент телепортации",
        ModalTitle = "Настройка клавиши",
        ModalDesc = "Нажмите клавишу для привязки функции",
        ModalClear = "Очистить клавишу",
        ModalCancel = "Отмена",
        ModalStatusBound = "Привязано к: ",
        ModalStatusNone = "Клавиша не задана"
    }
}

local function langStr(key)
    local dict = Translations[Config.Language] or Translations.RU
    return dict[key] or key
end

local function playClickSound()
    pcall(function()
        local sound = Instance.new("Sound", SoundService)
        sound.SoundId = "rbxassetid://8233519154"
        sound.Volume = 0.08
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
    end)
end

local function triggerGuiButton(btn)
    if not btn or not btn.Parent then return false end
    local clicked = false
    if firesignal then
        pcall(function()
            if btn.MouseButton1Click then firesignal(btn.MouseButton1Click) clicked = true end
            if btn.Activated then firesignal(btn.Activated) clicked = true end
            if btn.MouseButton1Down then firesignal(btn.MouseButton1Down) end
            if btn.MouseButton1Up then firesignal(btn.MouseButton1Up) end
        end)
    end
    if not clicked then
        pcall(function()
            local vim = game:GetService("VirtualInputManager")
            local pos = btn.AbsolutePosition + (btn.AbsoluteSize / 2)
            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
            task.wait(0.01)
            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
            clicked = true
        end)
    end
    return clicked
end

local function triggerPrompt(prompt)
    if not prompt or not prompt.Parent or not prompt.Enabled then return false end
    if fireproximityprompt then
        local ok = pcall(function()
            fireproximityprompt(prompt)
        end)
        if ok then return true end
    end
    pcall(function()
        local oldHold = prompt.HoldDuration
        prompt.HoldDuration = 0
        prompt:InputHoldBegin()
        task.wait(0.02)
        prompt:InputHoldEnd()
        prompt.HoldDuration = oldHold
    end)
    return true
end

local function performMouseClick(isRight)
    if isRight then
        if mouse2click then
            pcall(mouse2click)
            return
        end
    else
        if mouse1click then
            pcall(mouse1click)
            return
        end
    end
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        local pos = UserInputService:GetMouseLocation()
        local btn = isRight and 1 or 0
        vim:SendMouseButtonEvent(pos.X, pos.Y, btn, true, game, 1)
        task.wait(0.01)
        vim:SendMouseButtonEvent(pos.X, pos.Y, btn, false, game, 1)
    end)
end

local function RejoinCurrentServer()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

local function JoinLowestPlayerServer()
    local placeId = game.PlaceId
    local url = string.format("https://games.roblox.com/v1/games/%s/servers/0?sortOrder=Asc&limit=100", tostring(placeId))
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "KRESTIK HUB",
        Text = langStr("HopEmptyServerBtn") .. "...",
        Duration = 3
    })

    task.spawn(function()
        local success, result = pcall(function() return game:HttpGet(url) end)
        if success and result then
            local data = HttpService:JSONDecode(result)
            if data and data.data then
                for _, server in ipairs(data.data) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                        return
                    end
                end
            end
        end
        RejoinCurrentServer()
    end)
end

local targetCoords = {x = 0, y = 0, z = 0}
local savedCoords = nil

local AC = { BlockedCount = 0 }
local EspContainer, getCharacter, rebuildVehiclePartCache, isLocalCharPart, isLocalVehiclePart
local CachedLocalVehicleModel = nil
local CachedVehiclePartSet = {}
local CachedVehiclePartsList = {}
do
    local HiddenInstances = setmetatable({}, {__mode = "k"})
    AC.BlockedCount = 0

    function AC.AC.AC.markStealthInstance(inst)
        if inst then
            HiddenInstances[inst] = true
        end
        return inst
    end

    local function isStealthInstance(inst)
        if not inst then return false end
        if HiddenInstances[inst] then return true end
        local p = inst.Parent
        while p do
            if HiddenInstances[p] then
                HiddenInstances[inst] = true
                return true
            end
            p = p.Parent
        end
        return false
    end

    function AC.AC.AC.protectStealthGui(guiObj)
        AC.AC.markStealthInstance(guiObj)
        pcall(function()
            if syn and syn.protect_gui then
                syn.protect_gui(guiObj)
            elseif protect_gui then
                protect_gui(guiObj)
            elseif gethiddenui then
                guiObj.Parent = gethiddenui()
            end
        end)
    end

    function AC.AC.AC.generateNativeStealthName(prefix)
        return (prefix or "RobloxGui_") .. HttpService:GenerateGUID(false):gsub("-", ""):sub(1, 10)
    end

    -- Безопасная выгрузка предыдущей копии хаба через Lua-среду (без следов в DataModel)
    pcall(function()
        local env = (getgenv and getgenv()) or _G
        if env and type(env._KrestikHubCleanup) == "function" then
            pcall(env._KrestikHubCleanup)
        end
    end)

    AC.AC.targetParent = nil
    local successParent = pcall(function()
        AC.targetParent = (gethui and gethui()) or getSafeService("CoreGui")
    end)
    if not successParent or not AC.targetParent then
        AC.targetParent = LocalPlayer:WaitForChild("PlayerGui")
    end

    for _, child in ipairs(AC.targetParent:GetChildren()) do
        if child.Name == "KrestikHubV3_Final" or child.Name == "KrestikHub_UI" or child:GetAttribute("IsKrestikHub") then
            pcall(function() child:Destroy() end)
        end
    end

    EspContainer = AC.AC.markStealthInstance(Instance.new("Folder"))
    EspContainer.Name = AC.AC.generateNativeStealthName("CoreRender_")
    local okEspParent = pcall(function()
        EspContainer.Parent = AC.targetParent
    end)
    if not okEspParent or not EspContainer.Parent then
        AC.targetParent = LocalPlayer:WaitForChild("PlayerGui")
        EspContainer.Parent = AC.targetParent
    end

    getCharacter = function(player)
        if not player then return nil end
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            return player.Character
        end
        local char = Workspace:FindFirstChild(player.Name) or Workspace:FindFirstChild(player.DisplayName)
        if char and char:IsA("Model") and char:FindFirstChild("HumanoidRootPart") then
            return char
        end
        return nil
    end





    rebuildVehiclePartCache = function(vehModel)
        if CachedLocalVehicleModel == vehModel and #CachedVehiclePartsList > 0 then
            return
        end
        CachedLocalVehicleModel = vehModel
        table.clear(CachedVehiclePartSet)
        table.clear(CachedVehiclePartsList)
        if vehModel and vehModel.Parent then
            for _, d in ipairs(vehModel:GetDescendants()) do
                if d:IsA("BasePart") then
                    CachedVehiclePartSet[d] = true
                    table.insert(CachedVehiclePartsList, d)
                end
            end
        end
    end

    isLocalCharPart = function(inst)
        local char = LocalPlayer and LocalPlayer.Character
        return char and (inst == char or inst:IsDescendantOf(char))
    end

    isLocalVehiclePart = function(inst)
        if CachedVehiclePartSet[inst] then return true end
        local veh = CachedLocalVehicleModel
        return veh and veh.Parent and (inst == veh or inst:IsDescendantOf(veh))
    end

    -----------------------------------------------------------
    -- УНИВЕРСАЛЬНЫЙ ОБХОД ROBLOX ANTI-CHEAT (BYFRON / CLIENT / SERVER SHIELD)
    -----------------------------------------------------------
    local function isSuspiciousACName(rawName)
        local name = tostring(rawName):lower()
        return name:find("anticheat") or name:find("anti_cheat") or name:find("anti%-cheat")
            or name:find("ac_check") or name:find("ac_detect") or name:find("ac_log") or name:find("ac_report")
            or name:find("cheatdetect") or name:find("exploitdetect") or name:find("securitycheck")
            or name:find("tamper") or name:find("integrity") or name:find("flagplayer")
            or name:find("speedhack") or name:find("noclip") or name:find("flydetect")
            or name:find("verifypos") or name:find("positioncheck") or name:find("rubberband")
            or name:find("telemetry") or name:find("banremote") or name:find("kickremote")
            or name:find("logerror") or name:find("clienterror") or name:find("scripterror")
            or name:find("stacktrace") or name:find("violat") or name:find("punish")
            or name:find("hyperion") or name:find("byfron") or name:find("adonis")
    end

    function AC.sanitizeConnections()
        if not getconnections then return end
        local signalsToClean = {
            LocalPlayer and LocalPlayer.Idled,
            LogService and LogService.MessageOut,
            ScriptContext and ScriptContext.Error
        }

        local char = getCharacter(LocalPlayer)
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if hum then
                table.insert(signalsToClean, hum.StateChanged)
                pcall(function() table.insert(signalsToClean, hum:GetPropertyChangedSignal("WalkSpeed")) end)
                pcall(function() table.insert(signalsToClean, hum:GetPropertyChangedSignal("JumpPower")) end)
                pcall(function() table.insert(signalsToClean, hum:GetPropertyChangedSignal("JumpHeight")) end)
                pcall(function() table.insert(signalsToClean, hum:GetPropertyChangedSignal("PlatformStand")) end)
            end
            if root then
                pcall(function() table.insert(signalsToClean, root:GetPropertyChangedSignal("CanCollide")) end)
                pcall(function() table.insert(signalsToClean, root:GetPropertyChangedSignal("AssemblyLinearVelocity")) end)
            end
        end

        for _, sig in ipairs(signalsToClean) do
            if sig then
                pcall(function()
                    for _, conn in ipairs(getconnections(sig)) do
                        if conn.Function and (not isourclosure or not isourclosure(conn.Function)) then
                            local info = debug and debug.getinfo and debug.getinfo(conn.Function)
                            local src = info and tostring(info.source):lower() or ""
                            if src == "" or src:find("anticheat") or src:find("anti_cheat") or src:find("exploit")
                                or src:find("security") or src:find("client") or src:find("adonis") or src:find("detect") then
                                conn:Disable()
                                AC.BlockedCount = AC.BlockedCount + 1
                            end
                        end
                    end
                end)
            end
        end
    end

    function AC.grantPhysicsAuthority()
        pcall(function()
            if setsimulationradius then
                setsimulationradius(math.huge, math.huge)
            elseif sethiddenproperty then
                sethiddenproperty(LocalPlayer, "MaximumSimulationRadius", math.huge)
                sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            end
        end)
    end

    pcall(function()
        if hookmetamethod and newcclosure and getnamecallmethod and checkcaller then
            local dummyKickFn = newcclosure(function()
                AC.BlockedCount = AC.BlockedCount + 1
                return nil
            end)

            -- Прямой перехват LocalPlayer.Kick через hookfunction (на случай кэширования функции анти-читом)
            if hookfunction then
                pcall(function()
                    local origKick = LocalPlayer.Kick
                    if origKick then
                        hookfunction(origKick, newcclosure(function(self, ...)
                            if running and Config.AntiCheatBypass and not checkcaller() and self == LocalPlayer then
                                AC.BlockedCount = AC.BlockedCount + 1
                                return nil
                            end
                            return origKick(self, ...)
                        end))
                    end
                end)
            end

            local old_index
            old_index = hookmetamethod(game, "__index", newcclosure(function(self, key)
                if running and Config.AntiCheatBypass and not checkcaller() then
                    if self == LocalPlayer and (key == "Kick" or key == "kick") then
                        AC.BlockedCount = AC.BlockedCount + 1
                        return dummyKickFn
                    elseif key == "WalkSpeed" or key == "JumpPower" or key == "JumpHeight" or key == "HipHeight" or key == "PlatformStand" or key == "Sit" or key == "AutoRotate" then
                        if typeof(self) == "Instance" and self:IsA("Humanoid") and isLocalCharPart(self) then
                            if key == "WalkSpeed" then return 16 end
                            if key == "JumpPower" then return 50 end
                            if key == "JumpHeight" then return 7.2 end
                            if key == "HipHeight" then return 2.0 end
                            if key == "PlatformStand" and (Config.FlyOn or Config.DERecordActive) then return false end
                            if key == "Sit" and Config.SitSpam then return false end
                            if key == "AutoRotate" and Config.SpinBot then return true end
                        end
                    elseif key == "CanCollide" or key == "AssemblyLinearVelocity" or key == "Velocity" or key == "AssemblyAngularVelocity" or key == "RotVelocity" then
                        if typeof(self) == "Instance" then
                            if (Config.DERecordActive or Config.VehicleFlyOn or Config.VehicleSpeedOn or Config.VehicleNoFlip) and CachedVehiclePartSet[self] then
                                if key == "CanCollide" then
                                    return true
                                elseif key == "AssemblyAngularVelocity" or key == "RotVelocity" then
                                    return Vector3.zero
                                else
                                    local realVel = old_index(self, key)
                                    if realVel.Magnitude > 165 then
                                        return realVel.Unit * 155
                                    end
                                end
                            elseif self:IsA("BasePart") and isLocalCharPart(self) then
                                if key == "CanCollide" and Config.NoClipOn then
                                    return true
                                elseif (key == "AssemblyAngularVelocity" or key == "RotVelocity") and Config.SpinBot then
                                    return Vector3.zero
                                elseif (key == "AssemblyLinearVelocity" or key == "Velocity") and (Config.SpeedOn or Config.FlyOn or Config.JumpOn or Config.InfJumpOn or Config.JesusWalk or Config.TweenTP) then
                                    local callerScript = getcallingscript and getcallingscript()
                                    if callerScript and callerScript.Name == "Animate" then
                                        return old_index(self, key)
                                    end
                                    local realVel = old_index(self, key)
                                    local horiz = Vector3.new(realVel.X, 0, realVel.Z)
                                    local clampedY = math.clamp(realVel.Y, -55, 52)
                                    if horiz.Magnitude > 18 then
                                        local clamped = horiz.Unit * 16
                                        return Vector3.new(clamped.X, clampedY, clamped.Z)
                                    elseif realVel.Y ~= clampedY then
                                        return Vector3.new(realVel.X, clampedY, realVel.Z)
                                    end
                                end
                            end
                        end
                    elseif key == "Gravity" and self == Workspace then
                        return 196.2
                    end
                end
                return old_index(self, key)
            end))

            local old_newindex
            old_newindex = hookmetamethod(game, "__newindex", newcclosure(function(self, key, value)
                if running and Config.AntiCheatBypass and not checkcaller() then
                    if key == "CanCollide" and value == true then
                        if (Config.DERecordActive or Config.VehicleFlyOn) and CachedVehiclePartSet[self] then
                            return
                        elseif typeof(self) == "Instance" and self:IsA("BasePart") and isLocalCharPart(self) and Config.NoClipOn then
                            return
                        end
                    elseif (key == "WalkSpeed" or key == "JumpPower" or key == "JumpHeight" or key == "PlatformStand") then
                        if typeof(self) == "Instance" and self:IsA("Humanoid") and isLocalCharPart(self) then
                            if key == "WalkSpeed" and Config.SpeedOn then return end
                            if key == "JumpPower" and Config.JumpOn then return end
                            if key == "JumpHeight" and Config.JumpOn then return end
                            if key == "PlatformStand" and value == true and (Config.FlyOn or Config.AntiRagdoll) then return end
                        end
                    elseif key == "Gravity" and self == Workspace and Config.LowGravity then
                        return
                    end
                end
                return old_newindex(self, key, value)
            end))

            local old_namecall
            old_namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if running and Config.AntiCheatBypass and not checkcaller() then
                    if typeof(self) == "Instance" then
                        if self == LocalPlayer and (method == "Kick" or method == "kick") then
                            AC.BlockedCount = AC.BlockedCount + 1
                            return nil
                        end

                        -- Скрытие всех GUI/ESP объектов хаба от сканирования CoreGui / PlayerGui / Workspace
                        if (method == "GetChildren" or method == "GetDescendants") and (self == AC.targetParent or self == Workspace or self == EspContainer) then
                            local res = old_namecall(self, ...)
                            if type(res) == "table" then
                                local filtered = {}
                                for i = 1, #res do
                                    local item = res[i]
                                    if not isStealthInstance(item) then
                                        filtered[#filtered + 1] = item
                                    end
                                end
                                return filtered
                            end
                            return res
                        elseif (method == "FindFirstChild" or method == "FindFirstChildWhichIsA" or method == "FindFirstChildOfClass") and (self == AC.targetParent or self == Workspace) then
                            local found = old_namecall(self, ...)
                            if found and isStealthInstance(found) then
                                return nil
                            end
                            return found
                        end

                        -- Подмена состояния Humanoid (GetState) во время полета/NoClip/AntiRagdoll
                        if method == "GetState" and self:IsA("Humanoid") and isLocalCharPart(self) then
                            local st = old_namecall(self, ...)
                            if (Config.FlyOn or Config.NoClipOn or Config.DERecordActive) and (st == Enum.HumanoidStateType.PlatformStanding or st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.StrafingNoPhysics) then
                                return Enum.HumanoidStateType.Running
                            end
                            if Config.AntiRagdoll and (st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown) then
                                return Enum.HumanoidStateType.Running
                            end
                            return st
                        end

                        -- Блокировка анти-чит ремоутов и телеметрии
                        if method == "FireServer" or method == "InvokeServer" or method == "Fire" or method == "Invoke" then
                            if isSuspiciousACName(self.Name) then
                                AC.BlockedCount = AC.BlockedCount + 1
                                return nil
                            end
                            -- Блокируем передачу строк с сигнатурами экзекутора / стектрейса в репорт-ремоуты
                            local firstArg = select(1, ...)
                            if type(firstArg) == "string" then
                                local lowArg = firstArg:lower()
                                if lowArg:find("exploit") or lowArg:find("anticheat") or lowArg:find("speedhack") or lowArg:find("flyhack") or lowArg:find("noclip") then
                                    AC.BlockedCount = AC.BlockedCount + 1
                                    return nil
                                end
                            end
                        end
                    end
                end
                return old_namecall(self, ...)
            end))
        end
    end)

    AC.sanitizeConnections()
    AC.grantPhysicsAuthority()

    table.insert(connections, LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.4)
        if running and Config.AntiCheatBypass then
            AC.sanitizeConnections()
            AC.grantPhysicsAuthority()
        end
    end))

    table.insert(threads, task.spawn(function()
        while running do
            task.wait(4.0)
            if Config.AntiCheatBypass then
                AC.sanitizeConnections()
                AC.grantPhysicsAuthority()
            end
        end
    end))

end

local function getVehicleData()
    local char = getCharacter(LocalPlayer)
    if not char then return nil, nil, nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return nil, nil, nil end

    local seat = nil
    if hum.SeatPart:IsA("VehicleSeat") then
        seat = hum.SeatPart
    elseif hum.SeatPart.Parent then
        seat = hum.SeatPart.Parent:FindFirstChildOfClass("VehicleSeat") or hum.SeatPart
    end

    if not seat then
        CachedLocalVehicleModel = nil
        table.clear(CachedVehiclePartSet)
        table.clear(CachedVehiclePartsList)
        return nil, nil, nil
    end
    local rootPart = seat.AssemblyRootPart or seat
    local vehicleModel = seat:FindFirstAncestorOfClass("Model")
    if vehicleModel ~= CachedLocalVehicleModel then
        rebuildVehiclePartCache(vehicleModel)
    end
    return seat, rootPart, vehicleModel
end

local UI = { tabs = {}, UI.tabButtons = {}, UI.activeTab = nil, Elements = {}, UI.isKeyAuthenticated = not KeySystemConfig.Enabled }
local gui, mainFrame, sidebar, tabsContainer, speedTab, aimTab, vehicleTab, espTab, teleportTab
do
    gui = AC.markStealthInstance(Instance.new("ScreenGui"))
    gui.Name = AC.generateNativeStealthName("RobloxGui_")
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    AC.protectStealthGui(gui)
    if not gui.Parent then
        local okGuiP = pcall(function()
            gui.Parent = AC.targetParent
        end)
        if not okGuiP or not gui.Parent then
            gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end

    mainFrame = Instance.new("Frame", gui)
    mainFrame.Size = UDim2.new(0, 560, 0, 390)
    mainFrame.Position = UDim2.new(0.5, -280, 0.5, -195)
    mainFrame.BackgroundColor3 = Config.BGColor
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.ClipsDescendants = true

    local mainCorner = Instance.new("UICorner", mainFrame)
    mainCorner.CornerRadius = UDim.new(0, 6)

    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = Config.BorderColor
    mainStroke.Thickness = 1.0

    local topBar = Instance.new("Frame", mainFrame)
    topBar.Size = UDim2.new(1, 0, 0, 36)
    topBar.BackgroundColor3 = Color3.fromRGB(18, 19, 24)
    topBar.BorderSizePixel = 0

    function UI.makeDraggable(dragHandle, targetFrame)
        local dragging = false
        local dragInput, dragStart, startPos

        dragHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = targetFrame.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        dragHandle.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        table.insert(connections, UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                targetFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end))
    end

    UI.makeDraggable(topBar, mainFrame)

    local topCorner = Instance.new("UICorner", topBar)
    topCorner.CornerRadius = UDim.new(0, 6)

    local titleLabel = Instance.new("TextLabel", topBar)
    titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    titleLabel.Position = UDim2.new(0.03, 0, 0, 0)
    titleLabel.Text = langStr("Title")
    titleLabel.TextColor3 = Color3.fromRGB(240, 242, 245)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 11
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.BackgroundTransparency = 1

    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -28, 0.5, -11)
    closeBtn.BackgroundColor3 = Config.PanelColor
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 10
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
    local closeStroke = Instance.new("UIStroke", closeBtn)
    closeStroke.Color = Config.BorderColor

    local OpenDropdowns = {}
    local function closeAllDropdowns(exceptContainer)
        for cont, setClosed in pairs(OpenDropdowns) do
            if cont ~= exceptContainer and cont.Visible then
                setClosed()
            end
        end
    end



    function UI.toggleMenu()
        if not UI.isKeyAuthenticated then return end
        menuOpen = not menuOpen
        mainFrame.Visible = menuOpen
        if not menuOpen then
            closeAllDropdowns(nil)
        end
    end

    closeBtn.MouseEnter:Connect(function()
        closeBtn.BackgroundColor3 = Config.ThemeColor
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    closeBtn.MouseLeave:Connect(function()
        closeBtn.BackgroundColor3 = Config.PanelColor
        closeBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        playClickSound()
        UI.toggleMenu()
    end)

    sidebar = Instance.new("Frame", mainFrame)
    sidebar.Size = UDim2.new(0, 135, 1, -36)
    sidebar.Position = UDim2.new(0, 0, 0, 36)
    sidebar.BackgroundColor3 = Color3.fromRGB(18, 19, 24)
    sidebar.BorderSizePixel = 0

    tabsContainer = Instance.new("Frame", mainFrame)
    tabsContainer.Size = UDim2.new(1, -150, 1, -48)
    tabsContainer.Position = UDim2.new(0, 142, 0, 42)
    tabsContainer.BackgroundTransparency = 1

    local tabs = UI.tabs
    local UI.tabButtons = UI.tabButtons


    local bindModal = Instance.new("Frame", mainFrame)
    bindModal.Size = UDim2.new(0, 260, 0, 150)
    bindModal.Position = UDim2.new(0.5, -130, 0.5, -75)
    bindModal.BackgroundColor3 = Config.BGColor
    bindModal.ZIndex = 100
    bindModal.Visible = false
    Instance.new("UICorner", bindModal).CornerRadius = UDim.new(0, 6)
    local modalStroke = Instance.new("UIStroke", bindModal)
    modalStroke.Color = Config.ThemeColor
    modalStroke.Thickness = 1.0

    local modalTitle = Instance.new("TextLabel", bindModal)
    modalTitle.Size = UDim2.new(1, 0, 0, 30)
    modalTitle.BackgroundTransparency = 1
    modalTitle.Font = Enum.Font.GothamBold
    modalTitle.TextSize = 11
    modalTitle.TextColor3 = Color3.fromRGB(240, 242, 245)
    modalTitle.ZIndex = 101

    local modalDesc = Instance.new("TextLabel", bindModal)
    modalDesc.Size = UDim2.new(0.9, 0, 0, 40)
    modalDesc.Position = UDim2.new(0.05, 0, 0, 32)
    modalDesc.BackgroundTransparency = 1
    modalDesc.Font = Enum.Font.Gotham
    modalDesc.TextSize = 10
    modalDesc.TextColor3 = Color3.fromRGB(160, 165, 180)
    modalDesc.TextWrapped = true
    modalDesc.ZIndex = 101

    local modalStatus = Instance.new("TextLabel", bindModal)
    modalStatus.Size = UDim2.new(0.9, 0, 0, 25)
    modalStatus.Position = UDim2.new(0.05, 0, 0, 75)
    modalStatus.BackgroundTransparency = 1
    modalStatus.Font = Enum.Font.Code
    modalStatus.TextSize = 11
    modalStatus.TextColor3 = Config.ThemeAccent
    modalStatus.ZIndex = 101

    local modalClearBtn = Instance.new("TextButton", bindModal)
    modalClearBtn.Size = UDim2.new(0, 110, 0, 26)
    modalClearBtn.Position = UDim2.new(0.05, 0, 0.76, 0)
    modalClearBtn.BackgroundColor3 = Color3.fromRGB(45, 25, 30)
    modalClearBtn.Font = Enum.Font.GothamBold
    modalClearBtn.TextSize = 10
    modalClearBtn.TextColor3 = Color3.fromRGB(240, 90, 90)
    modalClearBtn.ZIndex = 101
    Instance.new("UICorner", modalClearBtn).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", modalClearBtn).Color = Config.BorderColor

    local modalCancelBtn = Instance.new("TextButton", bindModal)
    modalCancelBtn.Size = UDim2.new(0, 110, 0, 26)
    modalCancelBtn.Position = UDim2.new(0.55, 0, 0.76, 0)
    modalCancelBtn.BackgroundColor3 = Config.PanelColor
    modalCancelBtn.Font = Enum.Font.GothamBold
    modalCancelBtn.TextSize = 10
    modalCancelBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
    modalCancelBtn.ZIndex = 101
    Instance.new("UICorner", modalCancelBtn).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", modalCancelBtn).Color = Config.BorderColor

    local activeBindingKey = nil
    local activeBindingType = nil
    local activeBindingCallback = nil
    local isListeningForBind = false

    local UI.Elements = UI.Elements

    function UI.registerText(obj, translationKey, suffix)
        table.insert(UI.Elements, {instance = obj, key = translationKey, suffix = suffix or ""})
        obj.Text = langStr(translationKey) .. (suffix or "")
    end

    function UI.refreshAllTranslations()
        titleLabel.Text = langStr("Title")
        modalTitle.Text = langStr("ModalTitle")
        modalClearBtn.Text = langStr("ModalClear")
        modalCancelBtn.Text = langStr("ModalCancel")

        for _, item in ipairs(UI.Elements) do
            if item.instance and item.instance.Parent then
                if item.updateFunc then
                    item.updateFunc()
                else
                    item.instance.Text = langStr(item.key) .. (item.suffix or "")
                end
            end
        end
    end

    table.insert(connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentBind then
            UI.toggleMenu()
            return
        end

        if isListeningForBind then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local code = input.KeyCode
                if code ~= Enum.KeyCode.Unknown and code ~= Enum.KeyCode.Escape then
                    for oldKey, data in pairs(FeatureBinds) do
                        if data.configKey == activeBindingKey then
                            FeatureBinds[oldKey] = nil
                        end
                    end

                    FeatureBinds[code] = {
                        type = activeBindingType,
                        configKey = activeBindingKey,
                        callback = activeBindingCallback
                    }

                    ConfigKeyToBindName[activeBindingKey] = code.Name
                    modalStatus.Text = langStr("ModalStatusBound") .. code.Name
                    isListeningForBind = false
                    task.wait(0.3)
                    bindModal.Visible = false
                    UI.refreshAllTranslations()
                end
            end
            return
        end

        if gpe then return end

        local bound = FeatureBinds[input.KeyCode]
        if bound then
            playClickSound()
            if bound.type == "toggle" then
                Config[bound.configKey] = not Config[bound.configKey]
                local toggleRef = tabsContainer:FindFirstChild(bound.configKey, true)
                local switch = toggleRef and toggleRef:FindFirstChild("Switch")
                local dot = switch and switch:FindFirstChild("Dot")
                if switch and dot then
                    switch.BackgroundColor3 = Config[bound.configKey] and Config.ThemeColor or Color3.fromRGB(45, 48, 60)
                    dot.Position = Config[bound.configKey] and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4)
                end
                if bound.callback then bound.callback(Config[bound.configKey]) end
            elseif bound.type == "button" then
                if bound.callback then bound.callback() end
            end
        end
    end))

    modalCancelBtn.MouseButton1Click:Connect(function()
        playClickSound()
        isListeningForBind = false
        bindModal.Visible = false
    end)

    modalClearBtn.MouseButton1Click:Connect(function()
        playClickSound()
        for oldKey, data in pairs(FeatureBinds) do
            if data.configKey == activeBindingKey then
                FeatureBinds[oldKey] = nil
            end
        end
        ConfigKeyToBindName[activeBindingKey] = nil
        modalStatus.Text = langStr("ModalStatusNone")
        isListeningForBind = false
        task.wait(0.2)
        bindModal.Visible = false
        UI.refreshAllTranslations()
    end)

    local function openBindModal(configKey, featureNameKey, bindType, callback)
        activeBindingKey = configKey
        activeBindingType = bindType
        activeBindingCallback = callback
        isListeningForBind = true

        modalDesc.Text = langStr("ModalDesc") .. ' "' .. langStr(featureNameKey) .. '"'
        local currentBindName = ConfigKeyToBindName[configKey]
        if currentBindName then
            modalStatus.Text = langStr("ModalStatusBound") .. currentBindName
        else
            modalStatus.Text = langStr("ModalStatusNone")
        end

        bindModal.Visible = true
    end

    function UI.updateTabPositions()
        local visibleCount = 0
        for _, btn in ipairs(UI.tabButtons) do
            if btn.Visible then
                btn.Position = UDim2.new(0.05, 0, 0, 8 + (visibleCount * 31))
                visibleCount = visibleCount + 1
            end
        end
    end

    function UI.activateTabByName(name)
        closeAllDropdowns(nil)
        for _, otherBtn in ipairs(UI.tabButtons) do
            otherBtn.BackgroundColor3 = Config.PanelColor
            otherBtn.TextColor3 = Color3.fromRGB(160, 165, 180)
            local stroke = otherBtn:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = Config.BorderColor end
        end
        for _, otherTab in pairs(tabs) do
            otherTab.Visible = false
        end

        local targetBtn = sidebar:FindFirstChild("TabBtn_" .. name)
        local targetTab = tabs[name]
        if targetBtn and targetTab then
            targetBtn.BackgroundColor3 = Config.ThemeColor
            targetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            local stroke = targetBtn:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = Color3.fromRGB(255, 255, 255) end
            targetTab.Visible = true
            UI.activeTab = name
        end
    end

    function UI.createTab(name, displayNameKey)
        local tabFrame = Instance.new("ScrollingFrame", tabsContainer)
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.ScrollBarThickness = 2
        tabFrame.ScrollBarImageColor3 = Config.ThemeColor
        tabFrame.Visible = false
        tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

        local layout = Instance.new("UIListLayout", tabFrame)
        layout.Padding = UDim.new(0, 4)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local padding = Instance.new("UIPadding", tabFrame)
        padding.PaddingTop = UDim.new(0, 2)
        padding.PaddingBottom = UDim.new(0, 2)
        padding.PaddingRight = UDim.new(0, 6)

        tabs[name] = tabFrame

        local btn = Instance.new("TextButton", sidebar)
        btn.Name = "TabBtn_" .. name
        btn.Size = UDim2.new(0.9, 0, 0, 28)
        btn.BackgroundColor3 = Config.PanelColor
        btn.TextColor3 = Color3.fromRGB(160, 165, 180)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = Config.BorderColor
        btnStroke.Thickness = 1.0

        UI.registerText(btn, displayNameKey)

        btn.MouseEnter:Connect(function()
            if UI.activeTab ~= name then
                btn.TextColor3 = Config.ThemeAccent
                btnStroke.Color = Config.ThemeColor
            end
        end)
        btn.MouseLeave:Connect(function()
            if UI.activeTab ~= name then
                btn.TextColor3 = Color3.fromRGB(160, 165, 180)
                btnStroke.Color = Config.BorderColor
            end
        end)

        btn.MouseButton1Click:Connect(function()
            playClickSound()
            UI.activateTabByName(name)
        end)

        table.insert(UI.tabButtons, btn)
        UI.updateTabPositions()
        return tabFrame
    end

    function UI.createToggle(parent, featureKey, callback)
        local toggleFrame = Instance.new("Frame", parent)
        toggleFrame.Name = featureKey
        toggleFrame.Size = UDim2.new(0.98, 0, 0, 32)
        toggleFrame.BackgroundColor3 = Config.PanelColor
        Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 4)
        Instance.new("UIStroke", toggleFrame).Color = Config.BorderColor

        local label = Instance.new("TextLabel", toggleFrame)
        label.Size = UDim2.new(0.65, 0, 1, 0)
        label.Position = UDim2.new(0.03, 0, 0, 0)
        label.TextColor3 = Color3.fromRGB(210, 215, 225)
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1
        UI.registerText(label, featureKey)

        local switch = Instance.new("TextButton", toggleFrame)
        switch.Name = "Switch"
        switch.Size = UDim2.new(0, 26, 0, 12)
        switch.Position = UDim2.new(0.84, -26, 0.5, -6)
        switch.BackgroundColor3 = Config[featureKey] and Config.ThemeColor or Color3.fromRGB(45, 48, 60)
        switch.Text = ""
        Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

        local dot = Instance.new("Frame", switch)
        dot.Name = "Dot"
        dot.Size = UDim2.new(0, 8, 0, 8)
        dot.Position = Config[featureKey] and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4)
        dot.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        switch.MouseButton1Click:Connect(function()
            playClickSound()
            Config[featureKey] = not Config[featureKey]
            switch.BackgroundColor3 = Config[featureKey] and Config.ThemeColor or Color3.fromRGB(45, 48, 60)
            dot.Position = Config[featureKey] and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4)
            if callback then callback(Config[featureKey]) end
        end)

        local gear = Instance.new("TextButton", toggleFrame)
        gear.Size = UDim2.new(0, 24, 0, 24)
        gear.Position = UDim2.new(0.95, -24, 0.5, -12)
        gear.BackgroundTransparency = 1
        gear.Font = Enum.Font.GothamBold
        gear.TextSize = 10
        gear.TextColor3 = Color3.fromRGB(120, 125, 140)

        local function updateGearText()
            local currentKey = ConfigKeyToBindName[featureKey]
            gear.Text = currentKey and ("⚙ [" .. currentKey .. "]") or "⚙"
            gear.TextColor3 = currentKey and Config.ThemeAccent or Color3.fromRGB(120, 125, 140)
        end
        updateGearText()

        gear.MouseButton1Click:Connect(function()
            playClickSound()
            openBindModal(featureKey, featureKey, "toggle", callback)
        end)

        table.insert(UI.Elements, {instance = gear, key = featureKey, updateFunc = updateGearText})
    end

    function UI.createNumberInput(parent, featureKey, minVal, maxVal, callback)
        minVal = minVal or 0
        maxVal = maxVal or 100000

        local inputFrame = Instance.new("Frame", parent)
        inputFrame.Size = UDim2.new(0.98, 0, 0, 32)
        inputFrame.BackgroundColor3 = Config.PanelColor
        Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 4)
        Instance.new("UIStroke", inputFrame).Color = Config.BorderColor

        local label = Instance.new("TextLabel", inputFrame)
        label.Size = UDim2.new(0.65, 0, 1, 0)
        label.Position = UDim2.new(0.03, 0, 0, 0)
        label.TextColor3 = Color3.fromRGB(210, 215, 225)
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1

        local textBox
        local function updateLabel()
            label.Text = langStr(featureKey)
            if textBox and not textBox:IsFocused() then
                textBox.Text = tostring(Config[featureKey])
            end
        end
        label.Text = langStr(featureKey)
        table.insert(UI.Elements, {instance = label, key = featureKey, updateFunc = updateLabel})

        textBox = Instance.new("TextBox", inputFrame)
        textBox.Size = UDim2.new(0, 80, 0, 20)
        textBox.Position = UDim2.new(0.95, -110, 0.5, -10)
        textBox.BackgroundColor3 = Config.BGColor
        textBox.Text = tostring(Config[featureKey])
        textBox.TextColor3 = Config.ThemeAccent
        textBox.Font = Enum.Font.Code
        textBox.TextSize = 10
        Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 3)
        Instance.new("UIStroke", textBox).Color = Config.BorderColor

        textBox.FocusLost:Connect(function()
            local num = tonumber(textBox.Text)
            if num then
                num = math.clamp(num, minVal, maxVal)
                Config[featureKey] = num
                textBox.Text = tostring(num)
                if callback then callback(num) end
            else
                textBox.Text = tostring(Config[featureKey])
            end
        end)

        local gear = Instance.new("TextButton", inputFrame)
        gear.Size = UDim2.new(0, 24, 0, 24)
        gear.Position = UDim2.new(0.95, -24, 0.5, -12)
        gear.BackgroundTransparency = 1
        gear.Font = Enum.Font.GothamBold
        gear.TextSize = 10
        gear.TextColor3 = Color3.fromRGB(120, 125, 140)

        local function updateGearText()
            local currentKey = ConfigKeyToBindName[featureKey]
            gear.Text = currentKey and ("⚙ [" .. currentKey .. "]") or "⚙"
            gear.TextColor3 = currentKey and Config.ThemeAccent or Color3.fromRGB(120, 125, 140)
        end
        updateGearText()

        gear.MouseButton1Click:Connect(function()
            playClickSound()
            openBindModal(featureKey, featureKey, "button", function()
                Config[featureKey] = Config[featureKey] + 10
                textBox.Text = tostring(Config[featureKey])
                if callback then callback(Config[featureKey]) end
            end)
        end)

        table.insert(UI.Elements, {instance = gear, key = featureKey, updateFunc = updateGearText})
    end

    function UI.createDropdown(parent, featureKey, options, callback)
        local dropFrame = Instance.new("Frame", parent)
        dropFrame.Size = UDim2.new(0.98, 0, 0, 32)
        dropFrame.BackgroundColor3 = Config.PanelColor
        Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0, 4)
        Instance.new("UIStroke", dropFrame).Color = Config.BorderColor

        local label = Instance.new("TextLabel", dropFrame)
        label.Size = UDim2.new(0.5, 0, 1, 0)
        label.Position = UDim2.new(0.03, 0, 0, 0)
        label.TextColor3 = Color3.fromRGB(210, 215, 225)
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1
        UI.registerText(label, featureKey)

        local button = Instance.new("TextButton", dropFrame)
        button.Size = UDim2.new(0, 125, 0, 18)
        button.Position = UDim2.new(0.97, -125, 0.5, -9)
        button.BackgroundColor3 = Config.BGColor
        button.Text = tostring(Config[featureKey])
        button.TextColor3 = Color3.fromRGB(220, 225, 235)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 9
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 3)
        Instance.new("UIStroke", button).Color = Config.BorderColor

        local listActive = false
        local container = Instance.new("Frame", gui)
        container.Size = UDim2.new(0, 125, 0, #options * 18)
        container.BackgroundColor3 = Config.BGColor
        container.BorderSizePixel = 0
        container.Visible = false
        container.ZIndex = 120
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 3)
        Instance.new("UIStroke", container).Color = Config.ThemeColor

        Instance.new("UIListLayout", container)

        local function closeList()
            container.Visible = false
            listActive = false
        end
        OpenDropdowns[container] = closeList

        dropFrame.AncestryChanged:Connect(function(_, newParent)
            if not newParent then
                OpenDropdowns[container] = nil
                pcall(function() container:Destroy() end)
            end
        end)

        for _, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton", container)
            optBtn.Size = UDim2.new(1, 0, 0, 18)
            optBtn.BackgroundTransparency = 1
            optBtn.Text = tostring(opt)
            optBtn.TextColor3 = Color3.fromRGB(160, 165, 180)
            optBtn.Font = Enum.Font.GothamMedium
            optBtn.TextSize = 9
            optBtn.ZIndex = 121

            optBtn.MouseEnter:Connect(function()
                optBtn.TextColor3 = Config.ThemeAccent
            end)
            optBtn.MouseLeave:Connect(function()
                optBtn.TextColor3 = Color3.fromRGB(160, 165, 180)
            end)

            optBtn.MouseButton1Click:Connect(function()
                playClickSound()
                Config[featureKey] = opt
                button.Text = tostring(opt)
                closeList()
                if callback then callback(opt) end
            end)
        end

        button.MouseButton1Click:Connect(function()
            playClickSound()
            listActive = not listActive
            if listActive then
                closeAllDropdowns(container)
                container.Position = UDim2.new(0, button.AbsolutePosition.X, 0, button.AbsolutePosition.Y + button.AbsoluteSize.Y)
                container.Visible = true
            else
                closeList()
            end
        end)
    end

    function UI.createTextBox(parent, textKey, placeholderKey, callback)
        local boxFrame = Instance.new("Frame", parent)
        boxFrame.Size = UDim2.new(0.98, 0, 0, 32)
        boxFrame.BackgroundColor3 = Config.PanelColor
        Instance.new("UICorner", boxFrame).CornerRadius = UDim.new(0, 4)
        Instance.new("UIStroke", boxFrame).Color = Config.BorderColor

        local label = Instance.new("TextLabel", boxFrame)
        label.Size = UDim2.new(0.4, 0, 1, 0)
        label.Position = UDim2.new(0.03, 0, 0, 0)
        label.TextColor3 = Color3.fromRGB(210, 215, 225)
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1
        UI.registerText(label, textKey)

        local textBox = Instance.new("TextBox", boxFrame)
        textBox.Size = UDim2.new(0, 120, 0, 18)
        textBox.Position = UDim2.new(0.97, -120, 0.5, -9)
        textBox.BackgroundColor3 = Config.BGColor
        textBox.Text = ""
        textBox.TextColor3 = Color3.fromRGB(230, 235, 245)
        textBox.Font = Enum.Font.GothamBold
        textBox.TextSize = 9
        Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 3)
        Instance.new("UIStroke", textBox).Color = Config.BorderColor

        local function updatePlaceholder()
            textBox.PlaceholderText = langStr(placeholderKey)
        end
        updatePlaceholder()
        table.insert(UI.Elements, {instance = textBox, key = placeholderKey, updateFunc = updatePlaceholder})

        textBox.FocusLost:Connect(function()
            if callback then callback(textBox.Text) end
        end)
    end

    function UI.createButton(parent, textKey, callback)
        local btnFrame = Instance.new("Frame", parent)
        btnFrame.Size = UDim2.new(0.98, 0, 0, 32)
        btnFrame.BackgroundTransparency = 1

        local btn = Instance.new("TextButton", btnFrame)
        btn.Size = UDim2.new(0.85, 0, 1, 0)
        btn.BackgroundColor3 = Config.PanelColor
        btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = Color3.fromRGB(220, 225, 235)
        btn.TextSize = 10
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = Config.BorderColor

        UI.registerText(btn, textKey)

        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(45, 48, 62)
            btnStroke.Color = Config.ThemeColor
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Config.PanelColor
            btnStroke.Color = Config.BorderColor
        end)

        btn.MouseButton1Click:Connect(function()
            playClickSound()
            if callback then callback() end
        end)

        local gear = Instance.new("TextButton", btnFrame)
        gear.Size = UDim2.new(0, 24, 0, 24)
        gear.Position = UDim2.new(0.95, -24, 0.5, -12)
        gear.BackgroundTransparency = 1
        gear.Font = Enum.Font.GothamBold
        gear.TextSize = 10
        gear.TextColor3 = Color3.fromRGB(120, 125, 140)

        local function updateGearText()
            local currentKey = ConfigKeyToBindName[textKey]
            gear.Text = currentKey and ("⚙ [" .. currentKey .. "]") or "⚙"
            gear.TextColor3 = currentKey and Config.ThemeAccent or Color3.fromRGB(120, 125, 140)
        end
        updateGearText()

        gear.MouseButton1Click:Connect(function()
            playClickSound()
            openBindModal(textKey, textKey, "button", callback)
        end)

        table.insert(UI.Elements, {instance = gear, key = textKey, updateFunc = updateGearText})
    end

    speedTab = UI.createTab("Movement", "TabMovement")
    aimTab = UI.createTab("Combat", "TabCombat")
    vehicleTab = UI.createTab("Vehicle", "TabVehicle")
    espTab = UI.createTab("Visuals", "TabVisuals")
    teleportTab = UI.createTab("Teleport", "TabTeleport")

end

-----------------------------------------------------------
-- MOVEMENT СЕКЦИЯ (SPEEDHACK БЕЗ T-POSE + PERSISTENT NOCLIP)
-----------------------------------------------------------
local restoreOriginalCollisions
do
    local OriginalCollideCache = {}

    restoreOriginalCollisions = function()
        local char = getCharacter(LocalPlayer)
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if OriginalCollideCache[part] ~= nil then
                        part.CanCollide = OriginalCollideCache[part]
                    elseif part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso" or part.Name == "LowerTorso" then
                        part.CanCollide = true
                    end
                end
            end
        end
        table.clear(OriginalCollideCache)
    end

    local function ensureNaturalRunAnimation(char, hum)
        if not char or not hum then return end
        if hum.PlatformStand then
            hum.PlatformStand = false
        end
        local animateScript = char:FindFirstChild("Animate")
        if animateScript and animateScript:IsA("LocalScript") and not animateScript.Enabled then
            animateScript.Enabled = true
        end
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            local hasRunTrack = false
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local tName = track.Name:lower()
                local aName = (track.Animation and track.Animation.Name or ""):lower()
                if tName:find("run") or tName:find("walk") or aName:find("run") or aName:find("walk") then
                    hasRunTrack = true
                    break
                end
            end
            if not hasRunTrack and hum.FloorMaterial ~= Enum.Material.Air then
                pcall(function()
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end)
            end
        end
    end

    UI.createToggle(speedTab, "SpeedOn")
    UI.createDropdown(speedTab, "SpeedMethod", {"Natural Velocity", "CFrame Hybrid"})
    UI.createNumberInput(speedTab, "SpeedPower", 1, 100000)
    UI.createToggle(speedTab, "AdaptiveSpeed")
    UI.createToggle(speedTab, "FlyOn")
    UI.createNumberInput(speedTab, "FlySpeed", 1, 100000)
    UI.createToggle(speedTab, "NoClipOn", function(state)
        if not state then
            restoreOriginalCollisions()
        end
    end)
    UI.createToggle(speedTab, "SmartNoClip")
    UI.createToggle(speedTab, "InfJumpOn")
    UI.createToggle(speedTab, "JumpOn")
    UI.createNumberInput(speedTab, "JumpPower", 1, 100000)
    UI.createToggle(speedTab, "AntiRagdoll")
    UI.createToggle(speedTab, "AntiSlip")

    table.insert(connections, RunService.Heartbeat:Connect(function(dt)
        if not running then return end
        local char = getCharacter(LocalPlayer)
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end

        dt = math.clamp(dt, 0.001, 0.1)

        if Config.FlyOn then
            local camera = Workspace.CurrentCamera
            local moveDir = Vector3.new(0, 0, 0)

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit
            end

            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

            local nextPos = root.Position + (moveDir * Config.FlySpeed * dt)
            local lookAt = nextPos + camera.CFrame.LookVector
            root.CFrame = CFrame.new(nextPos, Vector3.new(lookAt.X, nextPos.Y, lookAt.Z))
            return
        end

        local isClimbing = (hum:GetState() == Enum.HumanoidStateType.Climbing)
        if Config.SpeedOn then
            if isClimbing then
                local climbSpeed = math.clamp(Config.SpeedPower * 0.45, 20, 120)
                local yVel = 0
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    yVel = climbSpeed
                elseif UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    yVel = -climbSpeed
                end
                if yVel ~= 0 then
                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, yVel, root.AssemblyLinearVelocity.Z)
                end
            else
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0.05 then
                    local flatDir = Vector3.new(moveDir.X, 0, moveDir.Z).Unit
                    local targetSpeed = Config.SpeedPower
                    local slideDir = flatDir

                    if Config.AdaptiveSpeed and not Config.NoClipOn then
                        local rayParams = RaycastParams.new()
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude
                        rayParams.FilterDescendantsInstances = {char}
                        rayParams.IgnoreWater = true

                        local chestOrigin = root.Position + Vector3.new(0, 0.5, 0)
                        local checkDist = math.clamp(targetSpeed * dt + 2.2, 2.5, 6.0)
                        local hit = Workspace:Raycast(chestOrigin, flatDir * checkDist, rayParams)

                        if hit and hit.Instance and hit.Instance.CanCollide then
                            local normal = hit.Normal
                            if math.abs(normal.Y) < 0.65 then
                                local headOrigin = root.Position + Vector3.new(0, 2.4, 0)
                                local upperHit = Workspace:Raycast(headOrigin, flatDir * checkDist, rayParams)
                                if not upperHit then
                                    root.CFrame = root.CFrame + Vector3.new(0, 0.35, 0)
                                else
                                    local tangent = flatDir - (flatDir:Dot(normal) * normal)
                                    if tangent.Magnitude > 0.1 then
                                        slideDir = tangent.Unit
                                        targetSpeed = math.min(targetSpeed, 28)
                                    else
                                        targetSpeed = 16
                                    end
                                end
                            end
                        end
                    end

                    ensureNaturalRunAnimation(char, hum)

                    if Config.SpeedMethod == "Natural Velocity" then
                        local curVel = root.AssemblyLinearVelocity
                        root.AssemblyLinearVelocity = Vector3.new(slideDir.X * targetSpeed, curVel.Y, slideDir.Z * targetSpeed)
                    else
                        local baseWalk = math.min(targetSpeed, hum.WalkSpeed)
                        local curVel = root.AssemblyLinearVelocity
                        root.AssemblyLinearVelocity = Vector3.new(slideDir.X * baseWalk, curVel.Y, slideDir.Z * baseWalk)
                        local extraSpeed = math.max(0, targetSpeed - baseWalk)
                        if extraSpeed > 0 then
                            root.CFrame = root.CFrame + (slideDir * extraSpeed * dt)
                        end
                    end
                else
                    if Config.AntiSlip then
                        root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
                    end
                end
            end
        end
    end))

    local function applyPersistentNoClip()
        if not running or not Config.NoClipOn then return end
        local char = getCharacter(LocalPlayer)
        if not char then return end

        local root = char:FindFirstChild("HumanoidRootPart")
        local keepFloorSolid = false

        if Config.SmartNoClip and not Config.FlyOn and root and not UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = {char}
            rayParams.IgnoreWater = true

            local floorHit = Workspace:Raycast(root.Position, Vector3.new(0, -4.2, 0), rayParams)
            if floorHit and floorHit.Instance and floorHit.Instance.CanCollide and floorHit.Normal.Y > 0.65 then
                keepFloorSolid = true
            end
        end

        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if OriginalCollideCache[part] == nil then
                    OriginalCollideCache[part] = part.CanCollide
                end

                if keepFloorSolid and (part.Name == "LeftFoot" or part.Name == "RightFoot" or part.Name == "Left Leg" or part.Name == "Right Leg") then
                    part.CanCollide = true
                else
                    if part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
    end

    table.insert(connections, RunService.Stepped:Connect(applyPersistentNoClip))
    table.insert(connections, RunService.PreSimulation:Connect(applyPersistentNoClip))

    table.insert(connections, UserInputService.JumpRequest:Connect(function()
        if not running then return end
        pcall(function()
            local char = getCharacter(LocalPlayer)
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if hum then
                if Config.InfJumpOn then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
                if Config.JumpOn and root and (hum:GetState() == Enum.HumanoidStateType.Running or hum:GetState() == Enum.HumanoidStateType.Jumping) then
                    task.wait(0.015)
                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, Config.JumpPower, root.AssemblyLinearVelocity.Z)
                end
            end
        end)
    end))

end

-- Combat Секция
UI.createToggle(aimTab, "AutoClickerOn")
UI.createNumberInput(aimTab, "AutoClickerCPS", 1, 100)
UI.createDropdown(aimTab, "AutoClickerButton", {"LMB", "RMB"})

UI.createToggle(aimTab, "AimbotOn")
UI.createDropdown(aimTab, "AimbotPart", {"Head", "HumanoidRootPart", "Torso"})
UI.createDropdown(aimTab, "AimbotMethod", {"Camera CFrame", "Mouse Emulation"})
UI.createDropdown(aimTab, "AimbotBind", {"MouseButton2", "MouseButton1", "E", "Q"})
UI.createNumberInput(aimTab, "AimbotFOV", 1, 100000)
UI.createNumberInput(aimTab, "AimbotSmoothness", 0, 2000)
UI.createToggle(aimTab, "AimbotJitter")
UI.createToggle(aimTab, "AimbotTeamCheck")
UI.createToggle(aimTab, "AimbotWallCheck")
UI.createToggle(aimTab, "AimbotPrediction")
UI.createNumberInput(aimTab, "AimbotPredictionPower", 1, 2000)
UI.createToggle(aimTab, "Triggerbot")

-----------------------------------------------------------
-- VEHICLE СЕКЦИЯ (ПОЛНОСТЬЮ ПЕРЕРАБОТАНА БЕЗ БАГОВ ПОДВЕСКИ)
-----------------------------------------------------------
local OriginalSeatStats = {}
do

    local lastVehicleFlipTick = 0

    UI.createToggle(vehicleTab, "VehicleSpeedOn", function(state)
        if not state then
            for seat, orig in pairs(OriginalSeatStats) do
                if seat and seat.Parent and seat:IsA("VehicleSeat") then
                    pcall(function()
                        seat.MaxSpeed = orig.MaxSpeed
                        seat.Torque = orig.Torque
                    end)
                end
            end
            table.clear(OriginalSeatStats)
        end
    end)
    UI.createDropdown(vehicleTab, "VehicleSpeedMethod", {"Suspension Safe", "Seat Tune + Boost"})
    UI.createNumberInput(vehicleTab, "VehicleSpeed", 1, 2000)
    UI.createToggle(vehicleTab, "VehicleJumpOn")
    UI.createNumberInput(vehicleTab, "VehicleJumpPower", 1, 1000)
    UI.createToggle(vehicleTab, "VehicleFlyOn")
    UI.createNumberInput(vehicleTab, "VehicleFlySpeed", 1, 2000)
    UI.createToggle(vehicleTab, "VehicleNoFlip")
    UI.createToggle(vehicleTab, "VehicleInstantBrake")

    table.insert(connections, RunService.Heartbeat:Connect(function(dt)
        if not running then return end
        if not Config.VehicleFlyOn and not Config.VehicleSpeedOn and not Config.VehicleNoFlip and not Config.VehicleInstantBrake then
            return
        end

        dt = math.clamp(dt, 0.001, 0.1)

        pcall(function()
            local seat, rootPart, vehicleModel = getVehicleData()
            if not seat or not rootPart then return end

            if Config.VehicleFlyOn then
                local camera = Workspace.CurrentCamera
                local moveDir = Vector3.new(0, 0, 0)

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

                if moveDir.Magnitude > 0 then
                    moveDir = moveDir.Unit
                end

                rootPart.AssemblyLinearVelocity = (moveDir * Config.VehicleFlySpeed) + Vector3.new(0, Workspace.Gravity * dt * 0.5, 0)
                rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                return
            end

            if Config.VehicleInstantBrake and UserInputService:IsKeyDown(Enum.KeyCode.B) then
                local curVel = rootPart.AssemblyLinearVelocity
                rootPart.AssemblyLinearVelocity = Vector3.new(curVel.X * 0.72, curVel.Y, curVel.Z * 0.72)
                rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                return
            end

            if Config.VehicleSpeedOn then
                if Config.VehicleSpeedMethod == "Seat Tune + Boost" and seat:IsA("VehicleSeat") then
                    if not OriginalSeatStats[seat] then
                        OriginalSeatStats[seat] = {MaxSpeed = seat.MaxSpeed, Torque = seat.Torque}
                    end
                    seat.MaxSpeed = math.max(OriginalSeatStats[seat].MaxSpeed, Config.VehicleSpeed * 6, 600)
                    seat.Torque = math.max(OriginalSeatStats[seat].Torque, Config.VehicleSpeed * 350)
                end

                local throttle = 0
                if seat:IsA("VehicleSeat") and seat.ThrottleFloat ~= 0 then
                    throttle = seat.ThrottleFloat
                else
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then throttle = throttle + 1 end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then throttle = throttle - 1 end
                end

                if math.abs(throttle) > 0.05 then
                    local rawLook = seat.CFrame.LookVector
                    local flatLook = Vector3.new(rawLook.X, 0, rawLook.Z)
                    if flatLook.Magnitude > 0.01 then
                        flatLook = flatLook.Unit
                        local curVel = rootPart.AssemblyLinearVelocity
                        local horizVel = Vector3.new(curVel.X, 0, curVel.Z)
                        local forwardSpeed = horizVel:Dot(flatLook)
                        local lateralVel = horizVel - (flatLook * forwardSpeed)

                        local accel = Config.VehicleSpeed * 2.2 * dt
                        local newForwardSpeed = forwardSpeed
                        if throttle > 0 then
                            newForwardSpeed = math.min(3000, forwardSpeed + (accel * throttle))
                        else
                            newForwardSpeed = math.max(-450, forwardSpeed + (accel * throttle * 1.2))
                        end

                        local finalHoriz = (flatLook * newForwardSpeed) + lateralVel
                        rootPart.AssemblyLinearVelocity = Vector3.new(finalHoriz.X, curVel.Y, finalHoriz.Z)
                    end
                end
            end

            if Config.VehicleNoFlip and (tick() - lastVehicleFlipTick) > 0.8 then
                local upDot = seat.CFrame.UpVector.Y
                if upDot < 0.25 then
                    lastVehicleFlipTick = tick()
                    local _, ry, _ = seat.CFrame:ToOrientation()
                    rootPart.AssemblyLinearVelocity = Vector3.new(0, 6, 0)
                    rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    if vehicleModel and vehicleModel.PrimaryPart then
                        local pivotPos = vehicleModel:GetPivot().Position + Vector3.new(0, 3.5, 0)
                        vehicleModel:PivotTo(CFrame.new(pivotPos) * CFrame.Angles(0, ry, 0))
                    else
                        rootPart.CFrame = CFrame.new(rootPart.Position + Vector3.new(0, 3.5, 0)) * CFrame.Angles(0, ry, 0)
                    end
                end
            end
        end)
    end))

    table.insert(connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not running then return end
        if input.KeyCode == Enum.KeyCode.Space and Config.VehicleJumpOn then
            pcall(function()
                local _, rootPart = getVehicleData()
                if rootPart then
                    local curVel = rootPart.AssemblyLinearVelocity
                    rootPart.AssemblyLinearVelocity = Vector3.new(
                        curVel.X,
                        Config.VehicleJumpPower,
                        curVel.Z
                    )
                end
            end)
        end
    end))

end

table.insert(threads, task.spawn(function()
    while running do
        if Config.AutoClickerOn then
            pcall(function()
                performMouseClick(Config.AutoClickerButton == "RMB")
                task.wait(1 / math.clamp(Config.AutoClickerCPS, 1, 100))
            end)
        else
            task.wait(0.15)
        end
    end
end))

do
    local fovCircle = Instance.new("Frame", gui)
    fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    fovCircle.BackgroundTransparency = 1
    fovCircle.ZIndex = 0
    fovCircle.Visible = false

    local fovCorner = Instance.new("UICorner", fovCircle)
    fovCorner.CornerRadius = UDim.new(1, 0)

    local fovStroke = Instance.new("UIStroke", fovCircle)
    fovStroke.Color = Config.ThemeColor
    fovStroke.Thickness = 1.0
    fovStroke.Transparency = 0.5

    local function isPartVisible(part, char)
        local camera = Workspace.CurrentCamera
        local origin = camera.CFrame.Position
        local destination = part.Position
        local direction = destination - origin

        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = {getCharacter(LocalPlayer), char}
        raycastParams.IgnoreWater = true

        local result = workspace:Raycast(origin, direction, raycastParams)
        if not result then return true end
        if result.Instance and (not result.Instance.CanCollide or result.Instance.Transparency > 0.6) then
            return true
        end
        return false
    end

    local targetLockedPlayer = nil

    local function getClosestPlayerToMouse()
        if targetLockedPlayer and targetLockedPlayer.Parent and targetLockedPlayer.Parent:FindFirstChild("Humanoid") then
            local hum = targetLockedPlayer.Parent.Humanoid
            if hum.Health > 0 then
                local camera = Workspace.CurrentCamera
                local targetPart = targetLockedPlayer.Parent:FindFirstChild(Config.AimbotPart) or targetLockedPlayer
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)

                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                    if dist <= Config.AimbotFOV then
                        if not Config.AimbotWallCheck or isPartVisible(targetPart, targetLockedPlayer.Parent) then
                            return targetPart
                        end
                    end
                end
            end
        end

        targetLockedPlayer = nil

        local closest = nil
        local maxDistance = Config.AimbotFOV
        local camera = Workspace.CurrentCamera
        local mousePos = UserInputService:GetMouseLocation()

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local char = getCharacter(p)
                if char and char:FindFirstChild("Humanoid") then
                    local hum = char.Humanoid
                    if hum.Health <= 0 then continue end
                    if Config.AimbotTeamCheck and LocalPlayer.Team ~= nil and p.Team == LocalPlayer.Team then continue end

                    local targetPart = char:FindFirstChild(Config.AimbotPart)
                    if targetPart then
                        if Config.AimbotWallCheck and not isPartVisible(targetPart, char) then continue end

                        local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if dist < maxDistance then
                                closest = targetPart
                                maxDistance = dist
                            end
                        end
                    end
                end
            end
        end

        if closest then
            targetLockedPlayer = closest
        end
        return closest
    end

    table.insert(connections, RunService.RenderStepped:Connect(function()
        if not running then return end

        if Config.AntiRagdoll then
            local char = getCharacter(LocalPlayer)
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                if hum:GetState() == Enum.HumanoidStateType.FallingDown or hum:GetState() == Enum.HumanoidStateType.Ragdoll then
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end
        end

        fovCircle.Visible = Config.ShowFOV
        if Config.ShowFOV then
            local mousePos = UserInputService:GetMouseLocation()
            local targetSize = Config.AimbotFOV * 2
            fovCircle.Size = UDim2.new(0, targetSize, 0, targetSize)
            fovCircle.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
        end

        if not Config.AimbotOn then
            targetLockedPlayer = nil
            return
        end

        local isPressed = false
        if Config.AimbotBind == "MouseButton2" then
            isPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        elseif Config.AimbotBind == "MouseButton1" then
            isPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        else
            local success, code = pcall(function() return Enum.KeyCode[Config.AimbotBind] end)
            if success and code then 
                isPressed = UserInputService:IsKeyDown(code) 
            end
        end

        if isPressed then
            local target = getClosestPlayerToMouse()
            if target then
                local camera = Workspace.CurrentCamera
                local targetPos = target.Position

                if Config.AimbotPrediction then
                    local velocity = target.AssemblyLinearVelocity
                    if velocity.Magnitude > 150 then
                        velocity = velocity.Unit * 150
                    end
                    local dist = (target.Position - camera.CFrame.Position).Magnitude
                    local travelTime = dist / 1200
                    targetPos = targetPos + (velocity * travelTime * Config.AimbotPredictionPower)
                end

                if Config.AimbotJitter then
                    local jitterFactor = 0.15
                    targetPos = targetPos + Vector3.new(
                        math.random(-100, 100)/1000 * jitterFactor,
                        math.random(-100, 100)/1000 * jitterFactor,
                        math.random(-100, 100)/1000 * jitterFactor
                    )
                end

                if Config.AimbotMethod == "Camera CFrame" then
                    local targetCFrame = CFrame.new(camera.CFrame.Position, targetPos)
                    if Config.AimbotSmoothness <= 0 then
                        camera.CFrame = targetCFrame
                    else
                        local smoothness = math.clamp(Config.AimbotSmoothness, 1, 100000)
                        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 1 / smoothness)
                    end
                elseif Config.AimbotMethod == "Mouse Emulation" and mousemoverel then
                    local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
                    if onScreen then
                        local mousePos = UserInputService:GetMouseLocation()
                        if Config.AimbotSmoothness <= 0 then
                            mousemoverel(screenPos.X - mousePos.X, screenPos.Y - mousePos.Y)
                        else
                            local deltaX = (screenPos.X - mousePos.X) / math.clamp(Config.AimbotSmoothness, 1.2, 100000)
                            local deltaY = (screenPos.Y - mousePos.Y) / math.clamp(Config.AimbotSmoothness, 1.2, 100000)
                            mousemoverel(deltaX, deltaY)
                        end
                    end
                end
            end
        else
            targetLockedPlayer = nil
        end

        if Config.Triggerbot then
            local mouse = LocalPlayer:GetMouse()
            local target = mouse.Target
            if target and target.Parent and target.Parent:FindFirstChildOfClass("Humanoid") then
                local targetPlayer = Players:GetPlayerFromCharacter(target.Parent)
                if targetPlayer and targetPlayer ~= LocalPlayer then
                    if not (Config.AimbotTeamCheck and LocalPlayer.Team ~= nil and targetPlayer.Team == LocalPlayer.Team) then
                        performMouseClick(false)
                    end
                end
            end
        end
    end))

end

-----------------------------------------------------------
-- VISUALS СЕКЦИЯ (ОПТИМИЗИРОВАННЫЙ ESP ИГРОКОВ + FULLBRIGHT)
-----------------------------------------------------------
local OriginalLighting, PlayerESPRegistry, destroyPlayerESP
do
    OriginalLighting = {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        GlobalShadows = Lighting.GlobalShadows,
        Ambient = Lighting.Ambient
    }

    UI.createToggle(espTab, "ESPOn")
    UI.createToggle(espTab, "ESPTagsOn")
    UI.createToggle(espTab, "ESPShowHP")
    UI.createToggle(espTab, "ESPBoxesOn")
    UI.createToggle(espTab, "ESPTracers")
    UI.createToggle(espTab, "ShowFOV")
    UI.createToggle(espTab, "ESPTeamCheck")
    UI.createNumberInput(espTab, "ESPDistanceLimit", 1, 100000)
    UI.createToggle(espTab, "Fullbright", function(state)
        if not state then
            pcall(function()
                Lighting.Brightness = OriginalLighting.Brightness
                Lighting.ClockTime = OriginalLighting.ClockTime
                Lighting.FogEnd = OriginalLighting.FogEnd
                Lighting.GlobalShadows = OriginalLighting.GlobalShadows
                Lighting.Ambient = OriginalLighting.Ambient
            end)
        end
    end)

    PlayerESPRegistry = {}

    destroyPlayerESP = function(player)
        local entry = PlayerESPRegistry[player]
        if entry then
            pcall(function()
                if entry.hl then entry.hl:Destroy() end
                if entry.bb then entry.bb:Destroy() end
                if entry.box then entry.box:Destroy() end
                if entry.line then entry.line:Destroy() end
            end)
            PlayerESPRegistry[player] = nil
        end
    end

    local function ensurePlayerESP(player, char)
        if player == LocalPlayer or not char or not char.Parent then return nil end
        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head") or root
        if not root or not head then return nil end

        local existing = PlayerESPRegistry[player]
        if existing and existing.char == char and existing.hl and existing.hl.Parent then
            existing.root = root
            existing.head = head
            existing.hum = char:FindFirstChildOfClass("Humanoid")
            return existing
        end

        destroyPlayerESP(player)

        local hl = Instance.new("Highlight")
        hl.Name = "PlayerESP_HL"
        hl.Adornee = char
        hl.FillColor = Config.ThemeColor
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0.1
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Enabled = false
        hl.Parent = EspContainer

        local bb = Instance.new("BillboardGui")
        bb.Name = "PlayerESP_Tag"
        bb.Adornee = head
        bb.Size = UDim2.new(0, 180, 0, 38)
        bb.StudsOffset = Vector3.new(0, 2.8, 0)
        bb.AlwaysOnTop = true
        bb.MaxDistance = 100000
        bb.Enabled = false
        bb.Parent = EspContainer

        local label = Instance.new("TextLabel", bb)
        label.Name = "Label"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 10
        label.TextStrokeTransparency = 0.15
        label.TextStrokeColor3 = Color3.fromRGB(12, 12, 16)
        label.RichText = true

        local box = Instance.new("SelectionBox")
        box.Name = "PlayerESP_Box"
        box.Adornee = char
        box.Color3 = Config.ThemeColor
        box.LineThickness = 0.04
        box.SurfaceTransparency = 0.88
        box.SurfaceColor3 = Config.ThemeColor
        box.Visible = false
        box.Parent = EspContainer

        local line = Instance.new("LineHandleAdornment")
        line.Name = "PlayerESP_Line"
        line.Adornee = Workspace.Terrain
        line.Color3 = Config.ThemeColor
        line.Thickness = 1.2
        line.AlwaysOnTop = true
        line.Visible = false
        line.Parent = EspContainer

        local entry = {
            player = player,
            char = char,
            root = root,
            head = head,
            hum = char:FindFirstChildOfClass("Humanoid"),
            hl = hl,
            bb = bb,
            label = label,
            box = box,
            line = line,
            lastText = ""
        }
        PlayerESPRegistry[player] = entry
        return entry
    end

    local function bindPlayerESPListeners(player)
        if player == LocalPlayer then return end
        local char = getCharacter(player)
        if char then
            ensurePlayerESP(player, char)
        end
        table.insert(connections, player.CharacterAdded:Connect(function(newChar)
            task.spawn(function()
                newChar:WaitForChild("HumanoidRootPart", 10)
                if running and player.Parent then
                    ensurePlayerESP(player, newChar)
                end
            end)
        end))
        table.insert(connections, player.CharacterRemoving:Connect(function()
            destroyPlayerESP(player)
        end))
    end

    for _, p in ipairs(Players:GetPlayers()) do
        bindPlayerESPListeners(p)
    end
    table.insert(connections, Players.PlayerAdded:Connect(bindPlayerESPListeners))
    table.insert(connections, Players.PlayerRemoving:Connect(destroyPlayerESP))

    table.insert(threads, task.spawn(function()
        while running do
            task.wait(0.12)
            if Config.Fullbright then
                pcall(function()
                    Lighting.Brightness = 2
                    Lighting.ClockTime = 14
                    Lighting.FogEnd = 100000
                    Lighting.GlobalShadows = false
                    Lighting.Ambient = Color3.fromRGB(190, 195, 210)
                end)
            end

            local anyESPEnabled = Config.ESPOn or Config.ESPTagsOn or Config.ESPBoxesOn or Config.ESPTracers
            local myChar = getCharacter(LocalPlayer)
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local char = getCharacter(player)
                    if not char or not char.Parent then
                        if PlayerESPRegistry[player] then
                            destroyPlayerESP(player)
                        end
                    else
                        local entry = PlayerESPRegistry[player]
                        if not entry or entry.char ~= char or not entry.hl or not entry.hl.Parent then
                            entry = ensurePlayerESP(player, char)
                        end

                        if entry then
                            if not anyESPEnabled or not myRoot or not entry.root or not entry.root.Parent then
                                entry.hl.Enabled = false
                                entry.bb.Enabled = false
                                entry.box.Visible = false
                                entry.line.Visible = false
                            else
                                local dist = (entry.root.Position - myRoot.Position).Magnitude
                                local isTeam = (LocalPlayer.Team ~= nil and player.Team == LocalPlayer.Team)
                                local skip = (Config.ESPTeamCheck and isTeam) or (dist > Config.ESPDistanceLimit)

                                if skip then
                                    entry.hl.Enabled = false
                                    entry.bb.Enabled = false
                                    entry.box.Visible = false
                                    entry.line.Visible = false
                                else
                                    local espColor = isTeam and Color3.fromRGB(90, 235, 130) or Config.ThemeColor
                                    entry.hl.Enabled = Config.ESPOn
                                    if entry.hl.FillColor ~= espColor then
                                        entry.hl.FillColor = espColor
                                    end

                                    entry.box.Visible = Config.ESPBoxesOn
                                    if Config.ESPBoxesOn and entry.box.Color3 ~= espColor then
                                        entry.box.Color3 = espColor
                                        entry.box.SurfaceColor3 = espColor
                                    end

                                    entry.bb.Enabled = Config.ESPTagsOn
                                    if Config.ESPTagsOn then
                                        local hpText = ""
                                        local hum = entry.hum or char:FindFirstChildOfClass("Humanoid")
                                        if Config.ESPShowHP and hum and hum.MaxHealth > 0 then
                                            entry.hum = hum
                                            local hp = math.max(0, math.floor(hum.Health))
                                            local hpRatio = math.clamp(hp / hum.MaxHealth, 0, 1)
                                            local hpHex = hpRatio > 0.6 and "#4ADE80" or (hpRatio > 0.3 and "#FBBF24" or "#F87171")
                                            hpText = string.format(" <font color='%s'>[%d HP]</font>", hpHex, hp)
                                        end
                                        local nameHex = isTeam and "#86EFAC" or "#FCA5A5"
                                        local newText = string.format("<font color='%s'>%s</font> [%dm]%s", nameHex, player.DisplayName, math.floor(dist), hpText)
                                        if entry.lastText ~= newText then
                                            entry.lastText = newText
                                            entry.label.Text = newText
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end))

    table.insert(connections, RunService.RenderStepped:Connect(function()
        if not running or not Config.ESPTracers then return end
        local myChar = getCharacter(LocalPlayer)
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        for _, entry in pairs(PlayerESPRegistry) do
            if entry.root and entry.root.Parent then
                local dist = (entry.root.Position - myRoot.Position).Magnitude
                local isTeam = (LocalPlayer.Team ~= nil and entry.player.Team == LocalPlayer.Team)
                local skip = (Config.ESPTeamCheck and isTeam) or (dist > Config.ESPDistanceLimit)
                if not skip then
                    entry.line.Visible = true
                    entry.line.Length = dist
                    entry.line.CFrame = CFrame.new(myRoot.Position - Vector3.new(0, 2.5, 0), entry.root.Position)
                else
                    entry.line.Visible = false
                end
            end
        end
    end))

end

-- Teleport Секция
UI.createToggle(teleportTab, "TweenTP")
UI.createNumberInput(teleportTab, "TweenTPSpeed", 1, 100000)
UI.createToggle(teleportTab, "ClickTP")

local secureMove
do
    local coordDisplay = Instance.new("Frame", teleportTab)
    coordDisplay.Size = UDim2.new(0.98, 0, 0, 40)
    coordDisplay.BackgroundColor3 = Config.PanelColor
    Instance.new("UICorner", coordDisplay).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", coordDisplay).Color = Config.BorderColor

    local coordLabel = Instance.new("TextLabel", coordDisplay)
    coordLabel.Size = UDim2.new(1, 0, 1, 0)
    coordLabel.BackgroundTransparency = 1
    coordLabel.TextColor3 = Color3.fromRGB(160, 165, 180)
    coordLabel.Font = Enum.Font.GothamMedium
    coordLabel.TextSize = 9

    local function updateCoordLabel()
        if savedCoords then
            coordLabel.Text = langStr("SavedLocLabel") .. string.format("\nX: %.1f, Y: %.1f, Z: %.1f", savedCoords.X, savedCoords.Y, savedCoords.Z)
            coordLabel.TextColor3 = Config.ThemeAccent
        else
            coordLabel.Text = langStr("SavedLocLabel") .. langStr("None")
            coordLabel.TextColor3 = Color3.fromRGB(160, 165, 180)
        end
    end
    updateCoordLabel()
    table.insert(UI.Elements, {instance = coordLabel, key = "SavedLocLabel", updateFunc = updateCoordLabel})

    secureMove = function(pos)
        local root = getCharacter(LocalPlayer) and getCharacter(LocalPlayer):FindFirstChild("HumanoidRootPart")
        if root then
            if Config.TweenTP then
                local dist = (root.Position - pos).Magnitude
                local speed = Config.TweenTPSpeed or 100
                local time = dist / speed
                local tween = TweenService:Create(root, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
                tween:Play()
                tween.Completed:Wait()
            else
                root.CFrame = CFrame.new(pos)
            end
        end
    end

    UI.createTextBox(teleportTab, "CoordsInput", "CoordsPlaceholder", function(text)
        local parsed = {}
        for num in string.gmatch(text:gsub(",", " "), "%S+") do
            table.insert(parsed, tonumber(num))
        end
        if #parsed >= 3 then
            targetCoords.x = parsed[1]
            targetCoords.y = parsed[2]
            targetCoords.z = parsed[3]
        end
    end)

    UI.createButton(teleportTab, "WarpCoordsBtn", function()
        secureMove(Vector3.new(targetCoords.x, targetCoords.y, targetCoords.z))
    end)

    UI.createButton(teleportTab, "SaveCoordsBtn", function()
        local root = getCharacter(LocalPlayer) and getCharacter(LocalPlayer):FindFirstChild("HumanoidRootPart")
        if root then
            savedCoords = root.Position
            updateCoordLabel()
        end
    end)

    UI.createButton(teleportTab, "WarpSavedBtn", function()
        if savedCoords then
            secureMove(savedCoords)
        end
    end)

    UI.createButton(teleportTab, "WarpRandomBtn", function()
        local playersList = Players:GetPlayers()
        local targets = {}
        for _, p in ipairs(playersList) do
            local char = getCharacter(p)
            if p ~= LocalPlayer and char and char:FindFirstChild("HumanoidRootPart") then
                table.insert(targets, char.HumanoidRootPart)
            end
        end
        if #targets > 0 then
            local chosen = targets[math.random(1, #targets)]
            secureMove(chosen.Position + Vector3.new(0, 3, 0))
        end
    end)

    UI.createButton(teleportTab, "WarpClosestBtn", function()
        local myRoot = getCharacter(LocalPlayer) and getCharacter(LocalPlayer):FindFirstChild("HumanoidRootPart")
        if myRoot then
            local closest = nil
            local minDist = math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                local char = getCharacter(p)
                if p ~= LocalPlayer and char and char:FindFirstChild("HumanoidRootPart") then
                    local dist = (myRoot.Position - char.HumanoidRootPart.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = char.HumanoidRootPart
                    end
                end
            end
            if closest then
                secureMove(closest.Position + Vector3.new(0, 3, 0))
            end
        end
    end)

    UI.createButton(teleportTab, "RejoinBtn", function()
        RejoinCurrentServer()
    end)

    UI.createButton(teleportTab, "HopEmptyServerBtn", function()
        JoinLowestPlayerServer()
    end)

    table.insert(connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and Config.ClickTP and input.UserInputType == Enum.UserInputType.MouseButton1 then
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                local mouse = LocalPlayer:GetMouse()
                if mouse and mouse.Hit then
                    secureMove(mouse.Hit.Position + Vector3.new(0, 3, 0))
                end
            end
        end
    end))

end

local currentDynamicTabFrame = nil

-- Универсальный мини-оверлей HUD для игровых режимов
local modeHUD, showModeHUD, getTargetPart
local lastHUDTitle, lastHUDBody = "", ""
do
    modeHUD = Instance.new("Frame", gui)
    modeHUD.Name = "KrestikModeHUD"
    modeHUD.Size = UDim2.new(0, 325, 0, 225)
    modeHUD.Position = UDim2.new(1, -340, 0, 50)
    modeHUD.BackgroundColor3 = Config.BGColor
    modeHUD.BorderSizePixel = 0
    modeHUD.Visible = false
    modeHUD.ZIndex = 50
    Instance.new("UICorner", modeHUD).CornerRadius = UDim.new(0, 6)
    local modeHUDStroke = Instance.new("UIStroke", modeHUD)
    modeHUDStroke.Color = Config.ThemeColor
    modeHUDStroke.Thickness = 1.0

    local modeHUDTop = Instance.new("Frame", modeHUD)
    modeHUDTop.Size = UDim2.new(1, 0, 0, 26)
    modeHUDTop.BackgroundColor3 = Color3.fromRGB(18, 19, 24)
    modeHUDTop.BorderSizePixel = 0
    modeHUDTop.ZIndex = 51
    Instance.new("UICorner", modeHUDTop).CornerRadius = UDim.new(0, 6)
    UI.makeDraggable(modeHUDTop, modeHUD)

    local modeHUDTitle = Instance.new("TextLabel", modeHUDTop)
    modeHUDTitle.Size = UDim2.new(0.85, 0, 1, 0)
    modeHUDTitle.Position = UDim2.new(0.04, 0, 0, 0)
    modeHUDTitle.BackgroundTransparency = 1
    modeHUDTitle.Text = "GAME HELPER HUD"
    modeHUDTitle.TextColor3 = Config.ThemeAccent
    modeHUDTitle.Font = Enum.Font.GothamBold
    modeHUDTitle.TextSize = 10
    modeHUDTitle.TextXAlignment = Enum.TextXAlignment.Left
    modeHUDTitle.ZIndex = 52

    local modeHUDClose = Instance.new("TextButton", modeHUDTop)
    modeHUDClose.Size = UDim2.new(0, 18, 0, 18)
    modeHUDClose.Position = UDim2.new(1, -22, 0.5, -9)
    modeHUDClose.BackgroundColor3 = Config.PanelColor
    modeHUDClose.Text = "✕"
    modeHUDClose.TextColor3 = Color3.fromRGB(180, 185, 200)
    modeHUDClose.Font = Enum.Font.GothamBold
    modeHUDClose.TextSize = 9
    modeHUDClose.ZIndex = 52
    Instance.new("UICorner", modeHUDClose).CornerRadius = UDim.new(0, 4)
    modeHUDClose.MouseButton1Click:Connect(function()
        playClickSound()
        modeHUD.Visible = false
    end)

    local modeHUDScroll = Instance.new("ScrollingFrame", modeHUD)
    modeHUDScroll.Size = UDim2.new(1, -12, 1, -34)
    modeHUDScroll.Position = UDim2.new(0, 6, 0, 30)
    modeHUDScroll.BackgroundTransparency = 1
    modeHUDScroll.ScrollBarThickness = 2
    modeHUDScroll.ScrollBarImageColor3 = Config.ThemeColor
    modeHUDScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    modeHUDScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    modeHUDScroll.ZIndex = 51

    local modeHUDBody = Instance.new("TextLabel", modeHUDScroll)
    modeHUDBody.Size = UDim2.new(1, -6, 0, 0)
    modeHUDBody.AutomaticSize = Enum.AutomaticSize.Y
    modeHUDBody.BackgroundTransparency = 1
    modeHUDBody.Text = ""
    modeHUDBody.TextColor3 = Color3.fromRGB(225, 230, 240)
    modeHUDBody.Font = Enum.Font.Code
    modeHUDBody.TextSize = 10
    modeHUDBody.TextXAlignment = Enum.TextXAlignment.Left
    modeHUDBody.TextYAlignment = Enum.TextYAlignment.Top
    modeHUDBody.TextWrapped = true
    modeHUDBody.RichText = true
    modeHUDBody.ZIndex = 52


    showModeHUD = function(titleText, bodyText)
        if lastHUDTitle ~= titleText then
            lastHUDTitle = titleText
            modeHUDTitle.Text = titleText
        end
        if lastHUDBody ~= bodyText then
            lastHUDBody = bodyText
            modeHUDBody.Text = bodyText
        end
        if not modeHUD.Visible then
            modeHUD.Visible = true
        end
    end

    getTargetPart = function(entity)
        if not entity then return nil end
        if entity:IsA("BasePart") then return entity end
        if entity:IsA("Model") then
            return entity.PrimaryPart or entity:FindFirstChild("Handle") or entity:FindFirstChild("HumanoidRootPart") or entity:FindFirstChildWhichIsA("BasePart")
        end
        return nil
    end

end

-----------------------------------------------------------
-- СИСТЕМА ESP ПРЕДМЕТОВ И МОНСТРА (ИИ) ДЛЯ STEAL OR DIE
-- Редкости: Common, Uncommon, Rare, Epic, Mythic, Legendary, Secret
-----------------------------------------------------------
local StealMod = { StealMod.lastFullStealScanTick = 0 }
do
    local StealItemVisuals = {}
    local StealMonsterVisuals = {}
    local StealExitVisuals = {}
    local DiscoveredStealItems = {}
    local DiscoveredStealMonsters = {}
    local DiscoveredStealExits = {}

    local isStealScanning = false

    function StealMod.clearAllStealVisuals()
        for _, v in pairs(StealItemVisuals) do
            pcall(function()
                if v.HL then v.HL:Destroy() end
                if v.BB then v.BB:Destroy() end
            end)
        end
        table.clear(StealItemVisuals)

        for _, v in pairs(StealMonsterVisuals) do
            pcall(function()
                if v.HL then v.HL:Destroy() end
                if v.BB then v.BB:Destroy() end
            end)
        end
        table.clear(StealMonsterVisuals)

        for _, v in pairs(StealExitVisuals) do
            pcall(function()
                if v.HL then v.HL:Destroy() end
                if v.BB then v.BB:Destroy() end
            end)
        end
        table.clear(StealExitVisuals)
    end

    function StealMod.disconnectStealListener()
        if StealMod.StealDescendantConn then
            pcall(function() StealMod.StealDescendantConn:Disconnect() end)
            StealMod.StealDescendantConn = nil
        end
    end

    local function detectStealItemMetadata(entity, prompt)
        local combined = entity.Name
        if prompt then
            combined = combined .. " " .. tostring(prompt.ObjectText) .. " " .. tostring(prompt.ActionText)
        end

        local rarityKey = nil
        local priceVal = 0
        local isUtilityTool = false

        local function inspectAttrs(inst)
            if not inst then return end
            for k, v in pairs(inst:GetAttributes()) do
                local kl = k:lower()
                local vs = tostring(v)
                if kl:find("rar") or kl:find("tier") or kl:find("grade") then
                    combined = combined .. " " .. vs
                elseif kl:find("price") or kl:find("val") or kl:find("worth") or kl:find("cash") or kl:find("money") or kl:find("sell") then
                    local num = tonumber(vs:match("%d+"))
                    if num and num > priceVal then priceVal = num end
                end
            end
        end
        inspectAttrs(entity)
        inspectAttrs(entity.Parent)

        for _, desc in ipairs(entity:GetDescendants()) do
            if desc:IsA("StringValue") then
                local nl = desc.Name:lower()
                if nl:find("rar") or nl:find("tier") or nl:find("name") or nl:find("grade") then
                    combined = combined .. " " .. desc.Value
                end
            elseif (desc:IsA("IntValue") or desc:IsA("NumberValue")) then
                local nl = desc.Name:lower()
                if nl:find("price") or nl:find("val") or nl:find("worth") or nl:find("cash") or nl:find("money") or nl:find("sell") then
                    if desc.Value > priceVal then priceVal = desc.Value end
                end
            elseif desc:IsA("TextLabel") and desc.Text ~= "" then
                combined = combined .. " " .. desc.Text
                local dollarNum = tonumber(desc.Text:gsub(",", ""):match("%$%s*(%d+)"))
                if dollarNum and dollarNum > priceVal then priceVal = dollarNum end
            end
        end

        local low = combined:lower()

        if low:find("screwdriver") or low:find("отверт") or low:find("keycard") or low:find("crowbar") or low:find("wrench") then
            isUtilityTool = true
        end

        -- ВАЖНО: проверяем "uncommon" ДО "common", так как "uncommon" содержит подстроку "common"!
        if low:find("secret") or low:find("секрет") then
            rarityKey = "Secret"
        elseif low:find("legendary") or low:find("легенд") then
            rarityKey = "Legendary"
        elseif low:find("mythic") or low:find("мифич") then
            rarityKey = "Mythic"
        elseif low:find("epic") or low:find("эпич") then
            rarityKey = "Epic"
        elseif low:find("rare") or low:find("редк") then
            rarityKey = "Rare"
        elseif low:find("uncommon") or low:find("необычн") then
            rarityKey = "Uncommon"
        elseif low:find("common") or low:find("обычн") then
            rarityKey = "Common"
        end

        if not rarityKey then
            if priceVal >= 2000 then
                rarityKey = "Secret"
            elseif priceVal >= 1000 then
                rarityKey = "Legendary"
            elseif priceVal >= 500 then
                rarityKey = "Mythic"
            elseif priceVal >= 250 then
                rarityKey = "Epic"
            elseif priceVal >= 120 then
                rarityKey = "Rare"
            elseif priceVal >= 50 then
                rarityKey = "Uncommon"
            else
                rarityKey = "Common"
            end
        end

        local rData = StealRarityOrder[rarityKey]
        local displayName = (prompt and prompt.ObjectText ~= "" and prompt.ObjectText) or entity.Name

        return {
            name = displayName,
            rarity = rarityKey,
            rank = rData.rank,
            label = rData.label,
            hex = rData.hex,
            color = isUtilityTool and Color3.fromRGB(56, 189, 248) or rData.color,
            price = priceVal,
            isTool = isUtilityTool
        }
    end

    -- Проверка, является ли модель Монстром / ИИ в Steal or Die
    local function isStealMonsterModel(model)
        if not model or not model:IsA("Model") or not model.Parent then return false end
        if Players:GetPlayerFromCharacter(model) ~= nil then return false end

        local hum = model:FindFirstChildOfClass("Humanoid")
        local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
        if not root then return false end

        local nl = model.Name:lower()
        local pl = model.Parent and model.Parent.Name:lower() or ""

        if nl:find("shop") or nl:find("merchant") or nl:find("vendor") or nl:find("dummy") or nl:find("mannequin") or nl:find("statue") or pl:find("lobby") or pl:find("shop") then
            return false
        end

        if hum and hum.Health > 0 then
            return true
        end

        if nl:find("monster") or nl:find("entity") or nl:find("hunter") or nl:find("killer") or nl:find("stalker") or nl:find("enemy") or nl:find("creature") or nl:find("locust") or pl:find("entit") or pl:find("monster") then
            return true
        end

        return false
    end

    function StealMod.classifySingleStealNode(desc)
        if not desc or not desc.Parent then return end

        -- 1. Проверка на Монстра (ИИ)
        if desc:IsA("Model") and not DiscoveredStealMonsters[desc] then
            if isStealMonsterModel(desc) then
                local mPart = desc:FindFirstChild("HumanoidRootPart") or desc.PrimaryPart or desc:FindFirstChildWhichIsA("BasePart")
                if mPart then
                    DiscoveredStealMonsters[desc] = {part = mPart, name = desc.Name}
                    return
                end
            end
        elseif desc:IsA("Humanoid") and desc.Parent and desc.Parent:IsA("Model") and not DiscoveredStealMonsters[desc.Parent] then
            if isStealMonsterModel(desc.Parent) then
                local mPart = desc.Parent:FindFirstChild("HumanoidRootPart") or desc.Parent.PrimaryPart or desc.Parent:FindFirstChildWhichIsA("BasePart")
                if mPart then
                    DiscoveredStealMonsters[desc.Parent] = {part = mPart, name = desc.Parent.Name}
                    return
                end
            end
        end

        -- 2. Выходы и вентиляции
        if desc:IsA("Model") or desc:IsA("BasePart") then
            local nl = desc.Name:lower()
            if nl:find("exit") or nl:find("escape") or nl:find("extract") then
                local ePart = getTargetPart(desc)
                if ePart and not DiscoveredStealExits[desc] then
                    DiscoveredStealExits[desc] = {part = ePart, kind = "EXIT"}
                end
                return
            elseif nl:find("vent") and desc:IsA("Model") then
                local vPart = getTargetPart(desc)
                if vPart and not DiscoveredStealExits[desc] then
                    DiscoveredStealExits[desc] = {part = vPart, kind = "VENT"}
                end
                return
            end
        end

        -- 3. Краденые предметы
        local entity = nil
        local prompt = nil

        if desc:IsA("ProximityPrompt") or desc:IsA("ClickDetector") then
            if desc:IsA("ProximityPrompt") then
                prompt = desc
            end
            entity = desc.Parent
            if entity and entity.Parent and entity.Parent:IsA("Model") and entity.Parent ~= Workspace then
                entity = entity.Parent
            end
        elseif desc:IsA("Tool") then
            entity = desc
            prompt = desc:FindFirstChildWhichIsA("ProximityPrompt", true)
        elseif (desc:IsA("StringValue") or desc:IsA("IntValue") or desc:IsA("NumberValue")) and desc.Parent then
            local vl = desc.Name:lower()
            if vl == "rarity" or vl == "worth" or vl == "sellvalue" or vl == "itemvalue" then
                entity = desc.Parent
                if entity.Parent and entity.Parent:IsA("Model") and entity.Parent ~= Workspace then
                    entity = entity.Parent
                end
                prompt = entity:FindFirstChildWhichIsA("ProximityPrompt", true)
            end
        elseif (desc:IsA("Model") or desc:IsA("BasePart")) and desc.Parent then
            local pl = desc.Parent.Name:lower()
            local hasTag = false
            pcall(function()
                for _, tag in ipairs(CollectionService:GetTags(desc)) do
                    local tl = tag:lower()
                    if tl:find("item") or tl:find("loot") or tl:find("steal") or tl:find("valuab") or tl:find("pickup") then
                        hasTag = true
                        break
                    end
                end
            end)
            if hasTag or pl:find("item") or pl:find("loot") or pl:find("steal") or pl:find("pickup") or pl:find("drop") or pl:find("valuab") or pl:find("goods") or pl:find("collect")
                or desc:GetAttribute("Rarity") ~= nil or desc:GetAttribute("Value") ~= nil or desc:GetAttribute("Price") ~= nil or desc:GetAttribute("Worth") ~= nil then
                entity = desc
                prompt = desc:FindFirstChildWhichIsA("ProximityPrompt", true)
            end
        end

        if not entity or entity == Workspace or DiscoveredStealItems[entity] then return end
        if entity:FindFirstChildOfClass("Humanoid") then return end

        local cur = entity.Parent
        while cur and cur ~= Workspace do
            if cur:FindFirstChildOfClass("Humanoid") or cur:IsA("Backpack") then
                return
            end
            cur = cur.Parent
        end

        local el = entity.Name:lower()
        if el:find("door") or el:find("vent") or el:find("locker") or el:find("closet") or el:find("exit") or el:find("escape") or el:find("elevator") or el:find("shop") then
            return
        end
        if prompt then
            local act = (prompt.ActionText .. " " .. prompt.ObjectText):lower()
            if act:find("open") or act:find("close") or act:find("hide") or act:find("vent") or act:find("door") or act:find("exit") or act:find("escape") then
                return
            end
        end

        local part = getTargetPart(entity)
        if part then
            local meta = detectStealItemMetadata(entity, prompt)
            DiscoveredStealItems[entity] = {part = part, prompt = prompt, meta = meta}
        end
    end

    function StealMod.scanStealOrDieMapAsync(showNotification, onComplete)
        if isStealScanning then
            if onComplete then onComplete() end
            return
        end
        isStealScanning = true

        task.spawn(function()
            table.clear(DiscoveredStealItems)
            table.clear(DiscoveredStealMonsters)
            table.clear(DiscoveredStealExits)

            local descendants = Workspace:GetDescendants()
            local total = #descendants
            for i = 1, total do
                if not running or Config.ActiveGameMode ~= "StealOrDie" then
                    isStealScanning = false
                    return
                end
                StealMod.classifySingleStealNode(descendants[i])
                if i % 450 == 0 then
                    task.wait()
                end
            end

            isStealScanning = false

            if showNotification then
                local counts = {Common = 0, Uncommon = 0, Rare = 0, Epic = 0, Mythic = 0, Legendary = 0, Secret = 0}
                local totalItems = 0
                local monsterCount = 0
                for entity, info in pairs(DiscoveredStealItems) do
                    if entity.Parent then
                        totalItems = totalItems + 1
                        counts[info.meta.rarity] = (counts[info.meta.rarity] or 0) + 1
                    end
                end
                for m, _ in pairs(DiscoveredStealMonsters) do
                    if m.Parent then monsterCount = monsterCount + 1 end
                end
                local summary = string.format(
                    "Лут: %d (Sec:%d | Leg:%d | Myth:%d | Epic:%d) | Монстров: %d",
                    totalItems, counts.Secret, counts.Legendary, counts.Mythic, counts.Epic, monsterCount
                )
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Steal or Die • Скан",
                    Text = summary,
                    Duration = 4
                })
            end

            if onComplete then
                onComplete()
            end
        end)
    end

    -- Единая синхронизация ESP Предметов (с фильтром редкости), ESP Монстра (ИИ) и ESP Выхода
    function StealMod.syncStealVisuals()
        if not running or Config.ActiveGameMode ~= "StealOrDie" then
            StealMod.clearAllStealVisuals()
            return
        end

        local minRank = StealMinRankMap[Config.StealMinRarity] or 1

        -- 1. ESP Монстра (ИИ)
        for model, vis in pairs(StealMonsterVisuals) do
            if not Config.StealMonsterESP or not model.Parent or not DiscoveredStealMonsters[model] then
                pcall(function()
                    if vis.HL then vis.HL:Destroy() end
                    if vis.BB then vis.BB:Destroy() end
                end)
                StealMonsterVisuals[model] = nil
            end
        end

        if Config.StealMonsterESP then
            for model, mInfo in pairs(DiscoveredStealMonsters) do
                if model.Parent and mInfo.part and mInfo.part.Parent and not StealMonsterVisuals[model] then
                    local hl = Instance.new("Highlight")
                    hl.Name = "StealMonster_HL"
                    hl.Adornee = model
                    hl.FillColor = Color3.fromRGB(255, 35, 35)
                    hl.OutlineColor = Color3.fromRGB(255, 220, 220)
                    hl.FillTransparency = 0.35
                    hl.OutlineTransparency = 0
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = EspContainer

                    local bb = Instance.new("BillboardGui")
                    bb.Name = "StealMonster_Tag"
                    bb.Adornee = mInfo.part
                    bb.Size = UDim2.new(0, 180, 0, 38)
                    bb.StudsOffset = Vector3.new(0, 3.2, 0)
                    bb.AlwaysOnTop = true
                    bb.MaxDistance = 5000
                    bb.Parent = EspContainer

                    local lbl = Instance.new("TextLabel", bb)
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3 = Color3.fromRGB(255, 70, 70)
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = 11
                    lbl.TextStrokeTransparency = 0.1
                    lbl.TextStrokeColor3 = Color3.fromRGB(10, 10, 14)

                    StealMonsterVisuals[model] = {HL = hl, BB = bb, Label = lbl, Part = mInfo.part, Name = mInfo.name, lastDist = -1}
                end
            end
        end

        -- 2. ESP Предметов с фильтрацией по выбранной минимальной редкости (StealMinRarity)
        for entity, vis in pairs(StealItemVisuals) do
            local info = DiscoveredStealItems[entity]
            local passRarity = info and ((info.meta.rank >= minRank) or info.meta.isTool)
            if not Config.StealItemsESP or not entity.Parent or not info or not info.part or not info.part.Parent or not passRarity then
                pcall(function()
                    if vis.HL then vis.HL:Destroy() end
                    if vis.BB then vis.BB:Destroy() end
                end)
                StealItemVisuals[entity] = nil
            end
        end

        if Config.StealItemsESP then
            local activeGlowCount = 0
            for _, vis in pairs(StealItemVisuals) do
                if vis.HL then activeGlowCount = activeGlowCount + 1 end
            end

            for entity, info in pairs(DiscoveredStealItems) do
                local passRarity = (info.meta.rank >= minRank) or info.meta.isTool
                if entity.Parent and info.part and info.part.Parent and passRarity and not StealItemVisuals[entity] then
                    local hl = nil
                    if (info.meta.rank >= 5 or info.meta.isTool) and activeGlowCount < 20 then
                        hl = Instance.new("Highlight")
                        hl.Name = "StealItem_HL"
                        hl.Adornee = entity
                        hl.FillColor = info.meta.color
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = (info.meta.rank >= 6) and 0.25 or 0.45
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = EspContainer
                        activeGlowCount = activeGlowCount + 1
                    end

                    local bb = Instance.new("BillboardGui")
                    bb.Name = "StealItem_Tag"
                    bb.Adornee = info.part
                    bb.Size = UDim2.new(0, 185, 0, 38)
                    bb.StudsOffset = Vector3.new(0, 2.0, 0)
                    bb.AlwaysOnTop = true
                    bb.MaxDistance = 2500
                    bb.Parent = EspContainer

                    local lbl = Instance.new("TextLabel", bb)
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3 = info.meta.color
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = (info.meta.rank >= 6) and 11 or 10
                    lbl.TextStrokeTransparency = 0.15
                    lbl.TextStrokeColor3 = Color3.fromRGB(10, 10, 14)

                    StealItemVisuals[entity] = {HL = hl, BB = bb, Label = lbl, Part = info.part, Meta = info.meta, lastDist = -1}
                end
            end
        end

        -- 3. ESP Выхода и Вентиляций
        for entity, vis in pairs(StealExitVisuals) do
            if not Config.StealExitESP or not entity.Parent or not DiscoveredStealExits[entity] then
                pcall(function()
                    if vis.HL then vis.HL:Destroy() end
                    if vis.BB then vis.BB:Destroy() end
                end)
                StealExitVisuals[entity] = nil
            end
        end

        if Config.StealExitESP then
            for entity, exInfo in pairs(DiscoveredStealExits) do
                if entity.Parent and exInfo.part and not StealExitVisuals[entity] then
                    local col = (exInfo.kind == "EXIT") and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(56, 189, 248)
                    local hl = nil
                    if exInfo.kind == "EXIT" then
                        hl = Instance.new("Highlight")
                        hl.Name = "StealExit_HL"
                        hl.Adornee = entity
                        hl.FillColor = col
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.4
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = EspContainer
                    end

                    local bb = Instance.new("BillboardGui")
                    bb.Name = "StealExit_Tag"
                    bb.Adornee = exInfo.part
                    bb.Size = UDim2.new(0, 140, 0, 32)
                    bb.StudsOffset = Vector3.new(0, 2.8, 0)
                    bb.AlwaysOnTop = true
                    bb.MaxDistance = 2500
                    bb.Parent = EspContainer

                    local lbl = Instance.new("TextLabel", bb)
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3 = col
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = 10
                    lbl.TextStrokeTransparency = 0.15
                    lbl.TextStrokeColor3 = Color3.fromRGB(10, 10, 14)

                    StealExitVisuals[entity] = {HL = hl, BB = bb, Label = lbl, Part = exInfo.part, Kind = exInfo.kind, lastDist = -1}
                end
            end
        end
    end

    -- Оптимизированный цикл обновления Steal or Die

    table.insert(threads, task.spawn(function()
        while running do
            task.wait(0.2)
            if Config.ActiveGameMode == "StealOrDie" then
                pcall(function()
                    if (tick() - StealMod.lastFullStealScanTick) > 8 and not isStealScanning then
                        StealMod.lastFullStealScanTick = tick()
                        StealMod.scanStealOrDieMapAsync(false, StealMod.syncStealVisuals)
                    end

                    if Config.StealItemsESP or Config.StealMonsterESP or Config.StealExitESP then
                        StealMod.syncStealVisuals()
                    end

                    local myChar = getCharacter(LocalPlayer)
                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

                    if myRoot then
                        if Config.StealMonsterESP then
                            for _, vis in pairs(StealMonsterVisuals) do
                                if vis.Part and vis.Part.Parent and vis.Label then
                                    local dist = math.floor((vis.Part.Position - myRoot.Position).Magnitude)
                                    if vis.lastDist ~= dist then
                                        vis.lastDist = dist
                                        vis.Label.Text = string.format("👹 МОНСТР (%s)\n[%dm]", vis.Name, dist)
                                    end
                                end
                            end
                        end

                        if Config.StealItemsESP then
                            for _, vis in pairs(StealItemVisuals) do
                                if vis.Part and vis.Part.Parent and vis.Label then
                                    local dist = math.floor((vis.Part.Position - myRoot.Position).Magnitude)
                                    if vis.lastDist ~= dist then
                                        vis.lastDist = dist
                                        local tagPrefix = vis.Meta.isTool and "🔧 [TOOL]" or ("[" .. vis.Meta.label .. "]")
                                        local priceStr = (vis.Meta.price > 0) and (" $" .. vis.Meta.price) or ""
                                        vis.Label.Text = string.format("%s %s%s\n[%dm]", tagPrefix, vis.Meta.name, priceStr, dist)
                                    end
                                end
                            end
                        end

                        if Config.StealExitESP then
                            for _, vis in pairs(StealExitVisuals) do
                                if vis.Part and vis.Part.Parent and vis.Label then
                                    local dist = math.floor((vis.Part.Position - myRoot.Position).Magnitude)
                                    if vis.lastDist ~= dist then
                                        vis.lastDist = dist
                                        local title = (vis.Kind == "EXIT") and "🚪 ВЫХОД (EXIT)" or "🌀 ВЕНТИЛЯЦИЯ"
                                        vis.Label.Text = string.format("%s [%dm]", title, dist)
                                    end
                                end
                            end
                        end
                    end

                    if Config.StealAutoCollect and myRoot then
                        for entity, info in pairs(DiscoveredStealItems) do
                            if entity.Parent and info.part and info.prompt and info.prompt.Enabled then
                                local dist = (info.part.Position - myRoot.Position).Magnitude
                                if dist <= (info.prompt.MaxActivationDistance + 3) then
                                    triggerPrompt(info.prompt)
                                end
                            end
                        end
                    end

                    -- Радар лута (HUD) с учетом выбранного фильтра редкости
                    if Config.StealLootHUD then
                        local minRank = StealMinRankMap[Config.StealMinRarity] or 1
                        local sorted = {}
                        local counts = {Secret = 0, Legendary = 0, Mythic = 0, Epic = 0, Rare = 0, Uncommon = 0, Common = 0}
                        for entity, info in pairs(DiscoveredStealItems) do
                            if entity.Parent and info.part then
                                counts[info.meta.rarity] = (counts[info.meta.rarity] or 0) + 1
                                if info.meta.rank >= minRank or info.meta.isTool then
                                    local d = myRoot and math.floor((info.part.Position - myRoot.Position).Magnitude) or 0
                                    table.insert(sorted, {info = info, dist = d})
                                end
                            end
                        end

                        table.sort(sorted, function(a, b)
                            if a.info.meta.rank ~= b.info.meta.rank then
                                return a.info.meta.rank > b.info.meta.rank
                            end
                            if a.info.meta.price ~= b.info.meta.price then
                                return a.info.meta.price > b.info.meta.price
                            end
                            return a.dist < b.dist
                        end)

                        local lines = {
                            string.format(
                                "<b>📊 ЛУТ:</b> <font color='#FF00E6'>Sec:%d</font> | <font color='#F59E0B'>Leg:%d</font> | <font color='#EF4444'>Myth:%d</font> | <font color='#A855F7'>Epic:%d</font>\n<font color='#3B82F6'>Rare:%d</font> | <font color='#22C55E'>Uncom:%d</font> | <font color='#B9C0CC'>Com:%d</font>\n",
                                counts.Secret, counts.Legendary, counts.Mythic, counts.Epic, counts.Rare, counts.Uncommon, counts.Common
                            )
                        }

                        if #sorted == 0 then
                            lines[#lines + 1] = "<font color='#9CA3AF'>Нет предметов выбранной редкости...</font>"
                        else
                            local maxShow = math.min(#sorted, 10)
                            for i = 1, maxShow do
                                local item = sorted[i]
                                local m = item.info.meta
                                local priceTxt = (m.price > 0) and string.format(" ($%d)", m.price) or ""
                                lines[#lines + 1] = string.format(
                                    "%d. <font color='%s'><b>[%s]</b></font> %s%s — <b>%dm</b>",
                                    i, m.hex, m.label, m.name, priceTxt, item.dist
                                )
                            end
                        end

                        showModeHUD("STEAL OR DIE • РАДАР ЛУТА", table.concat(lines, "\n"))
                    end
                end)
            end
        end
    end))

    function StealMod.buildStealOrDieMode(parent)
        UI.createButton(parent, "StealScanBtn", function()
            StealMod.lastFullStealScanTick = tick()
            StealMod.scanStealOrDieMapAsync(true, StealMod.syncStealVisuals)
        end)

        UI.createToggle(parent, "StealItemsESP", function()
            StealMod.syncStealVisuals()
        end)

        UI.createDropdown(parent, "StealMinRarity", {"All (Common+)", "Uncommon+", "Rare+", "Epic+", "Mythic+", "Legendary+", "Secret Only"}, function()
            StealMod.syncStealVisuals()
        end)

        UI.createToggle(parent, "StealMonsterESP", function()
            StealMod.syncStealVisuals()
        end)

        UI.createToggle(parent, "StealExitESP", function()
            StealMod.syncStealVisuals()
        end)

        UI.createToggle(parent, "StealLootHUD", function(state)
            if not state then
                modeHUD.Visible = false
            end
        end)

        UI.createToggle(parent, "StealAutoCollect")

        UI.createButton(parent, "StealTpBestBtn", function()
            local myRoot = getCharacter(LocalPlayer) and getCharacter(LocalPlayer):FindFirstChild("HumanoidRootPart")
            local bestPart = nil
            local bestRank = -1
            local bestPrice = -1
            local bestDist = math.huge

            for entity, info in pairs(DiscoveredStealItems) do
                if entity.Parent and info.part then
                    local d = myRoot and (myRoot.Position - info.part.Position).Magnitude or 0
                    if info.meta.rank > bestRank or (info.meta.rank == bestRank and info.meta.price > bestPrice) or (info.meta.rank == bestRank and info.meta.price == bestPrice and d < bestDist) then
                        bestRank = info.meta.rank
                        bestPrice = info.meta.price
                        bestDist = d
                        bestPart = info.part
                    end
                end
            end

            if bestPart then
                secureMove(bestPart.Position + Vector3.new(0, 3, 0))
            else
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Steal or Die",
                    Text = langStr("StealNoItemAlert"),
                    Duration = 3
                })
            end
        end)

        UI.createButton(parent, "StealTpClosestBtn", function()
            local myRoot = getCharacter(LocalPlayer) and getCharacter(LocalPlayer):FindFirstChild("HumanoidRootPart")
            if not myRoot then return end

            local minRank = StealMinRankMap[Config.StealMinRarity] or 1
            local closestPart = nil
            local minDist = math.huge

            for entity, info in pairs(DiscoveredStealItems) do
                if entity.Parent and info.part and (info.meta.rank >= minRank or info.meta.isTool) then
                    local d = (myRoot.Position - info.part.Position).Magnitude
                    if d < minDist then
                        minDist = d
                        closestPart = info.part
                    end
                end
            end

            if closestPart then
                secureMove(closestPart.Position + Vector3.new(0, 3, 0))
            else
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Steal or Die",
                    Text = langStr("StealNoItemAlert"),
                    Duration = 3
                })
            end
        end)

        UI.createButton(parent, "StealTpExitBtn", function()
            local exitPart = nil
            for entity, exInfo in pairs(DiscoveredStealExits) do
                if entity.Parent and exInfo.part and exInfo.kind == "EXIT" then
                    exitPart = exInfo.part
                    break
                end
            end

            if exitPart then
                secureMove(exitPart.Position + Vector3.new(0, 3, 0))
            else
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Steal or Die",
                    Text = langStr("StealNoExitAlert"),
                    Duration = 3
                })
            end
        end)
    end

end

-----------------------------------------------------------
-- СИСТЕМА ПОЛЕТА НАД ДОРОГОЙ ПО КРУГАМ И ЧЕКПОИНТАМ ДЛЯ DRIVING EMPIRE
-----------------------------------------------------------
local DEMod = { DEMod.DEActiveRunToken = 0, DEMod.DECachedCheckpoints = {} }
do
    local DECheckpointVisuals = {}

    local OriginalVehicleCollideCache = {}
    local DECollisionAppliedModel = nil

    local DEDescendantConn = nil
    local DEIsScanning = false
    local DELastFullScanTick = 0

    function DEMod.disconnectDEListener()
        if DEDescendantConn then
            pcall(function() DEDescendantConn:Disconnect() end)
            DEDescendantConn = nil
        end
    end

    function DEMod.setVehicleFlightNoClip(vehicleModel, enableNoClip)
        if enableNoClip then
            if not vehicleModel or not vehicleModel.Parent then return end
            if DECollisionAppliedModel == vehicleModel then
                return
            end
            DEMod.setVehicleFlightNoClip(nil, false)
            rebuildVehiclePartCache(vehicleModel)
            DECollisionAppliedModel = vehicleModel
            for _, part in ipairs(CachedVehiclePartsList) do
                if part and part.Parent then
                    if OriginalVehicleCollideCache[part] == nil then
                        OriginalVehicleCollideCache[part] = part.CanCollide
                    end
                    if part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        else
            DECollisionAppliedModel = nil
            for part, origCollide in pairs(OriginalVehicleCollideCache) do
                if part and part.Parent then
                    pcall(function()
                        part.CanCollide = origCollide
                    end)
                end
            end
            table.clear(OriginalVehicleCollideCache)
        end
    end

    -- База гонок Driving Empire с точным расчетом кругов (laps), чекпоинтов на круг и длины трассы
    local DrivingEmpireRaces = {
        ["Auto Detect"] = {
            aliases = {},
            laps = 1,
            minSec = 10,
            defaultSec = 25,
            cpPerLap = 12,
            lapStuds = 9000,
            cpDesc = "Авто-определение",
            wrText = "Зависит от трассы",
            avgText = "Авто-режим"
        },
        ["Drag Race (Vine Hill)"] = {
            aliases = {"drag", "vine", "strip"},
            laps = 1,
            minSec = 5,
            defaultSec = 6,
            cpPerLap = 2,
            lapStuds = 1650,
            cpDesc = "1 круг • 2 точки (включая финиш)",
            wrText = "~4–5+ сек",
            avgText = "6–8 сек"
        },
        ["Highway Race"] = {
            aliases = {"highway", "hwy"},
            laps = 1,
            minSec = 22,
            defaultSec = 25,
            cpPerLap = 12,
            lapStuds = 13500,
            cpDesc = "1 круг • вдоль шоссе",
            wrText = "~23–25 сек",
            avgText = "1:30–1:40"
        },
        ["Circuit Race (Joya Costa)"] = {
            aliases = {"circuit", "joya", "costa", "speedway"},
            laps = 2,
            minSec = 125,
            defaultSec = 130,
            cpPerLap = 18,
            lapStuds = 14250,
            cpDesc = "2 круга (кольцевая трасса)",
            wrText = "~127.1 сек (2:07.1)",
            avgText = "2:20–2:40"
        },
        ["Cross Country Race"] = {
            aliases = {"cross", "country"},
            laps = 1,
            minSec = 125,
            defaultSec = 132,
            cpPerLap = 45,
            lapStuds = 34000,
            cpDesc = "1 круг (почти вся карта)",
            wrText = "~128–130 сек",
            avgText = "3:30–4:15"
        },
        ["Drawbridge Sprint"] = {
            aliases = {"drawbridge", "bridge", "sprint"},
            laps = 1,
            minSec = 72,
            defaultSec = 76,
            cpPerLap = 22,
            lapStuds = 16500,
            cpDesc = "1 круг (мост + город)",
            wrText = "~74.1 сек (1:14.1)",
            avgText = "1:20–1:40"
        },
        ["Rush Hour"] = {
            aliases = {"rush", "hour", "wayfort", "downtown"},
            laps = 1,
            minSec = 22,
            defaultSec = 26,
            cpPerLap = 14,
            lapStuds = 7200,
            cpDesc = "1 круг (Wayfort)",
            wrText = "~23–31 сек",
            avgText = "40–60 сек"
        },
        ["Sandy Shores"] = {
            aliases = {"sandy", "shores", "island", "offroad"},
            laps = 3,
            minSec = 65,
            defaultSec = 75,
            cpPerLap = 11,
            lapStuds = 6200,
            cpDesc = "3 круга (остров оффроуд)",
            wrText = "Зависит от версии",
            avgText = "3 круга по острову"
        }
    }

    local DERaceDropdownOrder = {
        "Drag Race (Vine Hill)",
        "Highway Race",
        "Circuit Race (Joya Costa)",
        "Cross Country Race",
        "Drawbridge Sprint",
        "Rush Hour",
        "Sandy Shores",
        "Auto Detect"
    }

    function DEMod.clearAllDEVisuals()
        for _, v in pairs(DECheckpointVisuals) do
            pcall(function()
                if v.Box then v.Box:Destroy() end
                if v.BB then v.BB:Destroy() end
            end)
        end
        table.clear(DECheckpointVisuals)
    end

    local function getSelectedRaceData()
        return DrivingEmpireRaces[Config.DERaceSelect] or DrivingEmpireRaces["Auto Detect"]
    end

    -- Кэшированное чтение кругов из интерфейса Driving Empire (0 просадок FPS — без GetDescendants каждый кадр!)
    local CachedLapHudLabel = nil
    local LastLapHudScanTick = 0

    local function parseLapText(txt)
        if not txt or txt == "" or #txt > 24 then return nil, nil end
        local tl = txt:lower()
        if tl:find("lap") or tl:find("круг") then
            local cur, tot = tl:match("(%d+)%s*/%s*(%d+)")
            if cur and tot then
                local cNum, tNum = tonumber(cur), tonumber(tot)
                if cNum and tNum and tNum >= 1 and tNum <= 20 and cNum >= 1 and cNum <= tNum then
                    return cNum, tNum
                end
            end
        end
        return nil, nil
    end

    local function readDrivingEmpireLapHUD()
        if CachedLapHudLabel and CachedLapHudLabel.Parent and CachedLapHudLabel.Visible then
            local c, t = parseLapText(CachedLapHudLabel.Text)
            if c and t then
                return c, t
            end
        end

        if (tick() - LastLapHudScanTick) < 1.5 then
            return nil, nil
        end
        LastLapHudScanTick = tick()

        local pg = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return nil, nil end

        for _, obj in ipairs(pg:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Visible and obj.Text ~= "" and #obj.Text <= 24 then
                local c, t = parseLapText(obj.Text)
                if c and t then
                    CachedLapHudLabel = obj
                    return c, t
                end
            end
        end
        return nil, nil
    end

    local function getTargetTotalLaps()
        local override = tonumber(Config.DELapsCount) or 0
        if override >= 1 then
            return math.floor(override)
        end
        local _, hudTotal = readDrivingEmpireLapHUD()
        if hudTotal and hudTotal >= 1 then
            return hudTotal
        end
        local rData = getSelectedRaceData()
        return rData.laps or 1
    end

    local function enforceDERecordMinimum(notifyUser)
        local rData = getSelectedRaceData()
        local baseLaps = math.max(1, rData.laps or 1)
        local targetLaps = getTargetTotalLaps()
        local minAllowed = math.max(5, math.floor((rData.minSec or 10) * (targetLaps / baseLaps)))
        local current = tonumber(Config.DERecordSeconds) or rData.defaultSec
        if current < minAllowed then
            Config.DERecordSeconds = minAllowed
            UI.refreshAllTranslations()
            if notifyUser then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Driving Empire",
                    Text = langStr("DEMinClampAlert") .. tostring(minAllowed) .. " сек",
                    Duration = 3
                })
            end
        end
        return Config.DERecordSeconds, minAllowed
    end

    local function isCheckpointVisuallyActive(part, cpModel)
        if not part or not part.Parent then return false end
        if part.CanTouch and part.Transparency < 0.95 then
            return true
        end
        local target = cpModel or part
        for _, d in ipairs(target:GetChildren()) do
            if (d:IsA("ParticleEmitter") or d:IsA("BillboardGui") or d:IsA("SurfaceGui") or d:IsA("PointLight") or d:IsA("SpotLight")) and d.Enabled then
                return true
            elseif d:IsA("BasePart") and d.Transparency < 0.92 and d.Name:lower() ~= "hitbox" then
                return true
            end
        end
        return part.CanTouch
    end

    local function resolveBestCheckpointHitbox(inst)
        if not inst or not inst.Parent then return nil, nil, nil, nil end
        local model = inst:IsA("Model") and inst or nil
        if not model and inst.Parent and inst.Parent:IsA("Model") and inst.Parent ~= Workspace then
            local pn = inst.Parent.Name:lower()
            if pn:find("check") or pn:find("gate") or pn:find("ring") or pn:find("finish") or pn:match("^%d+$") then
                model = inst.Parent
            end
        end

        if model then
            local touchPart = nil
            local triggerPart = nil
            for _, d in ipairs(model:GetDescendants()) do
                if d:IsA("BasePart") then
                    if d:FindFirstChildOfClass("TouchTransmitter") then
                        touchPart = d
                        break
                    end
                    local dl = d.Name:lower()
                    if dl:find("hit") or dl:find("touch") or dl:find("trig") or dl:find("zone") or dl:find("center") or (not d.CanCollide and d.Transparency > 0 and d.Transparency < 0.98) then
                        triggerPart = d
                    end
                end
            end
            local bboxCF, bboxSize = model:GetBoundingBox()
            local chosenPart = touchPart or triggerPart or getTargetPart(model)
            if chosenPart then
                local bottomY = bboxCF.Position.Y - (bboxSize.Y * 0.5)
                local exactPos = Vector3.new(bboxCF.Position.X, chosenPart.Position.Y, bboxCF.Position.Z)
                return chosenPart, exactPos, model, bottomY
            end
        end

        if inst:IsA("BasePart") then
            local bottomY = inst.Position.Y - (inst.Size.Y * 0.5)
            return inst, inst.Position, nil, bottomY
        end

        return nil, nil, nil, nil
    end

    local function makeCheckpointKey(part, pos)
        local p = pos or part.Position
        return string.format("%s_%d_%d_%d", part.Name, math.floor(p.X / 10), math.floor(p.Y / 10), math.floor(p.Z / 10))
    end

    local function evaluateSingleCheckpointNode(rawInst, rData, seenEntities, outList)
        if not rawInst or not rawInst.Parent then return end
        if isLocalCharPart(rawInst) or isLocalVehiclePart(rawInst) then return end

        local targetObj = nil
        local priorityBoost = 10
        local forcedOrder = nil

        if rawInst:IsA("Beam") and rawInst.Enabled then
            local bName = rawInst.Name:lower()
            local pName = rawInst.Parent and rawInst.Parent.Name:lower() or ""
            if bName:find("race") or bName:find("check") or bName:find("way") or pName:find("race") or pName:find("check") then
                if rawInst.Attachment1 and rawInst.Attachment1.Parent and rawInst.Attachment1.Parent:IsA("BasePart") then
                    targetObj = rawInst.Attachment1.Parent
                    priorityBoost = 60
                    forcedOrder = 1
                end
            end
        elseif (rawInst:IsA("Highlight") or rawInst:IsA("SelectionBox") or rawInst:IsA("BillboardGui")) and rawInst.Adornee then
            local iname = rawInst.Name:lower()
            if iname:find("check") or iname:find("race") or iname:find("finish") or iname:find("gate") then
                targetObj = rawInst.Adornee
                priorityBoost = 50
                forcedOrder = 1
            end
        elseif rawInst:IsA("BasePart") then
            local nl = rawInst.Name:lower()
            local pl = rawInst.Parent and rawInst.Parent.Name:lower() or ""
            local gpl = (rawInst.Parent and rawInst.Parent.Parent) and rawInst.Parent.Parent.Name:lower() or ""

            local inRaceFolder = pl:find("checkpoint") or pl:find("activerace") or pl:find("race_") or pl:find("gates")
                or gpl:find("checkpoint") or gpl:find("activerace") or gpl:find("races")
            local isCpPart = nl:find("checkpoint") or nl:find("finishline") or nl:find("finish_line")
                or (nl == "finish") or (nl:match("^cp%d+$")) or (nl:match("^checkpoint%d+$"))
                or (inRaceFolder and (nl:match("^%d+$") or nl:find("gate") or nl:find("ring") or nl:find("goal") or rawInst:FindFirstChildOfClass("TouchTransmitter") ~= nil))

            if isCpPart then
                targetObj = rawInst
                priorityBoost = inRaceFolder and 20 or 10
            end
        end

        if not targetObj or not targetObj.Parent then return end
        if isLocalCharPart(targetObj) or isLocalVehiclePart(targetObj) then return end

        local part, centerPos, cpModel, bottomY = resolveBestCheckpointHitbox(targetObj)
        if not part or not part.Parent then return end

        local keyEntity = cpModel or part
        if seenEntities[keyEntity] then return end

        local nl = part.Name:lower()
        local mn = cpModel and cpModel.Name:lower() or ""
        local pl = part.Parent and part.Parent.Name:lower() or ""
        local gpl = (part.Parent and part.Parent.Parent) and part.Parent.Parent.Name:lower() or ""
        local fullPath = (nl .. " " .. mn .. " " .. pl .. " " .. gpl)

        if (fullPath:find("join") or fullPath:find("lobby")) and not fullPath:find("finish") then
            return
        end
        if nl:find("start") and not nl:find("finish") and not fullPath:find("checkpoint") and not fullPath:find("active") then
            return
        end

        seenEntities[keyEntity] = true

        local isFinish = fullPath:find("finish") or fullPath:find("goal") or nl == "end" or mn == "end"
        local num = forcedOrder
        if not num then
            num = tonumber(mn:match("(%d+)")) or tonumber(nl:match("(%d+)")) or tonumber(pl:match("(%d+)"))
        end
        if isFinish then
            num = 999999
        elseif not num then
            num = 50000
        end

        local aliasMatch = 0
        for _, al in ipairs(rData.aliases) do
            if fullPath:find(al) then
                aliasMatch = 10
                break
            end
        end

        local hasTouch = part:FindFirstChildOfClass("TouchTransmitter") ~= nil
        local isActive = isCheckpointVisuallyActive(part, cpModel)
        local posNow = centerPos or part.Position

        table.insert(outList, {
            part = part,
            model = cpModel,
            bottomY = bottomY or (part.Position.Y - part.Size.Y * 0.5),
            posKey = makeCheckpointKey(part, posNow),
            capturedPos = posNow,
            order = num,
            isFinish = isFinish,
            isActive = isActive,
            score = priorityBoost + aliasMatch + (hasTouch and 8 or 0) + (isActive and 15 or -20),
            name = isFinish and "FINISH" or ("CP #" .. tostring(num < 50000 and num or (#outList + 1)))
        })
    end

    local function refreshDrivingEmpireCacheAsync(onDone)
        if DEIsScanning then
            if onDone then onDone(DEMod.DECachedCheckpoints) end
            return
        end
        DEIsScanning = true
        DELastFullScanTick = tick()

        task.spawn(function()
            local newFound = {}
            local seenEntities = {}
            local rData = getSelectedRaceData()

            for _, tagName in ipairs({"Checkpoint", "RaceCheckpoint", "FinishLine", "RaceGate"}) do
                pcall(function()
                    for _, tagged in ipairs(CollectionService:GetTagged(tagName)) do
                        evaluateSingleCheckpointNode(tagged, rData, seenEntities, newFound)
                    end
                end)
            end

            local descendants = Workspace:GetDescendants()
            local total = #descendants
            for i = 1, total do
                if not running or Config.ActiveGameMode ~= "DrivingEmpire" then
                    DEIsScanning = false
                    return
                end
                evaluateSingleCheckpointNode(descendants[i], rData, seenEntities, newFound)
                if i % 1200 == 0 then
                    task.wait()
                end
            end

            table.sort(newFound, function(a, b)
                if a.isActive ~= b.isActive then
                    return a.isActive
                end
                if a.order ~= b.order then
                    return a.order < b.order
                end
                return a.score > b.score
            end)

            DEMod.DECachedCheckpoints = newFound
            DEIsScanning = false
            if onDone then
                onDone(DEMod.DECachedCheckpoints)
            end
        end)
    end

    local function getFastDrivingEmpireCheckpoints()
        local rData = getSelectedRaceData()
        local alive = {}
        local seenEntities = {}

        for _, cp in ipairs(DEMod.DECachedCheckpoints) do
            if cp.part and cp.part.Parent then
                local keyEntity = cp.model or cp.part
                if not seenEntities[keyEntity] then
                    seenEntities[keyEntity] = true
                    local posNow = cp.part.Position
                    cp.posKey = makeCheckpointKey(cp.part, posNow)
                    cp.capturedPos = posNow
                    cp.isActive = isCheckpointVisuallyActive(cp.part, cp.model)
                    table.insert(alive, cp)
                end
            end
        end

        local char = getCharacter(LocalPlayer)
        if char then
            for _, d in ipairs(char:GetDescendants()) do
                if d:IsA("Beam") and d.Enabled then
                    evaluateSingleCheckpointNode(d, rData, seenEntities, alive)
                end
            end
        end

        table.sort(alive, function(a, b)
            if a.isActive ~= b.isActive then
                return a.isActive
            end
            if a.order ~= b.order then
                return a.order < b.order
            end
            return a.score > b.score
        end)

        DEMod.DECachedCheckpoints = alive

        if #alive == 0 and (tick() - DELastFullScanTick) > 3.0 and not DEIsScanning then
            refreshDrivingEmpireCacheAsync(nil)
        end

        return alive
    end

    local function ensureDECheckpointListener()
        if DEDescendantConn then return end
        DEDescendantConn = Workspace.DescendantAdded:Connect(function(desc)
            if not running or Config.ActiveGameMode ~= "DrivingEmpire" then return end
            -- Быстрый фильтр: игнорируем обычные коллизионные детали окружения, эффекты дыма и следы шин
            if desc:IsA("BasePart") then
                if desc.CanCollide or desc.Transparency >= 0.96 then return end
                local nl = desc.Name:lower()
                if not (nl:find("check") or nl:find("finish") or nl:find("gate") or nl:find("ring") or nl:find("goal") or nl:match("^cp%d+$") or nl:match("^%d+$")) then
                    return
                end
            elseif not (desc:IsA("Beam") or desc:IsA("Highlight") or desc:IsA("SelectionBox") or desc:IsA("BillboardGui")) then
                return
            end

            local seen = {}
            for _, cp in ipairs(DEMod.DECachedCheckpoints) do
                seen[cp.model or cp.part] = true
            end
            evaluateSingleCheckpointNode(desc, getSelectedRaceData(), seen, DEMod.DECachedCheckpoints)
        end)
    end

    local function updateDECheckpointsESP(cpList)
        if not Config.DEShowCheckpointsESP or not running or Config.ActiveGameMode ~= "DrivingEmpire" then
            DEMod.clearAllDEVisuals()
            return
        end

        cpList = cpList or getFastDrivingEmpireCheckpoints()
        local activeSet = {}
        for _, cp in ipairs(cpList) do
            activeSet[cp.part] = cp
        end

        for part, vis in pairs(DECheckpointVisuals) do
            if not part.Parent or not activeSet[part] then
                pcall(function()
                    if vis.Box then vis.Box:Destroy() end
                    if vis.BB then vis.BB:Destroy() end
                end)
                DECheckpointVisuals[part] = nil
            end
        end

        local myChar = getCharacter(LocalPlayer)
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

        for idx, cp in ipairs(cpList) do
            if idx <= 25 then
                local vis = DECheckpointVisuals[cp.part]
                if not vis then
                    local col = cp.isFinish and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(56, 189, 248)
                    local box = Instance.new("SelectionBox")
                    box.Name = "DE_CP_Box"
                    box.Adornee = cp.model or cp.part
                    box.Color3 = col
                    box.LineThickness = 0.06
                    box.AlwaysOnTop = true
                    box.Parent = EspContainer

                    local bb = Instance.new("BillboardGui")
                    bb.Name = "DE_CP_Tag"
                    bb.Adornee = cp.part
                    bb.Size = UDim2.new(0, 150, 0, 34)
                    bb.StudsOffset = Vector3.new(0, 4, 0)
                    bb.AlwaysOnTop = true
                    bb.MaxDistance = 10000
                    bb.Parent = EspContainer

                    local lbl = Instance.new("TextLabel", bb)
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3 = col
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = 10
                    lbl.TextStrokeTransparency = 0.15
                    lbl.TextStrokeColor3 = Color3.fromRGB(10, 10, 14)

                    vis = {Box = box, BB = bb, Label = lbl, CP = cp, lastDist = -1}
                    DECheckpointVisuals[cp.part] = vis
                end

                if vis and myRoot then
                    local dist = math.floor((cp.part.Position - myRoot.Position).Magnitude)
                    if vis.lastDist ~= dist then
                        vis.lastDist = dist
                        vis.Label.Text = string.format("🏁 %s [%dm]", cp.isFinish and "ФИНИШ" or ("ЧЕКПОИНТ #" .. idx), dist)
                    end
                end
            end
        end
    end

    local function isRoadSurfaceHit(hit)
        if not hit or not hit.Instance then return false end
        local mat = hit.Material
        if mat == Enum.Material.Asphalt or mat == Enum.Material.Concrete or mat == Enum.Material.Pavement or mat == Enum.Material.Cobblestone then
            return true
        end
        local nl = hit.Instance.Name:lower()
        local pl = hit.Instance.Parent and hit.Instance.Parent.Name:lower() or ""
        if nl:find("road") or nl:find("street") or nl:find("highway") or nl:find("asphalt") or nl:find("bridge") or nl:find("track") or nl:find("lane") or nl:find("tunnel")
            or pl:find("road") or pl:find("highway") or pl:find("street") or pl:find("bridge") or pl:find("track") or pl:find("tunnel") then
            return true
        end
        return false
    end

    -- Умный двусторонний луч (вверх + вниз):
    -- Если над точкой есть крыша туннеля -> бьет вниз из-под потолка туннеля (залетает в туннель!).
    -- Если над точкой открытое небо -> бьет вниз с высоты +85 studs (НИКОГДА не проваливается под холмы и мосты!).
    local function sampleSmartRoadFloor(x, refY, z, rayParams)
        local upHit = Workspace:Raycast(Vector3.new(x, refY + 2.0, z), Vector3.new(0, 42, 0), rayParams)
        local startY
        local dropDist
        if upHit and upHit.Instance and (upHit.Instance.CanCollide or upHit.Instance:IsA("Terrain")) then
            -- Мы под сводом туннеля / моста: сканируем пол строго ниже потолка
            startY = upHit.Position.Y - 1.0
            dropDist = 55
        else
            -- Открытое небо: сканируем сверху над любыми подъемами и холмами
            startY = refY + 85.0
            dropDist = 220
        end

        local downHit = Workspace:Raycast(Vector3.new(x, startY, z), Vector3.new(0, -dropDist, 0), rayParams)
        if downHit and downHit.Instance and (downHit.Instance.CanCollide or downHit.Instance:IsA("Terrain")) then
            return downHit.Position.Y, isRoadSurfaceHit(downHit), (upHit ~= nil)
        end
        return nil, false, (upHit ~= nil)
    end

    -- Точный расчет пола дороги под чекпоинтом (работает и в туннелях, и на открытых трассах без ухода под карту)
    local function getCheckpointRoadFloorY(cpEntry, rayParams)
        local cpPart = cpEntry.part
        local hitY = sampleSmartRoadFloor(cpPart.Position.X, cpPart.Position.Y, cpPart.Position.Z, rayParams)
        if hitY then
            return hitY
        end
        -- Если луч не задел поверхность, берем центр чекпоинта (никогда не берем низ хитбокса, который может быть закопан под асфальт!)
        return cpPart.Position.Y - 2.0
    end

    -- Оптимизированный навигатор вдоль дороги (3 луча вместо 7 -> минимум нагрузки на CPU)
    local function computeRoadFollowingDirection(curPos, targetPos, fallbackDir, currentRoadY, cpRoadY, rayParams)
        local flatToTarget = Vector3.new(targetPos.X - curPos.X, 0, targetPos.Z - curPos.Z)
        local dist = flatToTarget.Magnitude
        if dist < 2 then
            return fallbackDir, currentRoadY
        end
        local directDir = flatToTarget.Unit

        if dist <= 42 then
            local nearFloorY = sampleSmartRoadFloor(targetPos.X, targetPos.Y, targetPos.Z, rayParams)
            return directDir, nearFloorY or cpRoadY
        end

        local angles = {0, -22, 22}
        local bestDir = directDir
        local bestScore = -99999
        local lookaheadRoadY = currentRoadY
        local expectedSlopeY = currentRoadY + (cpRoadY - currentRoadY) * math.min(1, 38 / dist)

        for _, deg in ipairs(angles) do
            local candDir
            if deg == 0 then
                candDir = directDir
            else
                local rad = math.rad(deg)
                local cosA, sinA = math.cos(rad), math.sin(rad)
                candDir = Vector3.new(
                    directDir.X * cosA - directDir.Z * sinA,
                    0,
                    directDir.X * sinA + directDir.Z * cosA
                ).Unit
            end

            local probePos = curPos + (candDir * 38)
            local gY, isRoad, inTunnel = sampleSmartRoadFloor(probePos.X, math.max(curPos.Y, expectedSlopeY), probePos.Z, rayParams)

            local alignScore = candDir:Dot(directDir) * 35
            local roadBonus = (isRoad or inTunnel) and 45 or 0
            -- Штрафуем только резкие крыши зданий (+28 студов выше ожидаемого уклона дороги)
            local roofPenalty = (gY and (gY - expectedSlopeY) > 28) and -75 or 0

            local totalScore = alignScore + roadBonus + roofPenalty
            if totalScore > bestScore then
                bestScore = totalScore
                bestDir = candDir
                if gY and (gY - expectedSlopeY) <= 28 then
                    lookaheadRoadY = gY
                end
            end
        end

        return bestDir, lookaheadRoadY
    end

    -- Поиск текущего активного чекпоинта по лучу навигации (Beam) игрока или машины
    local function getActiveBeamTargetPart()
        local char = getCharacter(LocalPlayer)
        if char then
            for _, d in ipairs(char:GetDescendants()) do
                if d:IsA("Beam") and d.Enabled and d.Attachment1 and d.Attachment1.Parent and d.Attachment1.Parent:IsA("BasePart") then
                    local bn = d.Name:lower()
                    local pn = d.Parent and d.Parent.Name:lower() or ""
                    if bn:find("race") or bn:find("check") or bn:find("way") or pn:find("race") or pn:find("check") then
                        return d.Attachment1.Parent
                    end
                end
            end
        end
        local _, _, vehModel = getVehicleData()
        if vehModel then
            for _, d in ipairs(vehModel:GetDescendants()) do
                if d:IsA("Beam") and d.Enabled and d.Attachment1 and d.Attachment1.Parent and d.Attachment1.Parent:IsA("BasePart") then
                    local bn = d.Name:lower()
                    local pn = d.Parent and d.Parent.Name:lower() or ""
                    if bn:find("race") or bn:find("check") or bn:find("way") or pn:find("race") or pn:find("check") then
                        return d.Attachment1.Parent
                    end
                end
            end
        end
        return nil
    end

    local function touchCheckpointDuringFlight(cpEntry, refPart, rootPart)
        if not firetouchinterest or not cpEntry or not cpEntry.part or not cpEntry.part.Parent then return end
        pcall(function()
            local touchTargets = {cpEntry.part}
            if cpEntry.model then
                for _, d in ipairs(cpEntry.model:GetDescendants()) do
                    if d:IsA("BasePart") and d ~= cpEntry.part and d:FindFirstChildOfClass("TouchTransmitter") then
                        table.insert(touchTargets, d)
                    end
                end
            end

            local carParts = {refPart}
            if rootPart and rootPart ~= refPart then
                table.insert(carParts, rootPart)
            end
            for i = 1, math.min(8, #CachedVehiclePartsList) do
                local p = CachedVehiclePartsList[i]
                if p and p.Parent then
                    table.insert(carParts, p)
                end
            end

            for _, tPart in ipairs(touchTargets) do
                for _, cPart in ipairs(carParts) do
                    firetouchinterest(cPart, tPart, 0)
                end
            end
            for _, tPart in ipairs(touchTargets) do
                for _, cPart in ipairs(carParts) do
                    firetouchinterest(cPart, tPart, 1)
                end
            end
        end)
    end

    -- Главный 60+ FPS цикл полета над дорогой с серверным подтверждением каждого чекпоинта (без откатов и сбросов!)
    local function startDrivingEmpireRunner()
        DEMod.DEActiveRunToken = DEMod.DEActiveRunToken + 1
        local myToken = DEMod.DEActiveRunToken

        ensureDECheckpointListener()
        refreshDrivingEmpireCacheAsync(nil)

        task.spawn(function()
            local targetSec, minSec = enforceDERecordMinimum(true)
            local rData = getSelectedRaceData()

            local seat, rootPart, vehicleModel = getVehicleData()
            if not seat or not rootPart then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Driving Empire",
                    Text = langStr("DENotInCarAlert"),
                    Duration = 4
                })
            end

            local runStartTime = tick()
            local currentLap = 1
            local totalLaps = getTargetTotalLaps()
            local touchedThisLap = 0
            local totalTouchedAllLaps = 0
            local takenCheckpointKeys = {}
            local smoothedSpeed = 60
            local lastHudUpdate = 0
            local lastListRefresh = 0
            local lastNavTick = 0
            local cachedCpList = {}

            -- Отслеживание подтверждения текущего чекпоинта сервером
            local activeTargetKey = nil
            local activeTargetStartTick = 0
            local activeTargetWasActive = false
            local passOscillationPhase = 0

            local lastValidRoadY = (seat and seat.Position.Y or 10) - 3.0
            local cachedLookaheadRoadY = lastValidRoadY
            local cachedNavDir = nil

            local cachedCarModel = nil
            local cachedSeatClearance = 3.0
            local cachedSeatToPivot = CFrame.identity

            local sharedRayParams = RaycastParams.new()
            sharedRayParams.FilterType = Enum.RaycastFilterType.Exclude
            sharedRayParams.IgnoreWater = true

            while running and Config.ActiveGameMode == "DrivingEmpire" and Config.DERecordActive and DEMod.DEActiveRunToken == myToken do
                local dt = RunService.Heartbeat:Wait()
                dt = math.clamp(dt, 0.001, 0.08)

                targetSec, minSec = enforceDERecordMinimum(false)
                rData = getSelectedRaceData()

                local hudCurLap, hudTotLap = readDrivingEmpireLapHUD()
                local configuredLaps = getTargetTotalLaps()
                totalLaps = math.max(configuredLaps, hudTotLap or 1)
                if hudCurLap and hudCurLap > currentLap and hudCurLap <= totalLaps then
                    currentLap = hudCurLap
                    touchedThisLap = 0
                    table.clear(takenCheckpointKeys)
                    activeTargetKey = nil
                end

                seat, rootPart, vehicleModel = getVehicleData()
                local char = getCharacter(LocalPlayer)
                local charRoot = char and char:FindFirstChild("HumanoidRootPart")
                local refPart = seat or rootPart or charRoot

                if vehicleModel and vehicleModel ~= cachedCarModel then
                    cachedCarModel = vehicleModel
                    local bboxCF, bboxSize = vehicleModel:GetBoundingBox()
                    local carBottomY = bboxCF.Position.Y - (bboxSize.Y * 0.5)
                    cachedSeatClearance = refPart and math.clamp(refPart.Position.Y - carBottomY, 1.8, 5.2) or 3.0
                    if refPart then
                        cachedSeatToPivot = refPart.CFrame:ToObjectSpace(vehicleModel:GetPivot())
                        lastValidRoadY = refPart.Position.Y - cachedSeatClearance
                        cachedLookaheadRoadY = lastValidRoadY
                    end
                end

                if (tick() - lastListRefresh) >= 0.15 then
                    lastListRefresh = tick()
                    cachedCpList = getFastDrivingEmpireCheckpoints()
                    if Config.DEShowCheckpointsESP then
                        updateDECheckpointsESP(cachedCpList)
                    end
                end

                -- Самовосстановление: если серверный луч (Beam) указывает на конкретный чекпоинт, снимаем с него пометку "взято"
                local beamTarget = getActiveBeamTargetPart()
                if beamTarget and beamTarget.Parent then
                    for _, cp in ipairs(cachedCpList) do
                        if cp.part == beamTarget or (cp.model and beamTarget:IsDescendantOf(cp.model)) then
                            if takenCheckpointKeys[cp.posKey] then
                                takenCheckpointKeys[cp.posKey] = nil
                            end
                            cp.isActive = true
                            break
                        end
                    end
                end

                local nextIdx = nil
                for idx, cp in ipairs(cachedCpList) do
                    if cp.part and cp.part.Parent and not takenCheckpointKeys[cp.posKey] then
                        nextIdx = idx
                        break
                    end
                end

                if not nextIdx and #cachedCpList > 0 and touchedThisLap > 0 and currentLap < totalLaps then
                    currentLap = currentLap + 1
                    touchedThisLap = 0
                    table.clear(takenCheckpointKeys)
                    activeTargetKey = nil
                    nextIdx = 1
                end

                local elapsed = tick() - runStartTime

                if not refPart or not nextIdx then
                    DEMod.setVehicleFlightNoClip(vehicleModel, false)
                    activeTargetKey = nil
                    if refPart then
                        lastValidRoadY = refPart.Position.Y - cachedSeatClearance
                        cachedLookaheadRoadY = lastValidRoadY
                    end
                    if (tick() - lastHudUpdate) >= 0.25 then
                        lastHudUpdate = tick()
                        showModeHUD(
                            "DRIVING EMPIRE • ПОЛЕТ НАД ДОРОГОЙ",
                            string.format(
                                "Трасса: <b>%s</b> | Круг: <b>%d/%d</b>\nЦель: <font color='#4ADE80'><b>%.1f сек</b></font> (Мин: %d сек)\nПройдено чекпоинтов: <b>%d</b>\nСтатус: <font color='#FBBF24'>%s</font>",
                                Config.DERaceSelect, currentLap, totalLaps, targetSec, minSec, totalTouchedAllLaps,
                                not refPart and "Сядьте в машину!" or "Ожидание старта / чекпоинта..."
                            )
                        )
                    end
                else
                    -- Держим машину НЕ заанкоренной (Anchored = false), чтобы сервер и Touched засчитывали каждый чекпоинт!
                    if vehicleModel then
                        DEMod.setVehicleFlightNoClip(vehicleModel, true)
                    end

                    local currentCP = cachedCpList[nextIdx]
                    local cpPart = currentCP.part

                    if activeTargetKey ~= currentCP.posKey then
                        activeTargetKey = currentCP.posKey
                        activeTargetStartTick = tick()
                        activeTargetWasActive = isCheckpointVisuallyActive(cpPart, currentCP.model)
                        passOscillationPhase = 0
                    end

                    local remainingUntakenOnLapList = {}
                    for j = nextIdx, #cachedCpList do
                        local c = cachedCpList[j]
                        if c.part and c.part.Parent and not takenCheckpointKeys[c.posKey] then
                            table.insert(remainingUntakenOnLapList, c)
                        end
                    end

                    local remainingOnLap = #remainingUntakenOnLapList
                    local isLastLap = (currentLap >= totalLaps)
                    local isLastPointOfLap = currentCP.isFinish or (remainingOnLap == 1 and touchedThisLap + 1 >= rData.cpPerLap and #cachedCpList > 1)
                    local isFinalRaceFinish = isLastLap and isLastPointOfLap

                    local ignoreList = {cpPart}
                    if char then table.insert(ignoreList, char) end
                    if vehicleModel then table.insert(ignoreList, vehicleModel) end
                    if currentCP.model then table.insert(ignoreList, currentCP.model) end
                    sharedRayParams.FilterDescendantsInstances = ignoreList

                    local hoverOffset = Config.DEHoverHeight or 6
                    local cpRoadY = getCheckpointRoadFloorY(currentCP, sharedRayParams)

                    -- При подлете ближе 32 студов к воротам плавно снижаемся прямо в центр триггера чекпоинта, чтобы гарантированно задеть хитбокс!
                    local horizDistNow = Vector2.new(cpPart.Position.X - refPart.Position.X, cpPart.Position.Z - refPart.Position.Z).Magnitude
                    local gatePassHeight = cpRoadY + cachedSeatClearance + hoverOffset
                    if horizDistNow <= 32 then
                        local centerTriggerY = math.max(cpRoadY + cachedSeatClearance + 0.6, cpPart.Position.Y)
                        gatePassHeight = math.min(gatePassHeight, centerTriggerY)
                    end

                    local targetPoint = Vector3.new(cpPart.Position.X, gatePassHeight, cpPart.Position.Z)

                    local toCpFlat = Vector3.new(targetPoint.X - refPart.Position.X, 0, targetPoint.Z - refPart.Position.Z)
                    local forwardFlat = (toCpFlat.Magnitude > 0.2) and toCpFlat.Unit or Vector3.new(refPart.CFrame.LookVector.X, 0, refPart.CFrame.LookVector.Z).Unit

                    local remainingTime = math.max(0.15, targetSec - elapsed)
                    local holdingBeforeFinish = false

                    if isFinalRaceFinish and (targetSec - elapsed) > 0.35 then
                        local holdPoint = targetPoint - (forwardFlat * 16)
                        local holdFloorY = sampleSmartRoadFloor(holdPoint.X, cpRoadY, holdPoint.Z, sharedRayParams) or cpRoadY
                        targetPoint = Vector3.new(holdPoint.X, holdFloorY + cachedSeatClearance + hoverOffset, holdPoint.Z)
                        holdingBeforeFinish = true
                    elseif not holdingBeforeFinish and horizDistNow <= 12 then
                        -- Если мы уже вплотную к воротам, совершаем сквозной проход вперед-назад на +-7 студов до подтверждения сервером!
                        passOscillationPhase = passOscillationPhase + (dt * 9.0)
                        local sweepOffset = math.sin(passOscillationPhase) * 7.5
                        targetPoint = targetPoint + (forwardFlat * sweepOffset)
                    end

                    local distToTarget = (targetPoint - refPart.Position).Magnitude
                    local distLeftOnCurrentLap = distToTarget

                    if remainingOnLap > 1 then
                        for k = 1, remainingOnLap - 1 do
                            local pA = remainingUntakenOnLapList[k].part.Position
                            local pB = remainingUntakenOnLapList[k + 1].part.Position
                            distLeftOnCurrentLap = distLeftOnCurrentLap + (pB - pA).Magnitude
                        end
                    elseif not isLastPointOfLap then
                        local cpsLeftOnLap = math.max(0, rData.cpPerLap - touchedThisLap - 1)
                        local avgSeg = rData.lapStuds / math.max(1, rData.cpPerLap)
                        distLeftOnCurrentLap = distToTarget + (cpsLeftOnLap * avgSeg)
                    end

                    local futureFullLaps = math.max(0, totalLaps - currentLap)
                    local totalRemainingRaceDist = distLeftOnCurrentLap + (futureFullLaps * rData.lapStuds)

                    local desiredSpeed = totalRemainingRaceDist / remainingTime
                    if holdingBeforeFinish then
                        desiredSpeed = math.clamp(distToTarget / math.max(0.25, (targetSec - elapsed) * 0.65), 18, 320)
                    elseif horizDistNow <= 14 then
                        desiredSpeed = math.clamp(desiredSpeed, 55, 180)
                    else
                        desiredSpeed = math.clamp(desiredSpeed, 35, 650)
                    end

                    smoothedSpeed = smoothedSpeed + (desiredSpeed - smoothedSpeed) * math.min(1, dt * 8)

                    -- Навигация вдоль дороги раз в 0.08с
                    if (tick() - lastNavTick) >= 0.08 or cachedNavDir == nil then
                        lastNavTick = tick()
                        local curGroundY = sampleSmartRoadFloor(refPart.Position.X, math.max(refPart.Position.Y, cpRoadY), refPart.Position.Z, sharedRayParams)
                        if curGroundY then
                            lastValidRoadY = curGroundY
                        end
                        local navDir, nextRoadY = computeRoadFollowingDirection(refPart.Position, targetPoint, forwardFlat, lastValidRoadY, cpRoadY, sharedRayParams)
                        cachedNavDir = navDir
                        cachedLookaheadRoadY = nextRoadY
                    end

                    local moveDir = cachedNavDir or forwardFlat
                    local dist3D = (targetPoint - refPart.Position).Magnitude
                    if dist3D <= 42 then
                        moveDir = (dist3D > 0.05) and (targetPoint - refPart.Position).Unit or forwardFlat
                    end

                    local step = math.min(dist3D, smoothedSpeed * dt)
                    local nextPos = refPart.Position + (moveDir * step)

                    -- Плавная траектория + жесткий пол над асфальтом (не падает под карту даже без Anchored!)
                    local slopeT = math.clamp(step / math.max(1, dist3D), 0, 1)
                    local interpolatedTargetY = refPart.Position.Y + (targetPoint.Y - refPart.Position.Y) * slopeT
                    local effectiveHover = (horizDistNow <= 32) and 0.6 or hoverOffset
                    local roadGuidedY = math.max(lastValidRoadY, cachedLookaheadRoadY) + cachedSeatClearance + effectiveHover
                    local desiredY = math.max(interpolatedTargetY, roadGuidedY)

                    local strictGroundFloorY = lastValidRoadY + cachedSeatClearance + 0.5
                    local smoothY = nextPos.Y + (desiredY - nextPos.Y) * math.min(1, dt * 16)
                    if smoothY < strictGroundFloorY then
                        smoothY = strictGroundFloorY
                    end
                    nextPos = Vector3.new(nextPos.X, smoothY, nextPos.Z)

                    local flatDir = Vector3.new(moveDir.X, 0, moveDir.Z)
                    if flatDir.Magnitude < 0.05 then
                        flatDir = forwardFlat
                    else
                        flatDir = flatDir.Unit
                    end
                    local targetSeatCF = CFrame.lookAt(nextPos, nextPos + flatDir, Vector3.yAxis)
                    local smoothSeatCF = refPart.CFrame:Lerp(targetSeatCF, math.min(1, dt * 14))
                    smoothSeatCF = CFrame.new(nextPos) * smoothSeatCF.Rotation

                    -- Компенсируем гравитацию в векторе скорости, чтобы неанкоренная машина летела ровно и стабильно
                    local antiGravVel = Vector3.new(0, Workspace.Gravity * dt * 0.5, 0)
                    local appliedVel = ((dist3D > 0.5) and (moveDir * smoothedSpeed) or Vector3.new(0, 0, 0)) + antiGravVel

                    if vehicleModel then
                        vehicleModel:PivotTo(smoothSeatCF * cachedSeatToPivot)
                    else
                        refPart.CFrame = smoothSeatCF
                    end

                    local physRoot = rootPart or refPart
                    physRoot.AssemblyLinearVelocity = appliedVel
                    physRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

                    -- Проверяем пересечение чекпоинта и ЖДЕМ РЕАЛЬНОГО ПОДТВЕРЖДЕНИЯ от игры!
                    local horizDistToCp = Vector2.new(cpPart.Position.X - nextPos.X, cpPart.Position.Z - nextPos.Z).Magnitude
                    local vertDiffToCp = math.abs(targetPoint.Y - nextPos.Y)
                    local maxVertAllowed = math.max(18, hoverOffset + cachedSeatClearance + 8)

                    if not holdingBeforeFinish and horizDistToCp <= 18 and vertDiffToCp <= maxVertAllowed then
                        touchCheckpointDuringFlight(currentCP, refPart, rootPart)

                        local currentBeamTarget = getActiveBeamTargetPart()
                        local beamMovedAway = (currentBeamTarget ~= nil) and (currentBeamTarget ~= cpPart) and (not currentCP.model or not currentBeamTarget:IsDescendantOf(currentCP.model))
                        local partDestroyed = (not cpPart.Parent)
                        local partMovedToNext = cpPart.Parent and ((cpPart.Position - currentCP.capturedPos).Magnitude > 12)
                        local partDeactivated = cpPart.Parent and activeTargetWasActive and (not isCheckpointVisuallyActive(cpPart, currentCP.model))
                        -- Страховочный таймаут 3.5с только если статичный декоративный объект не умеет исчезать после касания
                        local staticTimeout = (horizDistToCp <= 10) and ((tick() - activeTargetStartTick) > 3.5) and (currentBeamTarget == nil)

                        local serverConfirmed = partDestroyed or partMovedToNext or partDeactivated or beamMovedAway or staticTimeout

                        if serverConfirmed then
                            takenCheckpointKeys[currentCP.posKey] = true
                            activeTargetKey = nil
                            touchedThisLap = touchedThisLap + 1
                            totalTouchedAllLaps = totalTouchedAllLaps + 1
                            lastListRefresh = 0
                            lastNavTick = 0

                            if currentCP.isFinish then
                                if currentLap < totalLaps then
                                    currentLap = currentLap + 1
                                    touchedThisLap = 0
                                    table.clear(takenCheckpointKeys)
                                    lastListRefresh = 0
                                else
                                    local finalElapsed = tick() - runStartTime
                                    showModeHUD(
                                        "DRIVING EMPIRE • ФИНИШ!",
                                        string.format(
                                            "Трасса: <b>%s</b> (%d/%d кр.)\nИтоговый рекорд: <font color='#4ADE80'><b>%.2f сек</b></font> (Цель: %.1fс)\nВсего чекпоинтов: <b>%d</b>\n%s",
                                            Config.DERaceSelect, currentLap, totalLaps, finalElapsed, targetSec, totalTouchedAllLaps,
                                            Config.DEAutoLoop and "<font color='#38BDF8'>Авто-повтор: ожидание нового заезда...</font>" or "<font color='#9CA3AF'>Полет завершён!</font>"
                                        )
                                    )

                                    if Config.DEAutoLoop then
                                        DEMod.setVehicleFlightNoClip(vehicleModel, false)
                                        task.wait(2.5)
                                        runStartTime = tick()
                                        currentLap = 1
                                        touchedThisLap = 0
                                        totalTouchedAllLaps = 0
                                        table.clear(takenCheckpointKeys)
                                        activeTargetKey = nil
                                        lastListRefresh = 0
                                    else
                                        Config.DERecordActive = false
                                        DEMod.setVehicleFlightNoClip(vehicleModel, false)
                                        local toggleRef = tabsContainer:FindFirstChild("DERecordActive", true)
                                        local switch = toggleRef and toggleRef:FindFirstChild("Switch")
                                        local dot = switch and switch:FindFirstChild("Dot")
                                        if switch and dot then
                                            switch.BackgroundColor3 = Color3.fromRGB(45, 48, 60)
                                            dot.Position = UDim2.new(0, 2, 0.5, -4)
                                        end
                                        break
                                    end
                                end
                            end
                        end
                    end

                    if (tick() - lastHudUpdate) >= 0.25 then
                        lastHudUpdate = tick()
                        local statusLine = ""
                        if holdingBeforeFinish then
                            statusLine = "\n<font color='#FBBF24'>Выдержка времени у финиша...</font>"
                        elseif horizDistToCp <= 18 then
                            statusLine = "\n<font color='#38BDF8'>Подтверждение чекпоинта сервером...</font>"
                        end
                        showModeHUD(
                            "DRIVING EMPIRE • ПОЛЕТ НАД ДОРОГОЙ",
                            string.format(
                                "Трасса: <b>%s</b> | Круг: <font color='#38BDF8'><b>%d/%d</b></font>\nЦель: <font color='#4ADE80'><b>%.1f сек</b></font> | Прошло: <b>%.1f сек</b>\nСкорость: <font color='#FBBF24'><b>%d st/s</b></font> | До точки: <b>%dm</b>\nЧекпоинты: <b>%d</b> (%s)%s",
                                Config.DERaceSelect, currentLap, totalLaps, targetSec, elapsed, math.floor(smoothedSpeed), math.floor(horizDistToCp), totalTouchedAllLaps, currentCP.name,
                                statusLine
                            )
                        )
                    end
                end
            end

            local _, curRoot, curVeh = getVehicleData()
            DEMod.setVehicleFlightNoClip(curVeh or vehicleModel, false)
            if curRoot and curRoot.Parent then
                curRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                curRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
        end)
    end

    table.insert(threads, task.spawn(function()
        while running do
            task.wait(0.6)
            if Config.ActiveGameMode == "DrivingEmpire" and Config.DEShowCheckpointsESP and not Config.DERecordActive then
                pcall(function()
                    updateDECheckpointsESP(nil)
                end)
            end
        end
    end))

    function DEMod.buildDrivingEmpireMode(parent)
        UI.createDropdown(parent, "DERaceSelect", DERaceDropdownOrder, function(selected)
            local rData = DrivingEmpireRaces[selected] or DrivingEmpireRaces["Auto Detect"]
            Config.DERecordSeconds = rData.defaultSec
            Config.DELapsCount = 0
            UI.refreshAllTranslations()
            showModeHUD(
                "DRIVING EMPIRE • " .. selected:upper(),
                string.format(
                    "<b>%s</b>\nКругов: <b>%d</b> | %s\nРекорд WR (топ): <font color='#FBBF24'>%s</font>\nХороший результат: <font color='#4ADE80'>%s</font>\nБезопасный минимум: <font color='#38BDF8'><b>%d сек</b></font> | Выбрано: <b>%d сек</b>",
                    selected, rData.laps, rData.cpDesc, rData.wrText, rData.avgText, rData.minSec, Config.DERecordSeconds
                )
            )
        end)

        UI.createNumberInput(parent, "DERecordSeconds", 1, 3600, function()
            enforceDERecordMinimum(true)
        end)

        UI.createNumberInput(parent, "DELapsCount", 0, 20, function()
            enforceDERecordMinimum(true)
        end)

        UI.createNumberInput(parent, "DEHoverHeight", 2, 40)

        UI.createToggle(parent, "DERecordActive", function(state)
            if state then
                startDrivingEmpireRunner()
            else
                DEMod.DEActiveRunToken = DEMod.DEActiveRunToken + 1
                local _, _, curVeh = getVehicleData()
                DEMod.setVehicleFlightNoClip(curVeh, false)
            end
        end)

        UI.createToggle(parent, "DEAutoLoop")

        UI.createToggle(parent, "DEShowCheckpointsESP", function(state)
            if state then
                ensureDECheckpointListener()
                refreshDrivingEmpireCacheAsync(updateDECheckpointsESP)
            else
                DEMod.clearAllDEVisuals()
            end
        end)

        UI.createButton(parent, "DEShowTracksBtn", function()
            local lines = {"<b>🏎 СПРАВОЧНИК ГОНОК И КРУГОВ DRIVING EMPIRE:</b>\n"}
            for i = 1, 7 do
                local rName = DERaceDropdownOrder[i]
                local info = DrivingEmpireRaces[rName]
                lines[#lines + 1] = string.format(
                    "• <b>%s</b> (<b>%d кр.</b>)\n  WR: <font color='#FBBF24'>%s</font> | Норм: <font color='#4ADE80'>%s</font> | Мин: <font color='#38BDF8'><b>%dс</b></font>",
                    rName, info.laps, info.wrText, info.avgText, info.minSec
                )
            end
            showModeHUD("DRIVING EMPIRE • ТАБЛИЦА РЕКОРДОВ", table.concat(lines, "\n"))
        end)
    end

end

-----------------------------------------------------------
-- СИСТЕМА ПОМОЩНИКА ДЛЯ РЕЖИМА UNO
-----------------------------------------------------------
local UnoMod = {}
do
    local UnoVisualHighlights = {}
    local lastUnoActionTick = 0

    function UnoMod.clearAllUnoVisuals()
        for _, h in pairs(UnoVisualHighlights) do
            pcall(function() h:Destroy() end)
        end
        table.clear(UnoVisualHighlights)
    end

    local function detectCardColorName(obj)
        local attrColor = obj:GetAttribute("Color") or obj:GetAttribute("CardColor")
        if attrColor then return tostring(attrColor) end

        local n = obj.Name:lower()
        if n:find("red") or n:find("красн") then return "Red" end
        if n:find("blue") or n:find("син") then return "Blue" end
        if n:find("green") or n:find("зелен") then return "Green" end
        if n:find("yellow") or n:find("желт") then return "Yellow" end
        if n:find("wild") or n:find("black") or n:find("черн") then return "Wild" end

        if obj:IsA("GuiObject") then
            local c = obj.BackgroundColor3
            if c.R > 0.7 and c.G < 0.35 and c.B < 0.35 then return "Red" end
            if c.B > 0.7 and c.R < 0.35 and c.G < 0.45 then return "Blue" end
            if c.G > 0.65 and c.R < 0.4 and c.B < 0.4 then return "Green" end
            if c.R > 0.75 and c.G > 0.65 and c.B < 0.35 then return "Yellow" end
        end
        return nil
    end

    local function detectCardValueName(obj)
        local attrVal = obj:GetAttribute("Value") or obj:GetAttribute("Number") or obj:GetAttribute("Type")
        if attrVal then return tostring(attrVal) end

        local n = obj.Name:lower()
        if n:find("%+4") or n:find("plus4") or n:find("draw4") or n:find("wild4") then return "+4" end
        if n:find("%+2") or n:find("plus2") or n:find("draw2") then return "+2" end
        if n:find("skip") or n:find("пропуск") then return "Skip" end
        if n:find("rev") or n:find("разворот") then return "Reverse" end
        if n:find("wild") then return "Wild" end

        local digit = n:match("%d")
        if digit then return digit end

        for _, lbl in ipairs(obj:GetDescendants()) do
            if lbl:IsA("TextLabel") and lbl.Text ~= "" then
                local t = lbl.Text:gsub("%s+", "")
                if #t <= 4 then return t end
            end
        end
        return "?"
    end

    local function processUnoFastActions()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end

        local now = tick()
        for _, btn in ipairs(pg:GetDescendants()) do
            if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                local bn = btn.Name:lower()
                local bt = btn:IsA("TextButton") and btn.Text:lower() or ""

                if Config.UnoAutoUno and (now - lastUnoActionTick) > 0.25 then
                    if (bn == "uno" or bn:find("unobtn") or bn:find("uno_btn") or bn:find("sayuno") or bt == "uno" or bt == "uno!") and not bn:find("catch") and not bn:find("call") then
                        lastUnoActionTick = now
                        triggerGuiButton(btn)
                        return
                    end
                end

                if Config.UnoAutoCatch and (now - lastUnoActionTick) > 0.25 then
                    if bn:find("catch") or bn:find("callout") or bn:find("call_out") or bn:find("challenge") or bn:find("bluff")
                        or bt:find("catch") or bt:find("call out") or bt:find("challenge") or bt:find("поймать") or bt:find("проверить") then
                        lastUnoActionTick = now
                        triggerGuiButton(btn)
                        return
                    end
                end

                if Config.UnoAutoColor and (now - lastUnoActionTick) > 0.35 then
                    local parentName = btn.Parent and btn.Parent.Name:lower() or ""
                    if parentName:find("color") or parentName:find("wild") or parentName:find("choose") or bn:find("pickcolor") or bn:find("color_") then
                        local counts = {Red = 0, Blue = 0, Green = 0, Yellow = 0}
                        for _, item in ipairs(pg:GetDescendants()) do
                            if item:IsA("GuiObject") and item.Visible and item.Parent and item.Parent.Name:lower():find("hand") then
                                local col = detectCardColorName(item)
                                if col and counts[col] then
                                    counts[col] = counts[col] + 1
                                end
                            end
                        end
                        local bestColor = "Red"
                        local bestCount = -1
                        for cName, cnt in pairs(counts) do
                            if cnt > bestCount then
                                bestCount = cnt
                                bestColor = cName
                            end
                        end
                        local bCol = detectCardColorName(btn)
                        if bCol and bCol == bestColor then
                            lastUnoActionTick = now
                            triggerGuiButton(btn)
                            return
                        end
                    end
                end
            end
        end
    end

    local function scanUnoPlayersAndDeck()
        local playerInfoList = {}

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local foundCards = {}
                local cardCount = 0

                local ls = p:FindFirstChild("leaderstats")
                if ls then
                    for _, v in ipairs(ls:GetChildren()) do
                        if (v:IsA("IntValue") or v:IsA("NumberValue")) and v.Name:lower():find("card") then
                            cardCount = v.Value
                        end
                    end
                end

                local containers = {p, Workspace, ReplicatedStorage}
                for _, rootCont in ipairs(containers) do
                    for _, folder in ipairs(rootCont:GetDescendants()) do
                        if (folder:IsA("Folder") or folder:IsA("Model")) then
                            local fn = folder.Name:lower()
                            if fn:find(p.Name:lower()) or fn:find(p.DisplayName:lower()) then
                                for _, cardObj in ipairs(folder:GetChildren()) do
                                    local cn = cardObj.Name:lower()
                                    if cn:find("card") or cardObj:GetAttribute("Color") or cardObj:GetAttribute("Value") then
                                        cardCount = cardCount + 1
                                        local col = detectCardColorName(cardObj)
                                        local val = detectCardValueName(cardObj)
                                        if col or (val and val ~= "?") then
                                            local badge = string.format("[%s %s]", col or "?", val or "?")
                                            table.insert(foundCards, badge)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                table.insert(playerInfoList, {
                    name = p.DisplayName,
                    count = cardCount > 0 and cardCount or #foundCards,
                    cards = foundCards
                })
            end
        end

        return playerInfoList
    end

    local function processUnoHandHints()
        UnoMod.clearAllUnoVisuals()
        if not Config.UnoSmartHint and not Config.UnoAutoPlay then return end

        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end

        local activeColor, activeValue = nil, nil
        for _, obj in ipairs(pg:GetDescendants()) do
            if obj:IsA("GuiObject") and obj.Visible then
                local nl = obj.Name:lower()
                if nl:find("discard") or nl:find("pile") or nl:find("topcard") or nl:find("currentcard") then
                    activeColor = detectCardColorName(obj) or activeColor
                    local v = detectCardValueName(obj)
                    if v and v ~= "?" then activeValue = v end
                end
            end
        end

        local handCards = {}
        for _, obj in ipairs(pg:GetDescendants()) do
            if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.Visible then
                local pl = obj.Parent and obj.Parent.Name:lower() or ""
                local nl = obj.Name:lower()
                if pl:find("hand") or pl:find("cards") or nl:find("handcard") then
                    local col = detectCardColorName(obj)
                    local val = detectCardValueName(obj)
                    local score = 0
                    if col == "Wild" or val == "+4" or val == "Wild" then
                        score = 15
                    elseif (activeColor and col == activeColor) or (activeValue and val == activeValue) then
                        score = 50
                        if val == "+2" or val == "Skip" or val == "Reverse" then
                            score = 80
                        end
                    elseif not activeColor then
                        score = 20
                    end

                    if score > 0 then
                        table.insert(handCards, {btn = obj, score = score})
                    end
                end
            end
        end

        table.sort(handCards, function(a, b) return a.score > b.score end)

        if #handCards > 0 then
            local best = handCards[1]
            if Config.UnoSmartHint then
                local stroke = Instance.new("UIStroke")
                stroke.Name = "KrestikUnoBestHint"
                stroke.Color = Color3.fromRGB(255, 215, 0)
                stroke.Thickness = 2.5
                stroke.Parent = best.btn
                table.insert(UnoVisualHighlights, stroke)
            end

            if Config.UnoAutoPlay and (tick() - lastUnoActionTick) > 1.2 then
                lastUnoActionTick = tick()
                triggerGuiButton(best.btn)
            end
        end
    end

    table.insert(threads, task.spawn(function()
        while running do
            task.wait(0.08)
            if Config.ActiveGameMode == "UNO" and (Config.UnoAutoUno or Config.UnoAutoCatch or Config.UnoAutoColor) then
                pcall(processUnoFastActions)
            end
        end
    end))

    table.insert(threads, task.spawn(function()
        while running do
            task.wait(0.75)
            if Config.ActiveGameMode == "UNO" then
                pcall(function()
                    processUnoHandHints()

                    if Config.UnoShowCards then
                        local infoList = scanUnoPlayersAndDeck()
                        local lines = {"<b>🃏 СОПЕРНИКИ И КАРТЫ ЗА СТОЛОМ:</b>\n"}
                        if #infoList == 0 then
                            lines[#lines + 1] = "<font color='#9CA3AF'>Ожидание других игроков за столом...</font>"
                        else
                            for _, pInfo in ipairs(infoList) do
                                local unoWarn = (pInfo.count == 1) and " <font color='#F87171'><b>[1 КАРТА — ЛОВИ UNO!]</b></font>" or ""
                                if #pInfo.cards > 0 then
                                    lines[#lines + 1] = string.format(
                                        "• <b>%s</b> (%d шт.)%s\n  Карты: <font color='#38BDF8'>%s</font>",
                                        pInfo.name, pInfo.count, unoWarn, table.concat(pInfo.cards, " ")
                                    )
                                else
                                    lines[#lines + 1] = string.format(
                                        "• <b>%s</b> — карт на руках: <font color='#FBBF24'>%d</font>%s",
                                        pInfo.name, pInfo.count, unoWarn
                                    )
                                end
                            end
                        end
                        showModeHUD("UNO • ТРЕКЕР КАРТ И ИГРОКОВ", table.concat(lines, "\n"))
                    end
                end)
            end
        end
    end))

    function UnoMod.buildUNOMode(parent)
        UI.createToggle(parent, "UnoAutoUno")
        UI.createToggle(parent, "UnoAutoCatch")
        UI.createToggle(parent, "UnoAutoColor")
        UI.createToggle(parent, "UnoShowCards", function(state)
            if not state then
                modeHUD.Visible = false
            end
        end)
        UI.createToggle(parent, "UnoSmartHint", function(state)
            if not state then
                UnoMod.clearAllUnoVisuals()
            end
        end)
        UI.createToggle(parent, "UnoAutoPlay")
    end

end

-----------------------------------------------------------
-- УПРАВЛЕНИЕ ДИНАМИЧЕСКИМИ РЕЖИМАМИ ИГРЫ
-----------------------------------------------------------
local function clearDynamicTab()
    if currentDynamicTabFrame then
        currentDynamicTabFrame:Destroy()
        currentDynamicTabFrame = nil
    end

    local dynamicBtn = sidebar:FindFirstChild("TabBtn_Dynamic")
    if dynamicBtn then
        for i, btn in ipairs(UI.tabButtons) do
            if btn == dynamicBtn then
                table.remove(UI.tabButtons, i)
                break
            end
        end
        dynamicBtn:Destroy()
    end

    local filteredUI = {}
    for _, item in ipairs(UI.Elements) do
        if item.instance and item.instance.Parent then
            table.insert(filteredUI, item)
        end
    end
    UI.Elements = filteredUI

    UI.updateTabPositions()

    if UI.activeTab == "Dynamic" then
        UI.activateTabByName("Movement")
    end
end

local function setGameMode(modeName)
    clearDynamicTab()
    StealMod.disconnectStealListener()
    StealMod.clearAllStealVisuals()
    UnoMod.clearAllUnoVisuals()
    DEMod.disconnectDEListener()
    DEMod.clearAllDEVisuals()
    table.clear(DEMod.DECachedCheckpoints)
    Config.DERecordActive = false
    DEMod.DEActiveRunToken = DEMod.DEActiveRunToken + 1
    DEMod.setVehicleFlightNoClip(nil, false)
    modeHUD.Visible = false
    lastHUDTitle, lastHUDBody = "", ""

    if modeName == "None" or modeName == "Отсутствует" then
        Config.ActiveGameMode = "None"
        return
    end

    currentDynamicTabFrame = UI.createTab("Dynamic", "TabDynamic")

    if modeName == "Driving Empire" then
        Config.ActiveGameMode = "DrivingEmpire"
        DEMod.buildDrivingEmpireMode(currentDynamicTabFrame)
    elseif modeName == "Steal or Die" then
        Config.ActiveGameMode = "StealOrDie"
        StealMod.buildStealOrDieMode(currentDynamicTabFrame)
        StealMod.lastFullStealScanTick = tick()
        StealMod.scanStealOrDieMapAsync(true, StealMod.syncStealVisuals)
        StealMod.StealDescendantConn = Workspace.DescendantAdded:Connect(function(desc)
            if running and Config.ActiveGameMode == "StealOrDie" then
                task.defer(function()
                    StealMod.classifySingleStealNode(desc)
                end)
            end
        end)
    elseif modeName == "UNO" then
        Config.ActiveGameMode = "UNO"
        UnoMod.buildUNOMode(currentDynamicTabFrame)
    end

    UI.refreshAllTranslations()
    UI.activateTabByName("Dynamic")
end

do
    -- Utilities Секция
    local funTab = UI.createTab("Fun", "TabUtilities")

    UI.createToggle(funTab, "InstantInteract", function(state)
        if state then
            task.spawn(function()
                for i, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.HoldDuration > 0 then
                        prompt.HoldDuration = 0
                    end
                    if i % 500 == 0 then task.wait() end
                end
            end)
        end
    end)
    UI.createToggle(funTab, "SpinBot")
    UI.createNumberInput(funTab, "SpinSpeed", 1, 100000)
    UI.createToggle(funTab, "LowGravity")
    UI.createNumberInput(funTab, "GravityValue", 0, 100000)
    UI.createToggle(funTab, "ChatSpam")
    UI.createToggle(funTab, "JesusWalk")
    UI.createToggle(funTab, "SitSpam")
    UI.createToggle(funTab, "RagdollSelf")
    UI.createButton(funTab, "GetTpTool", function()
        pcall(function()
            local tool = Instance.new("Tool")
            tool.RequiresHandle = false
            tool.Name = "VectorWarp"
            tool.Activated:Connect(function()
                local mouse = LocalPlayer:GetMouse()
                local root = getCharacter(LocalPlayer) and getCharacter(LocalPlayer):FindFirstChild("HumanoidRootPart")
                if root and mouse and mouse.Hit then
                    root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
                end
            end)
            tool.Parent = LocalPlayer.Backpack
        end)
    end)

    table.insert(connections, ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
        if running and Config.InstantInteract and prompt and prompt.Parent then
            prompt.HoldDuration = 0
            triggerPrompt(prompt)
        end
    end))

    table.insert(connections, RunService.Heartbeat:Connect(function()
        if not running then return end
        if not Config.SpinBot and not Config.LowGravity and not Config.JesusWalk and not Config.SitSpam and not Config.RagdollSelf then
            return
        end
        pcall(function()
            local char = getCharacter(LocalPlayer)
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if Config.SpinBot and root then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Config.SpinSpeed), 0)
            end

            if Config.LowGravity then
                workspace.Gravity = Config.GravityValue
            elseif workspace.Gravity ~= 196.2 then
                workspace.Gravity = 196.2
            end

            if Config.JesusWalk and root then
                if root.Position.Y < 3 then
                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
                    root.CFrame = CFrame.new(root.Position.X, 3, root.Position.Z)
                end
            end

            if Config.SitSpam and hum then hum.Sit = not hum.Sit end
            if Config.RagdollSelf and hum then hum:ChangeState(Enum.HumanoidStateType.Physics) end
        end)
    end))

    table.insert(threads, task.spawn(function()
        while running do
            task.wait(4)
            if Config.ChatSpam then
                pcall(function()
                    local events = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                    if events then
                        events.SayMessageRequest:FireServer(Config.SpamText, "All")
                    else
                        game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(Config.SpamText)
                    end
                end)
            end
        end
    end))

end

-- System Секция
local sysTab = UI.createTab("System", "TabSystem")

UI.createDropdown(sysTab, "LangLabel", {"Русский", "English"}, function(selected)
    if selected == "Русский" then
        Config.Language = "RU"
    else
        Config.Language = "EN"
    end
    UI.refreshAllTranslations()
end)

UI.createDropdown(sysTab, "ActiveGameModeLabel", {"None", "Driving Empire", "Steal or Die", "UNO"}, function(selected)
    setGameMode(selected)
end)

UI.createToggle(sysTab, "AntiCheatBypass", function(state)
    if state then
        AC.sanitizeConnections()
        AC.grantPhysicsAuthority()
    end
end)

local acStatusFrame = Instance.new("Frame", sysTab)
acStatusFrame.Size = UDim2.new(0.98, 0, 0, 26)
acStatusFrame.BackgroundColor3 = Color3.fromRGB(22, 26, 36)
Instance.new("UICorner", acStatusFrame).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", acStatusFrame).Color = Config.BorderColor

local acStatusLabel = Instance.new("TextLabel", acStatusFrame)
acStatusLabel.Size = UDim2.new(0.94, 0, 1, 0)
acStatusLabel.Position = UDim2.new(0.03, 0, 0, 0)
acStatusLabel.BackgroundTransparency = 1
acStatusLabel.Font = Enum.Font.Code
acStatusLabel.TextSize = 9
acStatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local function updateACStatusLabel()
    if Config.AntiCheatBypass then
        acStatusLabel.Text = "🛡 " .. langStr("ACShieldStatusLabel") .. tostring(AC.BlockedCount)
        acStatusLabel.TextColor3 = Color3.fromRGB(74, 222, 128)
    else
        acStatusLabel.Text = "⚠ " .. langStr("ACShieldOffLabel")
        acStatusLabel.TextColor3 = Color3.fromRGB(248, 113, 113)
    end
end
updateACStatusLabel()
table.insert(UI.Elements, {instance = acStatusLabel, key = "ACShieldStatusLabel", updateFunc = updateACStatusLabel})

table.insert(threads, task.spawn(function()
    local lastShownCount = -1
    while running do
        task.wait(1.0)
        if lastShownCount ~= AC.BlockedCount then
            lastShownCount = AC.BlockedCount
            updateACStatusLabel()
        end
    end
end))

UI.createButton(sysTab, "ACReapplyBtn", function()
    AC.sanitizeConnections()
    AC.grantPhysicsAuthority()
    updateACStatusLabel()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "KRESTIK HUB",
        Text = "Roblox Anti-Cheat Shield обновлён!",
        Duration = 2.5
    })
end)

UI.createToggle(sysTab, "AntiAFK")

local bindFrame = Instance.new("Frame", sysTab)
bindFrame.Size = UDim2.new(0.98, 0, 0, 32)
bindFrame.BackgroundColor3 = Config.PanelColor
Instance.new("UICorner", bindFrame).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", bindFrame).Color = Config.BorderColor

local bindLabel = Instance.new("TextLabel", bindFrame)
bindLabel.Size = UDim2.new(0.5, 0, 1, 0)
bindLabel.Position = UDim2.new(0.03, 0, 0, 0)
bindLabel.TextColor3 = Color3.fromRGB(210, 215, 225)
bindLabel.Font = Enum.Font.GothamMedium
bindLabel.TextSize = 10
bindLabel.TextXAlignment = Enum.TextXAlignment.Left
bindLabel.BackgroundTransparency = 1
UI.registerText(bindLabel, "MenuBind")

local bindBtn = Instance.new("TextButton", bindFrame)
bindBtn.Size = UDim2.new(0, 125, 0, 18)
bindBtn.Position = UDim2.new(0.97, -125, 0.5, -9)
bindBtn.BackgroundColor3 = Config.BGColor
bindBtn.Text = currentBind.Name
bindBtn.TextColor3 = Config.ThemeAccent
bindBtn.Font = Enum.Font.GothamBold
bindBtn.TextSize = 9
Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 3)
Instance.new("UIStroke", bindBtn).Color = Config.BorderColor

local isConfiguringMenuBind = false
bindBtn.MouseButton1Click:Connect(function()
    playClickSound()
    isConfiguringMenuBind = true
    bindBtn.Text = "..."
end)

table.insert(connections, UserInputService.InputBegan:Connect(function(input, gpe)
    if isConfiguringMenuBind and not gpe then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            currentBind = input.KeyCode
            bindBtn.Text = currentBind.Name
            isConfiguringMenuBind = false
        end
    end
end))

UI.createButton(sysTab, "FpsBoost", function()
    task.spawn(function()
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
        local descendants = Workspace:GetDescendants()
        for i = 1, #descendants do
            local obj = descendants[i]
            if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                pcall(function() obj:Destroy() end)
            elseif obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.CastShadow = false
            end
            if i % 500 == 0 then task.wait() end
        end
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "KRESTIK HUB",
            Text = "Ultra FPS Boost применён!",
            Duration = 3
        })
    end)
end)

UI.createButton(sysTab, "Discord", function()
    pcall(function() setclipboard("https://discord.gg/krestikhub") end)
end)

local killBtnFrame = Instance.new("Frame", sysTab)
killBtnFrame.Size = UDim2.new(0, 420, 0, 32)
killBtnFrame.BackgroundTransparency = 1

local killBtn = Instance.new("TextButton", killBtnFrame)
killBtn.Size = UDim2.new(1, 0, 1, 0)
killBtn.BackgroundColor3 = Color3.fromRGB(45, 25, 30)
killBtn.TextColor3 = Color3.fromRGB(240, 90, 90)
killBtn.Font = Enum.Font.GothamBold
killBtn.TextSize = 10
Instance.new("UICorner", killBtn).CornerRadius = UDim.new(0, 4)
local killStroke = Instance.new("UIStroke", killBtn)
killStroke.Color = Config.BorderColor

UI.registerText(killBtn, "Unload")

killBtn.MouseEnter:Connect(function()
    killBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 35)
end)
killBtn.MouseLeave:Connect(function()
    killBtn.BackgroundColor3 = Color3.fromRGB(45, 25, 30)
end)

local function unloadHubCleanly()
    running = false

    StealMod.disconnectStealListener()
    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end

    pcall(function()
        restoreOriginalCollisions()
        StealMod.clearAllStealVisuals()
        UnoMod.clearAllUnoVisuals()
        DEMod.disconnectDEListener()
        DEMod.clearAllDEVisuals()
        DEMod.DEActiveRunToken = DEMod.DEActiveRunToken + 1
        DEMod.setVehicleFlightNoClip(nil, false)
        for p, _ in pairs(PlayerESPRegistry) do
            destroyPlayerESP(p)
        end
        for seat, orig in pairs(OriginalSeatStats) do
            if seat and seat.Parent and seat:IsA("VehicleSeat") then
                seat.MaxSpeed = orig.MaxSpeed
                seat.Torque = orig.Torque
            end
        end
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        Lighting.Ambient = OriginalLighting.Ambient
    end)

    pcall(function()
        EspContainer:Destroy()
    end)

    workspace.Gravity = 196.2
    pcall(function() gui:Destroy() end)
end

pcall(function()
    local env = (getgenv and getgenv()) or _G
    if env then
        env._KrestikHubCleanup = unloadHubCleanly
    end
end)

killBtn.MouseButton1Click:Connect(function()
    playClickSound()
    unloadHubCleanly()
end)



do
    -----------------------------------------------------------
    -- МОДУЛЬ ПРОВЕРКИ, ГЕНЕРАЦИИ И СИНХРОНИЗАЦИИ КЛЮЧЕЙ (GITHUB + LOCAL)
    -----------------------------------------------------------
    local ActiveKeyInfo = {
        key = "NONE",
        label = "Без ключа",
        expiresAt = 0,
        isAdmin = false
    }

    local KeyGenState = {
        CategoryPreset = "VIP (7 дней)",
        CustomLabel = "",
        DurationHours = 168,
        Amount = 1,
        TargetUserId = 0,
        GitHubToken = ""
    }

    local KeyCategoryPresets = {
        ["Free (24 часа)"]        = { hours = 24,      label = "Free (24 часа)" },
        ["Start (3 дня)"]         = { hours = 72,      label = "Start (3 дня)" },
        ["VIP (7 дней)"]          = { hours = 168,     label = "VIP (7 дней)" },
        ["PRO (30 дней)"]         = { hours = 720,     label = "PRO (30 дней)" },
        ["Lifetime (Навсегда)"]   = { hours = 0,       label = "Lifetime (Навсегда)" },
        ["Custom (Своя)"]         = { hours = 24,      label = "Custom" }
    }

    local KeyCategoryDropdownOrder = {
        "Free (24 часа)",
        "Start (3 дня)",
        "VIP (7 дней)",
        "PRO (30 дней)",
        "Lifetime (Навсегда)",
        "Custom (Своя)"
    }

    -- Генератор ключей строго в формате KRESTIK-........... (11 случайных символов)
    local function generateFormattedKrestikKey()
        local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        local chars = table.create(11)
        for i = 1, 11 do
            local idx = math.random(1, #alphabet)
            chars[i] = alphabet:sub(idx, idx)
        end
        return "KRESTIK-" .. table.concat(chars)
    end

    local function formatRemainingKeyTime(expiresAt)
        if not expiresAt or expiresAt <= 0 then
            return "Навсегда (Lifetime)"
        end
        local rem = math.max(0, expiresAt - os.time())
        local days = math.floor(rem / 86400)
        local hours = math.floor((rem % 86400) / 3600)
        local mins = math.floor((rem % 3600) / 60)
        if days > 0 then
            return string.format("%dд %dч %dм", days, hours, mins)
        elseif hours > 0 then
            return string.format("%dч %dм", hours, mins)
        else
            return string.format("%d мин", math.max(1, mins))
        end
    end

    local function saveKeyRecord(keyStr, activatedAt)
        if not KeySystemConfig.SaveKey then return end
        local payload = HttpService:JSONEncode({
            key = keyStr,
            activatedAt = activatedAt
        })
        pcall(function()
            local env = (getgenv and getgenv()) or _G
            if env then
                env._KrestikSavedKeyPayload = payload
            end
        end)
        if writefile then
            pcall(function()
                writefile(KeySystemConfig.SaveFileName, payload)
            end)
        end
    end

    local function loadKeyRecord()
        if not KeySystemConfig.SaveKey then return nil end
        local raw = nil
        pcall(function()
            local env = (getgenv and getgenv()) or _G
            if env and type(env._KrestikSavedKeyPayload) == "string" then
                raw = env._KrestikSavedKeyPayload
            end
        end)
        if not raw and readfile and isfile then
            pcall(function()
                if isfile(KeySystemConfig.SaveFileName) then
                    raw = readfile(KeySystemConfig.SaveFileName)
                end
            end)
        end
        if raw and raw ~= "" then
            local ok, decoded = pcall(function()
                return HttpService:JSONDecode(raw)
            end)
            if ok and type(decoded) == "table" and decoded.key then
                return decoded
            end
        end
        return nil
    end

    local function clearSavedKeyRecord()
        pcall(function()
            local env = (getgenv and getgenv()) or _G
            if env then
                env._KrestikSavedKeyPayload = nil
            end
        end)
        if delfile and isfile then
            pcall(function()
                if isfile(KeySystemConfig.SaveFileName) then
                    delfile(KeySystemConfig.SaveFileName)
                end
            end)
        elseif writefile then
            pcall(function()
                writefile(KeySystemConfig.SaveFileName, "")
            end)
        end
    end

    local function loadSavedGitHubToken()
        local tok = ""
        if readfile and isfile then
            pcall(function()
                if isfile(KeySystemConfig.GitHubTokenFile) then
                    tok = tostring(readfile(KeySystemConfig.GitHubTokenFile) or ""):gsub("%s+", "")
                end
            end)
        end
        KeyGenState.GitHubToken = tok
        return tok
    end

    local function saveGitHubToken(tok)
        local clean = tostring(tok or ""):gsub("%s+", "")
        KeyGenState.GitHubToken = clean
        if writefile then
            pcall(function()
                writefile(KeySystemConfig.GitHubTokenFile, clean)
            end)
        end
    end

    loadSavedGitHubToken()

    local function fetchRemoteKeysMap()
        if not KeySystemConfig.RemoteKeysUrl or KeySystemConfig.RemoteKeysUrl == "" then
            return nil
        end
        local sep = KeySystemConfig.RemoteKeysUrl:find("?") and "&" or "?"
        local urlWithBust = KeySystemConfig.RemoteKeysUrl .. sep .. "t=" .. tostring(os.time())
        local okHttp, body = pcall(function()
            return game:HttpGet(urlWithBust, true)
        end)
        if okHttp and body and body ~= "" then
            local okJson, remoteTable = pcall(function()
                return HttpService:JSONDecode(body)
            end)
            if okJson and type(remoteTable) == "table" then
                return remoteTable.keys or remoteTable
            end
        end
        return nil
    end

    local function verifyKeyAccess(inputKey, existingActivatedAt)
        local cleanKey = tostring(inputKey or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if cleanKey == "" then
            return false, "Введите ключ!"
        end

        -- Сначала проверяем удалённую базу GitHub (чтобы отзыв или изменение срока срабатывали мгновенно)
        local keyEntry = nil
        local remoteMap = fetchRemoteKeysMap()
        if type(remoteMap) == "table" and type(remoteMap[cleanKey]) == "table" then
            keyEntry = remoteMap[cleanKey]
        end

        -- Если в удалённой базе нет (или нет интернета к GitHub), проверяем локальный список
        if not keyEntry then
            keyEntry = KeySystemConfig.LocalKeys[cleanKey]
        end

        if type(keyEntry) ~= "table" then
            return false, "Неверный ключ доступа!"
        end

        if keyEntry.revoked then
            return false, "Этот ключ был отозван!"
        end

        if keyEntry.userId and tonumber(keyEntry.userId) and tonumber(keyEntry.userId) > 0 and tonumber(keyEntry.userId) ~= LocalPlayer.UserId then
            return false, "Ключ привязан к другому аккаунту Roblox!"
        end

        local now = os.time()
        local activatedAt = tonumber(existingActivatedAt) or now
        local expiresAt = 0

        if keyEntry.expiresAt and tonumber(keyEntry.expiresAt) and tonumber(keyEntry.expiresAt) > 0 then
            expiresAt = tonumber(keyEntry.expiresAt)
        elseif keyEntry.durationHours and tonumber(keyEntry.durationHours) and tonumber(keyEntry.durationHours) > 0 then
            expiresAt = activatedAt + math.floor(tonumber(keyEntry.durationHours) * 3600)
        end

        if expiresAt > 0 and now >= expiresAt then
            clearSavedKeyRecord()
            return false, "Срок действия ключа истёк! Получите новый."
        end

        saveKeyRecord(cleanKey, activatedAt)
        ActiveKeyInfo = {
            key = cleanKey,
            label = keyEntry.label or "Active Key",
            expiresAt = expiresAt,
            isAdmin = keyEntry.isAdmin == true
        }
        return true, "Успешно! Осталось: " .. formatRemainingKeyTime(expiresAt)
    end

    -- Base64 кодировщик для прямой заливки keys.json в GitHub API без внешних библиотек
    local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local function base64Encode(data)
        return ((data:gsub(".", function(x)
            local r, b = "", x:byte()
            for i = 8, 1, -1 do
                r = r .. (b % 2^i - b % 2^(i - 1) > 0 and "1" or "0")
            end
            return r
        end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
            if #x < 6 then return "" end
            local c = 0
            for i = 1, 6 do
                c = c + (x:sub(i, i) == "1" and 2^(6 - i) or 0)
            end
            return b64chars:sub(c + 1, c + 1)
        end) .. ({ "", "==", "=" })[#data % 3 + 1])
    end

    local function generateKeysBatchFromUI()
        local preset = KeyCategoryPresets[KeyGenState.CategoryPreset] or KeyCategoryPresets["VIP (7 дней)"]
        local finalLabel = (KeyGenState.CustomLabel ~= "" and KeyGenState.CustomLabel) or preset.label
        local hours = tonumber(KeyGenState.DurationHours)
        if hours == nil then
            hours = preset.hours
        end
        hours = math.max(0, math.floor(hours))

        local count = math.clamp(math.floor(tonumber(KeyGenState.Amount) or 1), 1, 50)
        local targetUid = math.max(0, math.floor(tonumber(KeyGenState.TargetUserId) or 0))

        local generatedList = {}
        local jsonLines = {}

        for i = 1, count do
            local k = generateFormattedKrestikKey()
            local entryObj = {
                durationHours = hours,
                label = finalLabel
            }
            if targetUid > 0 then
                entryObj.userId = targetUid
            end

            -- Сразу добавляем в оперативную память текущей сессии, чтобы ключ работал мгновенно
            KeySystemConfig.LocalKeys[k] = entryObj
            table.insert(generatedList, { key = k, data = entryObj })

            if targetUid > 0 then
                table.insert(jsonLines, string.format('  "%s": { "durationHours": %d, "userId": %d, "label": %q }', k, hours, targetUid, finalLabel))
            else
                table.insert(jsonLines, string.format('  "%s": { "durationHours": %d, "label": %q }', k, hours, finalLabel))
            end
        end

        return generatedList, table.concat(jsonLines, ",\n"), finalLabel, hours
    end

    local function pushGeneratedKeysToGitHub(generatedList)
        local httpReq = (syn and syn.request) or (http and http.request) or http_request or request
        if not httpReq then
            return false, "Экзекутор не поддерживает HTTP-запросы (request). Используйте копирование JSON."
        end
        local token = KeyGenState.GitHubToken
        if not token or token == "" then
            return false, "Укажите GitHub Token в поле выше!"
        end

        local apiUrl = string.format(
            "https://api.github.com/repos/%s/%s/contents/%s",
            KeySystemConfig.GitHubRepoOwner,
            KeySystemConfig.GitHubRepoName,
            KeySystemConfig.GitHubFilePath
        )

        local headers = {
            ["Authorization"] = "Bearer " .. token,
            ["Accept"] = "application/vnd.github+json",
            ["User-Agent"] = "KrestikHub-KeyManager",
            ["Content-Type"] = "application/json"
        }

        -- 1. Получаем текущий keys.json и его SHA
        local getResp = httpReq({
            Url = apiUrl,
            Method = "GET",
            Headers = headers
        })

        local currentSha = nil
        local keysDatabase = {}

        if getResp and getResp.StatusCode == 200 and getResp.Body then
            local okMeta, metaJson = pcall(function()
                return HttpService:JSONDecode(getResp.Body)
            end)
            if okMeta and type(metaJson) == "table" then
                currentSha = metaJson.sha
                local rawRemote = fetchRemoteKeysMap()
                if type(rawRemote) == "table" then
                    keysDatabase = rawRemote
                end
            end
        elseif getResp and getResp.StatusCode ~= 404 then
            return false, "Ошибка GitHub GET: HTTP " .. tostring(getResp and getResp.StatusCode or "nil")
        end

        -- 2. Добавляем новые ключи
        for _, item in ipairs(generatedList) do
            keysDatabase[item.key] = item.data
        end

        -- 3. Формируем красивый отформатированный JSON
        local formattedEntries = {}
        for k, info in pairs(keysDatabase) do
            if type(info) == "table" then
                local parts = {
                    string.format('"durationHours": %d', tonumber(info.durationHours) or 0),
                    string.format('"label": %q', tostring(info.label or "Key"))
                }
                if info.userId and tonumber(info.userId) and tonumber(info.userId) > 0 then
                    table.insert(parts, string.format('"userId": %d', tonumber(info.userId)))
                end
                if info.revoked then
                    table.insert(parts, '"revoked": true')
                end
                if info.isAdmin then
                    table.insert(parts, '"isAdmin": true')
                end
                table.insert(formattedEntries, string.format('  %q: { %s }', tostring(k), table.concat(parts, ", ")))
            end
        end
        table.sort(formattedEntries)
        local finalJsonText = "{\n" .. table.concat(formattedEntries, ",\n") .. "\n}\n"

        local putPayload = {
            message = string.format("Add %d key(s) via Krestik Hub Key Generator", #generatedList),
            content = base64Encode(finalJsonText)
        }
        if currentSha then
            putPayload.sha = currentSha
        end

        local putResp = httpReq({
            Url = apiUrl,
            Method = "PUT",
            Headers = headers,
            Body = HttpService:JSONEncode(putPayload)
        })

        if putResp and (putResp.StatusCode == 200 or putResp.StatusCode == 201) then
            return true, "Ключи успешно залиты в GitHub keys.json!"
        else
            return false, "Ошибка GitHub PUT: HTTP " .. tostring(putResp and putResp.StatusCode or "nil")
        end
    end

    -- Блок статуса лицензии и полноценный Генератор Ключей во вкладке «Система»
    local keyStatusFrame = Instance.new("Frame", sysTab)
    keyStatusFrame.Size = UDim2.new(0.98, 0, 0, 28)
    keyStatusFrame.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
    Instance.new("UICorner", keyStatusFrame).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", keyStatusFrame).Color = Config.BorderColor

    local keyStatusLabel = Instance.new("TextLabel", keyStatusFrame)
    keyStatusLabel.Size = UDim2.new(0.94, 0, 1, 0)
    keyStatusLabel.Position = UDim2.new(0.03, 0, 0, 0)
    keyStatusLabel.BackgroundTransparency = 1
    keyStatusLabel.Font = Enum.Font.Code
    keyStatusLabel.TextSize = 9
    keyStatusLabel.TextColor3 = Color3.fromRGB(165, 180, 252)
    keyStatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    local function updateKeyLicenseHUD()
        keyStatusLabel.Text = string.format("🔑 %s | %s", ActiveKeyInfo.label, formatRemainingKeyTime(ActiveKeyInfo.expiresAt))
    end
    updateKeyLicenseHUD()

    UI.createButton(sysTab, "KeyResetBtn", function()
        clearSavedKeyRecord()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "KRESTIK HUB",
            Text = "Сохранённый ключ удалён. При следующем запуске потребуется ввод ключа.",
            Duration = 4
        })
    end)

    -- Конструктор ключей под свои категории (формат KRESTIK-...........)
    Config.KeyGenCategory = KeyGenState.CategoryPreset
    Config.KeyGenHours = KeyGenState.DurationHours
    Config.KeyGenAmount = KeyGenState.Amount
    Config.KeyGenUserId = KeyGenState.TargetUserId

    UI.createDropdown(sysTab, "KeyGenCategory", KeyCategoryDropdownOrder, function(selected)
        KeyGenState.CategoryPreset = selected
        local p = KeyCategoryPresets[selected]
        if p then
            KeyGenState.DurationHours = p.hours
            Config.KeyGenHours = p.hours
            UI.refreshAllTranslations()
        end
    end)

    UI.createTextBox(sysTab, "KeyGenCustomLabel", "KeyGenCustomLabelPh", function(text)
        KeyGenState.CustomLabel = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
    end)

    UI.createNumberInput(sysTab, "KeyGenHours", 0, 87600, function(val)
        KeyGenState.DurationHours = val
    end)

    UI.createNumberInput(sysTab, "KeyGenAmount", 1, 50, function(val)
        KeyGenState.Amount = val
    end)

    UI.createNumberInput(sysTab, "KeyGenUserId", 0, 999999999999, function(val)
        KeyGenState.TargetUserId = val
    end)

    UI.createButton(sysTab, "KeyGenCopyJsonBtn", function()
        local genList, jsonSnippet, labelUsed, hoursUsed = generateKeysBatchFromUI()
        local plainKeys = {}
        for _, item in ipairs(genList) do
            table.insert(plainKeys, item.key)
        end

        pcall(function()
            if setclipboard then
                setclipboard(jsonSnippet)
            end
        end)

        local hudLines = {
            string.format("<b>Категория:</b> <font color='#FBBF24'>%s</font> (%s)", labelUsed, hoursUsed == 0 and "Навсегда" or (hoursUsed .. " ч.")),
            "<b>JSON для keys.json скопирован в буфер!</b>\n",
            "<b>Созданные ключи (формат KRESTIK-...........):</b>"
        }
        for i, k in ipairs(plainKeys) do
            hudLines[#hudLines + 1] = string.format("%d. <font color='#4ADE80'><b>%s</b></font>", i, k)
        end
        showModeHUD("KRESTIK KEY GENERATOR", table.concat(hudLines, "\n"))

        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "KRESTIK KEY GEN",
            Text = string.format("Создано %d ключ(ей)!\nПервый: %s\nJSON скопирован для keys.json", #plainKeys, plainKeys[1] or ""),
            Duration = 5
        })
    end)

    UI.createTextBox(sysTab, "KeyGenGitHubToken", "KeyGenGitHubTokenPh", function(text)
        saveGitHubToken(text)
    end)

    UI.createButton(sysTab, "KeyGenPushGitHubBtn", function()
        local genList, jsonSnippet, labelUsed, hoursUsed = generateKeysBatchFromUI()
        local plainKeys = {}
        for _, item in ipairs(genList) do
            table.insert(plainKeys, item.key)
        end

        task.spawn(function()
            local okPush, statusMsg = pushGeneratedKeysToGitHub(genList)
            if okPush then
                pcall(function()
                    if setclipboard then
                        setclipboard(table.concat(plainKeys, "\n"))
                    end
                end)
                local hudLines = {
                    "<font color='#4ADE80'><b>✔ Успешно загружено в GitHub keys.json!</b></font>",
                    string.format("<b>Категория:</b> %s (%s)", labelUsed, hoursUsed == 0 and "Навсегда" or (hoursUsed .. " ч.")),
                    "<b>Сами ключи скопированы в буфер для выдачи:</b>\n"
                }
                for i, k in ipairs(plainKeys) do
                    hudLines[#hudLines + 1] = string.format("%d. <font color='#38BDF8'><b>%s</b></font>", i, k)
                end
                showModeHUD("GITHUB KEYS.JSON ОБНОВЛЁН", table.concat(hudLines, "\n"))
            else
                pcall(function()
                    if setclipboard then
                        setclipboard(jsonSnippet)
                    end
                end)
                showModeHUD(
                    "GITHUB PUSH • ИНФО",
                    string.format(
                        "<font color='#F87171'>%s</font>\n\n<b>JSON ключей скопирован в буфер вручную:</b>\n<font color='#4ADE80'>%s</font>",
                        statusMsg, plainKeys[1] or ""
                    )
                )
            end

            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "KRESTIK GITHUB SYNC",
                Text = statusMsg,
                Duration = 4
            })
        end)
    end)

    -- Инициализация проверки ключа при запуске
    local function unlockMainHubUI()
        UI.isKeyAuthenticated = true
        menuOpen = true
        mainFrame.Visible = true
        updateKeyLicenseHUD()
        UI.activateTabByName("Movement")
        UI.refreshAllTranslations()
    end

    if not KeySystemConfig.Enabled then
        ActiveKeyInfo = { key = "DISABLED", label = "Key System Off", expiresAt = 0, isAdmin = true }
        unlockMainHubUI()
    else
        local savedRec = loadKeyRecord()
        local autoOk = false
        if savedRec then
            autoOk = verifyKeyAccess(savedRec.key, savedRec.activatedAt)
        end

        if autoOk then
            unlockMainHubUI()
        else
            mainFrame.Visible = false
            menuOpen = false

            local keyFrame = Instance.new("Frame", gui)
            keyFrame.Size = UDim2.new(0, 390, 0, 215)
            keyFrame.Position = UDim2.new(0.5, -195, 0.5, -107)
            keyFrame.BackgroundColor3 = Config.BGColor
            keyFrame.BorderSizePixel = 0
            keyFrame.Active = true
            Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 6)
            local kStroke = Instance.new("UIStroke", keyFrame)
            kStroke.Color = Config.ThemeColor
            kStroke.Thickness = 1.2

            local kTop = Instance.new("Frame", keyFrame)
            kTop.Size = UDim2.new(1, 0, 0, 34)
            kTop.BackgroundColor3 = Color3.fromRGB(18, 19, 24)
            kTop.BorderSizePixel = 0
            Instance.new("UICorner", kTop).CornerRadius = UDim.new(0, 6)
            UI.makeDraggable(kTop, keyFrame)

            local kTitle = Instance.new("TextLabel", kTop)
            kTitle.Size = UDim2.new(0.8, 0, 1, 0)
            kTitle.Position = UDim2.new(0.04, 0, 0, 0)
            kTitle.BackgroundTransparency = 1
            kTitle.Text = "🔐 KRESTIK HUB V0.9 • KEY SYSTEM"
            kTitle.TextColor3 = Color3.fromRGB(240, 242, 245)
            kTitle.Font = Enum.Font.GothamBold
            kTitle.TextSize = 11
            kTitle.TextXAlignment = Enum.TextXAlignment.Left

            local kClose = Instance.new("TextButton", kTop)
            kClose.Size = UDim2.new(0, 22, 0, 22)
            kClose.Position = UDim2.new(1, -28, 0.5, -11)
            kClose.BackgroundColor3 = Config.PanelColor
            kClose.Text = "✕"
            kClose.TextColor3 = Color3.fromRGB(180, 185, 200)
            kClose.Font = Enum.Font.GothamBold
            kClose.TextSize = 10
            Instance.new("UICorner", kClose).CornerRadius = UDim.new(0, 4)
            kClose.MouseButton1Click:Connect(function()
                playClickSound()
                unloadHubCleanly()
            end)

            local kDesc = Instance.new("TextLabel", keyFrame)
            kDesc.Size = UDim2.new(0.92, 0, 0, 32)
            kDesc.Position = UDim2.new(0.04, 0, 0, 42)
            kDesc.BackgroundTransparency = 1
            kDesc.Text = "Введите ключ активации для доступа к Krestik Hub.\nНажмите «Получить ключ», чтобы скопировать ссылку."
            kDesc.TextColor3 = Color3.fromRGB(175, 182, 198)
            kDesc.Font = Enum.Font.Gotham
            kDesc.TextSize = 10
            kDesc.TextWrapped = true
            kDesc.TextXAlignment = Enum.TextXAlignment.Left

            local kInput = Instance.new("TextBox", keyFrame)
            kInput.Size = UDim2.new(0.92, 0, 0, 32)
            kInput.Position = UDim2.new(0.04, 0, 0, 82)
            kInput.BackgroundColor3 = Config.PanelColor
            kInput.PlaceholderText = "Вставьте ключ (например: KRESTIK-XXXXXXXXXXX)"
            kInput.PlaceholderColor3 = Color3.fromRGB(115, 120, 138)
            kInput.Text = ""
            kInput.TextColor3 = Color3.fromRGB(240, 244, 255)
            kInput.Font = Enum.Font.Code
            kInput.TextSize = 11
            kInput.ClearTextOnFocus = false
            Instance.new("UICorner", kInput).CornerRadius = UDim.new(0, 4)
            local kInputStroke = Instance.new("UIStroke", kInput)
            kInputStroke.Color = Config.BorderColor

            local kStatus = Instance.new("TextLabel", keyFrame)
            kStatus.Size = UDim2.new(0.92, 0, 0, 22)
            kStatus.Position = UDim2.new(0.04, 0, 0, 120)
            kStatus.BackgroundTransparency = 1
            kStatus.Text = "Статус: Ожидание ввода ключа..."
            kStatus.TextColor3 = Color3.fromRGB(150, 156, 175)
            kStatus.Font = Enum.Font.GothamMedium
            kStatus.TextSize = 10
            kStatus.TextXAlignment = Enum.TextXAlignment.Left

            local kCheckBtn = Instance.new("TextButton", keyFrame)
            kCheckBtn.Size = UDim2.new(0.44, 0, 0, 32)
            kCheckBtn.Position = UDim2.new(0.04, 0, 0, 152)
            kCheckBtn.BackgroundColor3 = Config.ThemeColor
            kCheckBtn.Text = "✔ Проверить ключ"
            kCheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            kCheckBtn.Font = Enum.Font.GothamBold
            kCheckBtn.TextSize = 10
            Instance.new("UICorner", kCheckBtn).CornerRadius = UDim.new(0, 4)

            local kGetBtn = Instance.new("TextButton", keyFrame)
            kGetBtn.Size = UDim2.new(0.44, 0, 0, 32)
            kGetBtn.Position = UDim2.new(0.52, 0, 0, 152)
            kGetBtn.BackgroundColor3 = Config.PanelColor
            kGetBtn.Text = "🔗 Получить ключ"
            kGetBtn.TextColor3 = Color3.fromRGB(220, 225, 235)
            kGetBtn.Font = Enum.Font.GothamBold
            kGetBtn.TextSize = 10
            Instance.new("UICorner", kGetBtn).CornerRadius = UDim.new(0, 4)
            Instance.new("UIStroke", kGetBtn).Color = Config.BorderColor

            kGetBtn.MouseButton1Click:Connect(function()
                playClickSound()
                pcall(function()
                    if setclipboard then
                        setclipboard(KeySystemConfig.GetKeyLink)
                    end
                end)
                kStatus.Text = "Ссылка скопирована! Вставьте её в браузер."
                kStatus.TextColor3 = Color3.fromRGB(56, 189, 248)
            end)

            local isCheckingKey = false
            local function submitKeyCheck()
                if isCheckingKey then return end
                isCheckingKey = true
                kStatus.Text = "Проверка ключа..."
                kStatus.TextColor3 = Color3.fromRGB(251, 191, 36)

                task.spawn(function()
                    local ok, msg = verifyKeyAccess(kInput.Text, nil)
                    if ok then
                        kStatus.Text = msg
                        kStatus.TextColor3 = Color3.fromRGB(74, 222, 128)
                        task.wait(0.6)
                        if keyFrame and keyFrame.Parent then
                            keyFrame:Destroy()
                        end
                        unlockMainHubUI()
                    else
                        kStatus.Text = "✖ " .. tostring(msg)
                        kStatus.TextColor3 = Color3.fromRGB(248, 113, 113)
                        kInputStroke.Color = Color3.fromRGB(248, 113, 113)
                        task.wait(0.8)
                        if kInputStroke and kInputStroke.Parent then
                            kInputStroke.Color = Config.BorderColor
                        end
                    end
                    isCheckingKey = false
                end)
            end

            kCheckBtn.MouseButton1Click:Connect(function()
                playClickSound()
                submitKeyCheck()
            end)

            kInput.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    submitKeyCheck()
                end
            end)
        end
    end

end

table.insert(connections, LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK and running then
        pcall(function()
            local virtualUser = game:GetService("VirtualUser")
            virtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            task.wait(0.2)
            virtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        end)
    end
end))

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "KRESTIK HUB",
        Text = "Krestik Hub V0.9 loaded.\nPress Right Shift to toggle GUI.",
        Duration = 5
    })
end)
