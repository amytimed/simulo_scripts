function reset()
    local objs = Scene:get_all_objects();
    for i=1,#objs do
        objs[i]:destroy();
    end;
    local new_ground = Scene:add_box({
        position = vec2(0, -120),
        size = vec2(1000, 100),
        color = 0xb9a1c4,
        is_static = true,
    });
end;

reset();

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
    id = "@amy/platformer/player_component",
    version = "0.2.0",
    code = temp_load_string('./scripts/@amy/platformer/player.lua')
});

player:add_component(hash);

print(hash);

local button_spawner = Scene:add_component({
    name = "Button Spawner",
    version = "0.1.0",
    id = "@amy/platformer/button_spawner",
    code = temp_load_string('./scripts/@amy/platformer/button.lua')
});

Scene:add_circle({
    name = "button_spawner",
    position = vec2(31.2, -15.9),
    radius = 0.01,
    is_static = true,
    color = Scene.background_color,
}):add_component(button_spawner);

Scene:add_box({
    name = "Wall",
    position = vec2(27, -15.6),
    size = vec2(0.2, 2),
    is_static = true,
    color = 0xe5d3b9,
});

Scene:add_box({
    name = "Wall",
    position = vec2(29.7, -13.5),
    size = vec2(2.9, 0.2),
    is_static = true,
    color = 0xe5d3b9,
});

Scene:add_box({
    name = "Wall",
    position = vec2(32.4, -15.6),
    size = vec2(0.2, 2),
    is_static = true,
    color = 0xe5d3b9,
});

Scene:add_box({
    name = "Wall",
    position = vec2(37.8, -10),
    size = vec2(0.2, 10),
    is_static = true,
    color = 0xe5d3b9,
});

Scene:add_box({
    name = "Wall",
    position = vec2(37.8 + 10, -7),
    size = vec2(0.2, 13),
    is_static = true,
    color = 0xe5d3b9,
});

Scene:add_box({
    name = "Wall",
    position = vec2(37.8 + 5, -0.2),
    size = vec2(5, 0.2),
    is_static = true,
    color = 0xe5d3b9,
});

Scene:add_box({
    name = "Wall",
    position = vec2(17.8, 5.8),
    size = vec2(30, 0.2),
    is_static = true,
    color = 0xe5d3b9,
});

local weapon_item = Scene:add_box({
    position = vec2(44, 0.5),
    size = vec2(0.7, 0.1),
    color = 0xffffff,
    is_static = false,
    name = "Weapon 1"
});

Scene:add_box({
    name = "Wall",
    position = vec2(44, 0.2),
    size = vec2(0.5, 0.2),
    is_static = true,
    color = 0xe5d3b9,
});

Scene:add_box({
    name = "Wall",
    position = vec2(32.4, -7),
    size = vec2(0.2, 7),
    is_static = true,
    color = 0xe5d3b9,
});

Scene:add_box({
    name = "Wall",
    position = vec2(37.8 - 8.2, -0.2),
    size = vec2(2.8, 0.2),
    is_static = true,
    color = 0xe5d3b9,
});

Scene:add_box({
    name = "Wall",
    position = vec2(27, -7),
    size = vec2(0.2, 7),
    is_static = true,
    color = 0xe5d3b9,
});

Scene:add_box({
    name = "Wall",
    position = vec2(5, -6.85),
    size = vec2(0.2, 6.85),
    is_static = true,
    color = 0xe5d3b9,
});

Scene:add_box({
    name = "Wall",
    position = vec2(-0.4, -6.85),
    size = vec2(0.2, 6.85),
    is_static = true,
    color = 0xe5d3b9,
});

Scene:add_box({
    name = "Wall",
    position = vec2(2.3, -0.2),
    size = vec2(2.8, 0.2),
    is_static = true,
    color = 0xe5d3b9,
});

Scene:add_box({
    name = "Wall",
    position = vec2(2.3, -13.5),
    size = vec2(2.8, 0.2),
    is_static = true,
    color = 0xe5d3b9,
});

--[[
local gravgun = Scene:add_box({
    position = vec2(3, -19),
    size = vec2(0.7, 0.2),
    color = 0xe07536,
    is_static = false,
    name = "Gravity Gun"
});]]

Scene:add_box({
    name = "Box",
    position = vec2(3.3, -12.9),
    size = vec2(0.4, 0.4),
    is_static = false,
    color = 0xa0a0a0,
});

Scene:add_box({
    name = "Box",
    position = vec2(3.5, -12.9 + 0.8),
    size = vec2(0.4, 0.4),
    is_static = false,
    color = 0xa0a0a0,
});

Scene:add_box({
    name = "Box",
    position = vec2(1.5, -11.3),
    size = vec2(1, 2),
    is_static = false,
    color = 0xa0a0a0,
});