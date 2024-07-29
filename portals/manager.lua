local p1 = Scene:add_box({
    name = "Portal",
    size = vec2(2, 0.2),
    position = vec2(0, 5),
    is_static = true,
    color = 0xf1853c,
});

p1:temp_set_collides(false);

local p2 = Scene:add_box({
    name = "Portal",
    size = vec2(2, 0.2),
    position = vec2(0, -5),
    is_static = true,
    color = 0x77aef1,
});

Scene:add_box({
    name = "Wall",
    size = vec2(4, 0.2),
    position = vec2(-6, -5),
    is_static = true,
    color = 0xe5d3b9,
});

Scene:add_box({
    name = "Wall",
    size = vec2(4, 0.2),
    position = vec2(6, -5),
    is_static = true,
    color = 0xe5d3b9,
});

Scene:add_box({
    name = "Wall",
    size = vec2(4, 0.2),
    position = vec2(6, 5),
    is_static = true,
    color = 0xe5d3b9,
});

Scene:add_box({
    name = "Wall",
    size = vec2(4, 0.2),
    position = vec2(-6, 5),
    is_static = true,
    color = 0xe5d3b9,
});

p2:temp_set_collides(false);

local box = Scene:add_box({
    name = "Portal Box",
    size = vec2(0.5, 0.5),
    position = vec2(0, 0),
    is_static = false,
    color = 0xa0a0a0,
});

local box2 = Scene:add_box({
    name = "Portal Box",
    size = vec2(0.5, 0.5),
    position = vec2(0, 0),
    is_static = true,
    color = 0xa0a0a0,
});

box2:temp_set_collides(false);

function on_update()
    update_box2();
end;

function on_step()
    update_box2();
end;

function update_box2()
    local box_pos = box:get_position();

    local x_in_range = (box_pos.x > -2) and (box_pos.x < 2);

    if not x_in_range then
        box2:set_position(vec2(0, -100));
        return;
    end;

    if box_pos.y < 0 then
        box2:set_position(box_pos + vec2(0, 10));
        box2:set_angle(box:get_angle());
    else
        box2:set_position(box_pos - vec2(0, 10));
        box2:set_angle(box:get_angle());
    end;

    if ((box_pos.y <= -5) or (box_pos.y >= 5)) and x_in_range then
        box:set_position(box2:get_position());
        box:set_angle(box2:get_angle());
    end;
end;

Scene:add_box({
    name = "Wall",
    size = vec2(10, 10),
    position = vec2(0, 15.2),
    is_static = true,
    color = 0xe5d3b9,
}):temp_set_collides(false);

Scene:add_box({
    name = "Wall",
    size = vec2(10, 10),
    position = vec2(0, -15.2),
    is_static = true,
    color = 0xe5d3b9,
}):temp_set_collides(false);