self:temp_set_collides(false);

local box = Scene:add_box({
    name = "button_inactive",
    position = self:get_position(),
    size = vec2(0.15, 1),
    is_static = false,
    color = 0xff7b7b,
});

box:set_angle(-0.2);

local box2 = Scene:add_box({
    name = "button base",
    position = self:get_position() + (vec2(21, -18.9) - vec2(20.2, -18.9)),
    size = vec2(0.2, 1),
    is_static = true,
    color = 0xa0a0a0,
});

local box3 = Scene:add_box({
    name = "button base 2",
    position = self:get_position() + (vec2(21, -18.9) - vec2(20.2, -18.9)),
    size = vec2(0.2, 1),
    is_static = true,
    color = 0xa0a0a0,
});

local pivot = Scene:add_circle({
    position = self:get_position() + (vec2(20.6, -18) - vec2(20.2, -18.9)),
    radius = 0.1,
    is_static = true,
    color = 0xffffff,
});
pivot:temp_set_collides(false);

local hinge = Scene:add_hinge_at_world_point({
    point = self:get_position() + (vec2(20.6, -18) - vec2(20.2, -18.9)),
    object_a = box,
    object_b = box2
});

local ground_body = Scene:add_circle({
    position = self:get_position() + (vec2(20.6, -19.8) - vec2(20.2, -18.9)),
    radius = 0.1,
    is_static = true,
    color = 0xffffff,
});
ground_body:temp_set_collides(false);

Scene:add_drag_spring({
    point = self:get_position() + (vec2(20.6, -19.8) - vec2(20.2, -18.9)),
    object_a = ground_body,
    object_b = box,
    strength = 50,
    damping = 0.8,
});

local cooldown = 0;

local gel_hash = Scene:add_component({
    name = "Gel",
    version = "0.1.0",
    id = "@amy/platformer/gel",
    code = temp_load_string('./scripts/@amy/platformer/gel.lua')
});

local gel_x = 0;
local gel_count = 30;

function on_step()
    if hinge:get_angle() < 0 then
        box.color = 0xffa0a0;
        box:set_name("button_active");

        if gel_count > 0 then
            cooldown -= 1;

            if cooldown <= 0 then
                cooldown = 2;
                local gel = Scene:add_box({
                    position = self:get_position() - vec2(6 + gel_x, -12),
                    size = vec2(0.2, 0.2),
                    color = 0x667dbd,
                    is_static = false,
                    name = "gel"
                });
                gel_x += 0.5;
                gel_count -= 1;
                gel:set_density(500);
                gel:add_component(gel_hash);
            end;
        end;
    else
        box.color = 0xff7b7b;
        box:set_name("button_inactive");
    end;
end;