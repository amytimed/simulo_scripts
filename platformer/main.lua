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
