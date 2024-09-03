Scene:reset():set_restitution(0);

function alpha_ball(pos, radius)
    local circle = Scene:add_circle({
        position = pos,
        radius = radius,
        is_static = false,
        color = Color:rgba(0,0,0,0)
    });

    Scene:add_attachment({
        name = "Image",
        component = {
            name = "Image",
            code = temp_load_string('./scripts/core/hinge.lua'),
        },
        parent = circle,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "~/scripts/@amy/images/alpha.png",
        size = (radius * 2) / 512,
        color = Color:hex(0xffffff),
        light = {
            color = 0x6ba2ff,
            intensity = 2,
            radius = 2,
        }
    });
end;

alpha_ball(vec2(0,-10 + 0.8), 0.8);

local box = Scene:add_box({
    position = vec2(2.5, -10 + 1),
    size = vec2(1,2),
    is_static = false,
    color = 0x435555,
});

Scene:add_attachment({
    name = "Point Light",
    component = {
        name = "Point Light",
        code = temp_load_string('./scripts/core/hinge.lua'),
    },
    parent = box,
    local_position = vec2(0,0.5),
    local_angle = 0,
    image = "embedded://textures/point_light.png",
    size = 0.001,
    color = Color:hex(0xdb5858),
    light = {
        color = 0xdb5858,
        intensity = 6,
        radius = 1,
    }
});

Scene:add_attachment({
    name = "Point Light",
    component = {
        name = "Point Light",
        code = temp_load_string('./scripts/core/hinge.lua'),
    },
    parent = box,
    local_position = vec2(0,-0.5),
    local_angle = 0,
    image = "embedded://textures/point_light.png",
    size = 0.001,
    color = Color:hex(0x648ddb),
    light = {
        color = 0x648ddb,
        intensity = 6,
        radius = 1,
    }
});