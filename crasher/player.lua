local speed = 5 / 2;
local jump_force = 5 / 2;
local weapon_offset = vec2(0.15, 0);
local weapon_cooldown = 0;
local weapon = nil;
local weapon_number = 0;

function get_weapon_1(obj)
    if weapon ~= nil then
        weapon:temp_set_is_static(false);
        weapon:temp_set_collides(true);
        weapon:set_position(weapon:get_position() + vec2(-1, 0));
        weapon:set_linear_velocity(self:get_linear_velocity());
    end;
    weapon = obj;
    weapon:temp_set_is_static(true);
    weapon:temp_set_collides(false);
    weapon_offset = vec2(0.15, 0);
    weapon_cooldown = 0;
    weapon_number = 1;
end;

function on_collision_start(data)
    if (data.other:get_name() == "Weapon 1") and (weapon_number ~= 1) then
        get_weapon_1(data.other);
    end;
end;

local proj_hash = Scene:add_component({
    name = "Projectile",
    id = "@amy/platformer/projectile",
    version = "0.1.0",
    code = temp_load_string('./scripts/@amy/platformer/projectile.lua')
});

function on_start()
    print("start!!");
end;

function on_update()
    local current_vel = self:get_linear_velocity();
    local update_vel = false;

    if Input:key_pressed("D") then
        if current_vel.x < speed then
            current_vel.x = speed;
            update_vel = true;
        end;
    end;
    if Input:key_pressed("A") then
        if current_vel.x > -speed then
            current_vel.x = -speed;
            update_vel = true;
        end;
    end;

    if update_vel then
        self:set_linear_velocity(current_vel);
    end;

    self:set_angle(0);

    --[[
    weapon:set_position(self:get_position() + weapon_offset);

    -- this code rotates weapon from center :( we want it rotate from different point (self position) instead
    local world_position = Input:pointer_pos();
    local global_pos = weapon:get_position();
    weapon:set_angle(math.atan2(world_position.y - global_pos.y, world_position.x - global_pos.x));
    ]]

    if weapon ~= nil then
        local player_pos = self:get_position()
        weapon:set_position(player_pos + weapon_offset)

        -- Adjust rotation to use the player position as the pivot
        local world_position = Input:pointer_pos()
        local angle = math.atan2(world_position.y - player_pos.y, world_position.x - player_pos.x)
        
        -- Set weapon's angle
        weapon:set_angle(angle)
        
        -- Calculate the new position of the weapon based on the angle
        local rotated_offset = vec2(
            weapon_offset.x * math.cos(angle) - weapon_offset.y * math.sin(angle),
            weapon_offset.x * math.sin(angle) + weapon_offset.y * math.cos(angle)
        )
        weapon:set_position(player_pos + rotated_offset)

        if Input:pointer_pressed() then
            if weapon_number ~= 3 then
                if weapon_cooldown <= 0 then
                    launch_projectile();
                end;
            end;
        end;
    end;
end;

function rgb_to_color(r, g, b)
    return r * 0x10000 + g * 0x100 + b;
end

function on_step()
    local hp_value = tonumber(string.match(self:get_name(), "player_(%d+)"))
    if hp_value then
        self.color = rgb_to_color(0, math.ceil((hp_value / 100.0) * 255), math.ceil((hp_value / 100.0) * 255));
        if hp_value <= 0 then
            if weapon ~= nil then
                weapon:temp_set_is_static(false);
                weapon:temp_set_collides(true);
                weapon:set_position(weapon:get_position());
                weapon:set_linear_velocity(self:get_linear_velocity());
            end;
            self:destroy();
            return;
        end;
    end;

    --weapon:set_position(self:get_position() + weapon_offset);
    self:set_angle(0);

    if weapon ~= nil then
        local player_pos = self:get_position()
        weapon:set_position(player_pos + weapon_offset)

        -- Adjust rotation to use the player position as the pivot
        local world_position = Input:pointer_pos()
        local angle = math.atan2(world_position.y - player_pos.y, world_position.x - player_pos.x)
        
        -- Set weapon's angle
        weapon:set_angle(angle)
        
        -- Calculate the new position of the weapon based on the angle
        local rotated_offset = vec2(
            weapon_offset.x * math.cos(angle) - weapon_offset.y * math.sin(angle),
            weapon_offset.x * math.sin(angle) + weapon_offset.y * math.cos(angle)
        )
        weapon:set_position(player_pos + rotated_offset)

        if weapon_cooldown > 0 then
            weapon_cooldown -= 1;
        end;
    end;

    prev_hp_value = hp_value;
end;

function launch_projectile()
    weapon_cooldown = 4;
    -- Get the player's position and velocity
    local player_pos = self:get_position()
    local player_vel = self:get_linear_velocity()
    
    -- Calculate the end point of the weapon
    local weapon_length = 1.1 / 2 -- Length of the weapon (same as size.x in the weapon creation)
    local angle = weapon:get_angle()
    local end_point = player_pos + vec2(
        weapon_length * math.cos(angle),
        weapon_length * math.sin(angle)
    )

    -- Add the projectile at the calculated end point
    local name = "Projectile";
    local projectile_speed = 10;
    if weapon_number == 2 then
        name = "Rocket";
        projectile_speed = 20;
        weapon_cooldown = 120;
    end;
    local proj = Scene:add_circle({
        position = end_point,
        radius = 0.05,
        color = 0xffa000,
        is_static = false,
        name = name,
    });

    proj:temp_set_group_index(-69);
    proj:set_restitution(1);
    proj:set_friction(0);

    --proj:add_component(proj_hash);
    
    -- Calculate the projectile velocity
    local velocity = vec2(
        projectile_speed * math.cos(angle),
        projectile_speed * math.sin(angle)
    ) / 2;
    
    -- Add the player's velocity to the projectile's velocity
    velocity = velocity + player_vel
    
    -- Set the projectile's velocity
    proj:set_linear_velocity(velocity)
end