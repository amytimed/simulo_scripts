local ground = Scene:reset();

ground.color = 0x6d8b59;
ground:set_position(ground:get_position() + vec2(0, 0.125));
Scene.background_color = 0x1a1828;

ground:set_restitution(0);
ground:set_friction(1);

--[[
local player = Scene:add_box({
    name = "player_100",
    position = vec2(0, -10 + (0.9 * 0.5) + 0.125),
    size = vec2(0.45, 0.8),
    is_static = false,
    color = 0x7b89be,
});
]]
local radius = 0.2;

local player = Scene:add_capsule({
    name = "player_100",
    position = vec2(0, -10 + (0.9 * 0.5) + 0.125),
    local_point_a = vec2(0, 0.4 - (radius)),
    local_point_b = vec2(0, -0.4 + (radius)),
    is_static = false,
    color = 0x7b89be,
    radius = radius,
});

local hash = Scene:add_component({
    name = "Player",
    id = "@amy/tiles/player",
    version = "0.1.0",
    code = temp_load_string('./scripts/@amy/tiles/player.lua')
});

player:add_component(hash);