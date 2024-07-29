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

local hash = Scene:add_component({
    name = "Tetris Manager",
    id = "@amy/tetris/manager",
    version = "0.2.0",
    code = temp_load_string('./scripts/@amy/tetris/manager.lua')
});

local manager = Scene:add_box({
    name = "Tetris Manager",
    size = vec2(0.2, 0.2),
    position = vec2(0, -100),
    is_static = true,
    color = 0xa0a0a0,
});

manager:add_component(hash);