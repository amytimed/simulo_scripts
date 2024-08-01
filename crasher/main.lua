Scene:reset();

local player = Scene:add_box({
    name = "player_100",
    position = vec2(2, -19.5),
    size = vec2(0.5, 0.5),
    is_static = false,
    color = 0xa0a0ff,
});

print(player.guid);

local hash = Scene:add_component({
    name = "Player Component",
    id = "@amy/crasher/player_component",
    version = "0.2.0",
    code = temp_load_string('./scripts/@amy/crasher/player.lua')
});

player:add_component(hash);

print(hash);

local weapon_item = Scene:add_box({
    position = vec2(44, 0.5),
    size = vec2(0.7, 0.1),
    color = 0xffffff,
    is_static = false,
    name = "Weapon 1"
});