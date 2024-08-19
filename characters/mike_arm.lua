local normal_color = Color:hex(0x423847);
local sticky_color = Color:hex(0x8ec25e);

local sticky_hinges = {};

local sticky = false;

local proj_hash = Scene:add_component({
    name = "Projectile",
    id = "@amy/characters/projectile",
    version = "0.1.0",
    code = temp_load_string('./scripts/@amy/characters/projectile.lua')
});

function on_update()
    if Input:key_just_pressed("Z") then
        sticky = not sticky;
        if sticky then
            self.color = sticky_color;
        else
            for i=1,#sticky_hinges do
                sticky_hinges[i]:destroy();
            end;
            sticky_hinges = {};
            self.color = normal_color;
        end;
    end;

    if Input:key_just_pressed("Q") then
        local player_pos = self:get_position()
        local player_vel = self:get_linear_velocity()
        
        -- Calculate the end point of the weapon
        local weapon_length = 0.5; -- Length of the weapon (same as size.x in the weapon creation)
        local angle = self:get_angle()
        local end_point = player_pos + vec2(
            weapon_length * math.cos(angle),
            weapon_length * math.sin(angle)
        );

        -- Add the projectile at the calculated end point
        local name = "Light";
        local projectile_speed = 50;
        
        local proj = Scene:add_box({
            position = end_point,
            size = vec2(0.5, 0.05),
            color = 0xff7979,
            is_static = false,
            name = name,
        });
        proj:set_density(10);
        proj:set_angle(angle);

        proj:temp_set_group_index(-69);
        proj:set_restitution(1);
        proj:set_friction(0);

        proj:add_component(proj_hash);
        
        -- Calculate the projectile velocity
        local velocity = vec2(
            projectile_speed * math.cos(angle),
            projectile_speed * math.sin(angle)
        ) / 2;
        
        -- Add the player's velocity to the projectile's velocity
        local final_velocity = velocity + player_vel
        
        -- Set the projectile's velocity
        proj:set_linear_velocity(final_velocity)

        self:apply_force_to_center(-velocity * 0.1);
    end;
end;

function on_collision_start(data)
    if sticky then
        for i=1,#data.points do
            table.insert(sticky_hinges, Scene:add_hinge_at_world_point({
                point = data.points[i],
                object_a = self,
                object_b = data.other,
                motor_enabled = false,
                motor_speed = 0, -- radians per second
                max_motor_torque = 1.25, -- maximum torque for the motor, in newton-meters
                collide_connected = true,
            }));
        end;
    end;
end;