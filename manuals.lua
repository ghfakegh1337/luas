-- keybinds / бинды
local STATES = {
    z = 90,    -- крутит влево на кнопку Z
    c = -90,   -- крутит вправо на кнопку C
    x = 0,     -- разворот вперед на кнопку X
    default = 180 -- стандартное значение
}

-- indicator settings / настройки индикатора
local ENABLE_INDICATOR = true                  -- включить индикатор, true/false
local ACTIVE_COLOR = color_t(0.72, 0.76, 1, 1) -- цвет индикатора
local INACTIVE_COLOR = color_t(0, 0, 0, 0.4)   -- цвет индикатора когда отключен
local INDICATOR_DISTANCE = 40                  -- расстояние от центра экрана, px

ffi.cdef [[
    unsigned short GetAsyncKeyState(int vKey);
]]

local function is_key_pressed(virtualKey)
    return bit.band(ffi.C.GetAsyncKeyState(virtualKey), 32768) == 32768
end

local keys = {
    z = 0x5A, -- Клавиша Z
    c = 0x43, -- Клавиша C
    x = 0x58  -- Клавиша X
}

local held_keys_cache = {}
local current_yaw = STATES["default"]

register_callback("paint", function()
    -- Обработка нажатий клавиш для изменения угла
    for k, v in pairs(STATES) do
        if k == "default" then
            goto continue
        end

        local is_key_held = is_key_pressed(keys[k] or error("Key doesn't exist: " .. k))

        if (not held_keys_cache[k]) and is_key_held then
            -- Если клавиша была нажата, меняем угол
            if current_yaw == v then
                current_yaw = STATES["default"]
            else
                current_yaw = v
            end
        end

        held_keys_cache[k] = is_key_held

        ::continue::
    end

    -- Рендеринг индикаторов
    if ENABLE_INDICATOR then
        local local_player = entitylist.get_local_player_pawn()
        if not local_player then return end

        local screen_center = vec2_t(
            render.screen_size().x / 2,
            render.screen_size().y / 2
        )

        -- Индикатор слева (левый угол)
        render.filled_polygon(
            {
                vec2_t(screen_center.x - (INDICATOR_DISTANCE), screen_center.y - 9),
                vec2_t(screen_center.x - (INDICATOR_DISTANCE), screen_center.y + 9),
                vec2_t(screen_center.x - (INDICATOR_DISTANCE + 15), screen_center.y)
            },
            current_yaw == STATES.z and ACTIVE_COLOR or INACTIVE_COLOR
        )

        -- Индикатор справа (правый угол)
        render.filled_polygon(
            {
                vec2_t(screen_center.x + (INDICATOR_DISTANCE), screen_center.y - 9),
                vec2_t(screen_center.x + (INDICATOR_DISTANCE), screen_center.y + 9),
                vec2_t(screen_center.x + (INDICATOR_DISTANCE + 15), screen_center.y)
            },
            current_yaw == STATES.c and ACTIVE_COLOR or INACTIVE_COLOR
        )

        -- Индикатор снизу (для X)
        render.filled_polygon(
            {
                vec2_t(screen_center.x - 9, screen_center.y + INDICATOR_DISTANCE),
                vec2_t(screen_center.x + 9, screen_center.y + INDICATOR_DISTANCE),
                vec2_t(screen_center.x, screen_center.y + (INDICATOR_DISTANCE + 15))
            },
            current_yaw == STATES.x and ACTIVE_COLOR or INACTIVE_COLOR
        )
    end

    -- Установка значения угла для anti-aim
    menu.ragebot_anti_aim_base_yaw_offset = current_yaw
end)

-- Сброс состояния при выгрузке скрипта
register_callback("unload", function()
    menu.ragebot_anti_aim_base_yaw_offset = STATES["default"]
end)
