local speed = 5;
local jump_force = 5;
local weapon_offset = vec2(0.3, 0);
local weapon_cooldown = 0;
local weapon = nil;
local grenade_count = 10;
local weapon_number = 0;

local contacts = 0;
local touching_wall = false;

function get_weapon_1(obj)
    if weapon ~= nil then
        weapon:temp_set_is_static(false);
        weapon:temp_set_collides(true);
        weapon:set_position(weapon:get_position() + vec2(-2, 0));
        weapon:set_linear_velocity(self:get_linear_velocity());
    end;
    weapon = obj;
    weapon:temp_set_is_static(true);
    weapon:temp_set_collides(false);
    weapon_offset = vec2(0.3, 0);
    weapon_cooldown = 0;
    weapon_number = 1;
end;

function get_weapon_2(obj)
    if weapon ~= nil then
        weapon:temp_set_is_static(false);
        weapon:temp_set_collides(true);
        weapon:set_position(weapon:get_position() + vec2(-2, 0));
        weapon:set_linear_velocity(self:get_linear_velocity());
    end;
    weapon = obj;
    weapon:temp_set_is_static(true);
    weapon:temp_set_collides(false);
    weapon_offset = vec2(0.2, 0);
    weapon_cooldown = 0;
    weapon_number = 2;
end;

function on_collision_start(other)
    contacts += 1;
    if other:get_name() == "Wall" then
        touching_wall = true;
    end;
    if other:get_name() == "Weapon 1" then
        get_weapon_1(other);
    end;
    if other:get_name() == "Weapon 2" then
        get_weapon_2(other);
    end;
    if other:get_name() == "health_fruit" then
        local hp_value = tonumber(string.match(self:get_name(), "player_(%d+)"))
        if hp_value then
            hp_value = hp_value + 10;
            if hp_value > 100 then
                hp_value = 100;
            end;
            
            self:set_name("player_" .. hp_value);
        end;
        other:destroy();
    end;
    if other:get_name() == "grenade" then
        grenade_count += 1;
        other:destroy();
    end;
end;

function on_collision_end(other)
    contacts -= 1;
    if contacts < 0 then
        contacts = 0;
    end;
    if other:get_name() == "Wall" then
        touching_wall = false;
    end;
end;

local weapon_item = Scene:add_box({
    position = self:get_position() + vec2(10, 1),
    size = vec2(0.7, 0.1),
    color = 0xffffff,
    is_static = false,
    name = "Weapon 1"
});

local weapon_item = Scene:add_box({
    position = self:get_position() + vec2(15, 1),
    size = vec2(0.9, 0.2),
    color = 0x50a050,
    is_static = false,
    name = "Weapon 2"
});

function spawn_health(pos)
    local health_fruit = Scene:add_box({
        position = pos,
        size = vec2(0.2, 0.2),
        color = 0x00ff00,
        is_static = false,
        name = "health_fruit"
    });
end;

local proj_hash = Scene:add_component({
    name = "Projectile",
    id = "@amy/platformer/projectile",
    version = "0.1.0",
    code = temp_load_string('./scripts/@amy/platformer/projectile.lua')
});

local enemy_hash = Scene:add_component({
    name = "Enemy",
    id = "@amy/platformer/enemy",
    version = "0.1.0",
    code = temp_load_string('./scripts/@amy/platformer/enemy.lua')
});

local grenade_hash = Scene:add_component({
    name = "Grenade",
    id = "@amy/platformer/grenade",
    version = "0.1.0",
    code = temp_load_string('./scripts/@amy/platformer/grenade.lua')
});

function on_start()
    print("start!!");
end;

function spawn_enemy(pos)
    local enemy = Scene:add_box({
        name = "Enemy_100",
        position = pos,
        size = vec2(0.5, 0.5),
        is_static = false,
        color = 0xffa0a0,
    });
    enemy:add_component(enemy_hash);
end;

function spawn_grenade(pos)
    Scene:add_box({
        position = pos,
        size = vec2(0.15, 0.2),
        color = 0x50a050,
        is_static = false,
        name = "grenade",
    });
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
    if Input:key_pressed("W") and ((contacts > 0) or touching_wall) then
        current_vel.y = jump_force;
        update_vel = true;
        contacts = 0;
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
            if weapon_cooldown <= 0 then
                launch_projectile();
            end;
        end;
    end;

    if Input:key_just_pressed("C") then
        spawn_enemy(Input:pointer_pos());
    end;
    if Input:key_just_pressed("V") then
        spawn_health(Input:pointer_pos());
    end;
    if Input:key_just_pressed("E") then
        launch_grenade();
    end;
    if Input:key_just_pressed("G") then
        spawn_grenade(Input:pointer_pos());
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
end;

function launch_projectile()
    weapon_cooldown = 4;
    -- Get the player's position and velocity
    local player_pos = self:get_position()
    local player_vel = self:get_linear_velocity()
    
    -- Calculate the end point of the weapon
    local weapon_length = 1.1  -- Length of the weapon (same as size.x in the weapon creation)
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
        radius = 0.1,
        color = 0xffa000,
        is_static = false,
        name = name,
    });

    proj:temp_set_group_index(-69);
    proj:set_restitution(1);
    proj:set_friction(0);

    proj:add_component(proj_hash);
    
    -- Calculate the projectile velocity
    local velocity = vec2(
        projectile_speed * math.cos(angle),
        projectile_speed * math.sin(angle)
    )
    
    -- Add the player's velocity to the projectile's velocity
    velocity = velocity + player_vel
    
    -- Set the projectile's velocity
    proj:set_linear_velocity(velocity)
end

function launch_grenade()
    if grenade_count < 1 then
        return;
    end;

    grenade_count -= 1;

    -- Get the player's position and velocity
    local player_pos = self:get_position()
    local player_vel = self:get_linear_velocity()
    
    -- Calculate the end point of the weapon
    local weapon_length = 1.1  -- Length of the weapon (same as size.x in the weapon creation)
    local world_position = Input:pointer_pos();
    local angle = math.atan2(world_position.y - player_pos.y, world_position.x - player_pos.x);
        
    local end_point = player_pos + vec2(
        weapon_length * math.cos(angle),
        weapon_length * math.sin(angle)
    )

    -- Add the projectile at the calculated end point
    local proj = Scene:add_box({
        position = end_point,
        size = vec2(0.15, 0.2),
        color = 0x50a050,
        is_static = false,
        name = "Grenade",
    });
    proj:set_angle(math.random() * 2 * math.pi);
    local function random_angular_velocity(max)
        local sign = (math.random(0, 1) == 0) and -1 or 1;
        return sign * math.random() * max;
    end
    proj:set_angular_velocity(random_angular_velocity(10));
    proj:temp_set_group_index(-69);
    proj:set_restitution(0);
    proj:set_friction(1);

    proj:add_component(grenade_hash);
    
    -- Calculate the projectile velocity
    local projectile_speed = 10  -- Set the desired speed for the projectile
    local velocity = vec2(
        projectile_speed * math.cos(angle),
        projectile_speed * math.sin(angle)
    )
    
    -- Add the player's velocity to the projectile's velocity
    velocity = velocity + player_vel
    
    -- Set the projectile's velocity
    proj:set_linear_velocity(velocity)
end
