local function spawn_pylon(spawn_offset)
    local pylon_main = Scene:add_polygon({
        points = {
            [1] = vec2(-1.4 * 0.0625, 1),
            [2] = vec2(1.4 * 0.0625, 1),
            [3] = vec2(-0.5 + (2.1 * 0.0625), 2.6 * 0.0625),
            [4] = vec2(0.5 - (2.1 * 0.0625), 2.6 * 0.0625),
        },
        color = Color:hex(0x874e32),
        is_static = false,
        position = vec2(0, -10) + spawn_offset,
    });

    local pylon_base = Scene:add_box({
        position = vec2(0, -10 + (0.0625 * 2.6 * 0.5)) + spawn_offset,
        size = vec2(1 - 0.0625, 2.6 * 0.0625),
        color = Color:hex(0x4e2c2f),
        is_static = false,
    });

    pylon_base:bolt_to(pylon_main);

    local visor = Scene:add_polygon({
        points = {
            [1] = vec2(-3.2 * 0.0625, 2.1 * 0.0625),
            [2] = vec2(3.2 * 0.0625, 2.1 * 0.0625),
            [3] = vec2(4.6 * 0.0625, -2.1 * 0.0625),
            [4] = vec2(-4.6 * 0.0625, -2.1 * 0.0625),
        },
        color = Color:hex(0),
        is_static = false,
        position = vec2(0, -10 + (10 * 0.0625)) + spawn_offset,
    });

    local visor_border_height = 0.305 * 0.0625;
    local visor_bottom = Scene:add_polygon({
        points = {
            [1] = vec2(-4.6 * 0.0625, -2.1 * 0.0625),
            [2] = vec2(4.6 * 0.0625, -2.1 * 0.0625),
            [3] = vec2(((-0.13125 - visor_border_height) - 0.73125) / 3, -0.13125 - visor_border_height),
            [4] = vec2(-(((-0.13125 - visor_border_height) - 0.73125) / 3), -0.13125 - visor_border_height),
        },
        color = Color:hex(0x6a636e),
        is_static = false,
        position = vec2(0, -10 + (10 * 0.0625)) + spawn_offset,
    });
    local visor_top = Scene:add_polygon({
        points = {
            [1] = vec2(-3.2 * 0.0625, 2.1 * 0.0625),
            [2] = vec2(3.2 * 0.0625, 2.1 * 0.0625),
            [3] = vec2(((0.13125 + visor_border_height) - 0.73125) / 3, 0.13125 + visor_border_height),
            [4] = vec2(-(((0.13125 + visor_border_height) - 0.73125) / 3), 0.13125 + visor_border_height),
        },
        color = Color:hex(0x6a636e),
        is_static = false,
        position = vec2(0, -10 + (10 * 0.0625)) + spawn_offset,
    });

    local left_eye = Scene:add_circle({
        position = vec2(-1.8 * 0.0625, -10 + (10 * 0.0625)) + spawn_offset,
        radius = 1.6 * 0.0625 * 0.5,
        color = Color:hex(0xff9a52),
        is_static = false,
    });

    left_eye:bolt_to(visor);

    local right_eye = Scene:add_circle({
        position = vec2(1.8 * 0.0625, -10 + (10 * 0.0625)) + spawn_offset,
        radius = 1.6 * 0.0625 * 0.5,
        color = Color:hex(0xff9a52),
        is_static = false,
    });

    right_eye:bolt_to(visor);

    visor_top:bolt_to(visor);
    visor_bottom:bolt_to(visor);
    visor:bolt_to(pylon_main);

    local weapon_1 = Scene:add_polygon({
        points = {
            [1] = vec2(-4.9 * 0.0625, 1.3 * 0.0625),
            [2] = vec2(7.5 * 0.0625, 1.3 * 0.0625),
            [3] = vec2(5 * 0.0625, -1.3 * 0.0625),
            [4] = vec2(-4.9 * 0.0625, -1.3 * 0.0625),
        },
        color = Color:hex(0x403c42),
        is_static = false,
        position = vec2(0, -10 + (5.8 * 0.0625)) + spawn_offset,
    });

    local weapon_2 = Scene:add_polygon({
        points = {
            [1] = vec2(7.5 * 0.0625, 1.3 * 0.0625),
            [2] = vec2(12.1 * 0.0625, 1.3 * 0.0625),
            [3] = vec2(12.1 * 0.0625, -1.3 * 0.0625),
            [4] = vec2(5 * 0.0625, -1.3 * 0.0625),
        },
        color = Color:hex(0x1b191c),
        is_static = false,
        position = vec2(0, -10 + (5.8 * 0.0625)) + spawn_offset,
    });

    local weapon_3 = Scene:add_circle({
        position = vec2(0, -10 + (5.8 * 0.0625)) + spawn_offset,
        radius = 1.6 * 0.0625 * 0.5,
        color = Color:hex(0x1b191c),
        is_static = false,
    });

    weapon_2:bolt_to(weapon_1);
    weapon_3:bolt_to(weapon_1);

    Scene:add_hinge_at_world_point({
        point = vec2(0, -10 + (5.8 * 0.0625)) + spawn_offset,
        object_a = weapon_1,
        object_b = pylon_main,
        motor_enabled = true,
        motor_speed = 0, -- radians per second
        max_motor_torque = 1, -- maximum torque for the motor, in newton-meters
    });

    local hash = Scene:add_component({
        name = "Weapon",
        id = "@amy/pylon/weapon",
        version = "0.1.0",
        code = temp_load_string('./scripts/@amy/pylon/weapon.lua')
    });

    weapon_2:add_component(hash);

    weapon_1:set_angle(-0.38945937156677246);
end;

return spawn_pylon;