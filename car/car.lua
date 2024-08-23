self:set_density(6);

local left_wheel = Scene:add_circle({
    position = vec2((-1.8 / 2) + 0.3, -10 + 0.3),
    radius = 0.3,
    is_static = false,
    color = Color:hex(0x48404f)
});
local left_wheel_dot = Scene:add_circle({
    position = vec2((-1.8 / 2) + 0.3, -10 + 0.3 + 0.15),
    radius = 0.08,
    is_static = false,
    color = Color:hex(0x786d81)
});
left_wheel_dot:temp_set_collides(false);
left_wheel_dot:set_density(0.1);
left_wheel_dot:bolt_to(left_wheel);

left_wheel:set_friction(1);

local right_wheel = Scene:add_circle({
    position = vec2((1.8 / 2) - 0.3, -10 + 0.3),
    radius = 0.3,
    is_static = false,
    color = Color:hex(0x48404f)
});
local right_wheel_dot = Scene:add_circle({
    position = vec2((1.8 / 2) - 0.3, -10 + 0.3 + 0.15),
    radius = 0.08,
    is_static = false,
    color = Color:hex(0x786d81)
});
right_wheel_dot:temp_set_collides(false);
right_wheel_dot:set_density(0.1);
right_wheel_dot:bolt_to(right_wheel);
right_wheel:set_friction(1);

local left_hinge = Scene:add_hinge_at_world_point({
    point = vec2((-1.8 / 2) + 0.3, -10 + 0.3),
    object_a = left_wheel,
    object_b = self,
    motor_enabled = true,
    motor_speed = 0, -- radians per second
    max_motor_torque = 3,
});

local right_hinge = Scene:add_hinge_at_world_point({
    point = vec2((1.8 / 2) - 0.3, -10 + 0.3),
    object_a = right_wheel,
    object_b = self,
    motor_enabled = true,
    motor_speed = 0, -- radians per second
    max_motor_torque = 3,
});

local speed = 50;
function on_update()
    local new_speed = 0;

    if Input:key_pressed("D") then
        new_speed += speed;
    end;
    if Input:key_pressed("A") then
        new_speed -= speed;
    end;

    self:apply_force_to_center(vec2(0, 0));

    left_hinge:set_motor_speed(new_speed);
    right_hinge:set_motor_speed(new_speed);
end;