local speed = 3 / 2;
local jump_force = 5 / 2;

local health_bar_fg = nil;
local health_bar_bg = nil;
local health_bar_offset = vec2(0, 0.5);
local health_bar_width = 0.8;
local health_bar_height = 0.05;
local prev_hp_value = 100;

local weapon_offset = vec2(0.15, 0);
local weapon_cooldown = 0;
local weapon = nil;
local weapon_number = 0;

local grenade_count = 10;

self:temp_set_group_index(-68);

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

function get_weapon_2(obj)
    if weapon ~= nil then
        weapon:temp_set_is_static(false);
        weapon:temp_set_collides(true);
        weapon:set_position(weapon:get_position() + vec2(-1, 0));
        weapon:set_linear_velocity(self:get_linear_velocity());
    end;
    weapon = obj;
    weapon:temp_set_is_static(true);
    weapon:temp_set_collides(false);
    weapon_offset = vec2(0.1, 0);
    weapon_cooldown = 0;
    weapon_number = 2;
end;

if math.random(1, 4) == 2 then
    get_weapon_1(Scene:add_box({
        position = self:get_position(),
        size = vec2(0.7, 0.1),
        color = 0xffffff,
        is_static = false,
        name = "Weapon 1"
    }));
end;

local proj_hash = Scene:add_component({
    name = "Projectile",
    id = "@amy/platformer/projectile",
    version = "0.1.0",
    code = temp_load_string('./scripts/@amy/platformer/projectile.lua')
});

function update_health_bar(value)
    if health_bar_fg ~= nil then
        health_bar_fg:destroy();
    end;
    if health_bar_bg ~= nil then
        health_bar_bg:destroy();
    end;
    health_bar_bg = Scene:add_box({
        position = self:get_position() + health_bar_offset,
        size = vec2(health_bar_width, health_bar_height),
        color = 0x000000,
        is_static = true,
    });
    health_bar_bg:temp_set_collides(false);
    health_bar_fg = Scene:add_box({
        position = self:get_position() + health_bar_offset + (vec2(((value / 100.0) * health_bar_width) - health_bar_width, 0)) / 2,
        size = vec2((value / 100.0) * health_bar_width, health_bar_height),
        color = 0x00ff00,
        is_static = true,
    });
    health_bar_fg:temp_set_collides(false);
end;

update_health_bar(100);

function starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

if not starts(self:get_name(), "Enemy_") then
    self:set_name("Enemy_100");
end;

function rgb_to_color(r, g, b)
    return r * 0x10000 + g * 0x100 + b;
end

local player = nil;

function find_player()
    local objs = Scene:get_all_objects();
    for i=1,#objs do
        if starts(objs[i]:get_name(), "player_") then
            player = objs[i];
        end;
    end;
end;

find_player();

local contacts = 0;
local touching_wall = false;

local was_shot = false;

function on_collision_start(data)
    contacts += 1;
    if data.other:get_name() == "Wall" then
        touching_wall = true;
    end;
    if starts(data.other:get_name(), "player_") then
        local hp_value = tonumber(string.match(data.other:get_name(), "player_(%d+)"))
        if hp_value then
            -- Reduce HP by 10
            hp_value = hp_value - 10;
            if hp_value < 0 then
                hp_value = 0;
            end;
            
            data.other:set_name("player_" .. hp_value);

            print("Hit player and lowered HP to " .. tostring(hp_value));
        end;
    end;
    if data.other:get_name() == "health_fruit" then
        local hp_value = tonumber(string.match(self:get_name(), "Enemy_(%d+)"))
        if hp_value then
            hp_value = hp_value + 10;
            if hp_value > 100 then
                hp_value = 100;
            end;
            
            self:set_name("Enemy_" .. hp_value);
        end;
        data.other:destroy();
    end;
    if (data.other:get_name() == "Weapon 1") and (weapon_number ~= 1) then
        get_weapon_1(data.other);
    end;
    if (data.other:get_name() == "Weapon 2") and (weapon_number ~= 2) then
        get_weapon_2(data.other);
    end;
end;

function on_collision_end(data)
    contacts -= 1;
    if contacts < 0 then
        contacts = 0;
    end;
    if data.other:get_name() == "Wall" then
        touching_wall = false;
    end;
end;

function get_player_pos()
    return player:get_position();
end;

function vec2_distance(vec1, vec2)
    local dx = vec2.x - vec1.x
    local dy = vec2.y - vec1.y
    return math.sqrt(dx * dx + dy * dy)
end

function spawn_health(pos)
    local health_fruit = Scene:add_box({
        position = pos,
        size = vec2(0.2, 0.2),
        color = 0x00ff00,
        is_static = false,
        name = "health_fruit"
    });
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

function on_step()
    local hp_value = tonumber(string.match(self:get_name(), "Enemy_(%d+)"))
    if hp_value then
        self.color = rgb_to_color(math.ceil((hp_value / 100.0) * 255), 0, 0);
        if hp_value <= 0 then
            if math.random(1, 15) == 2 then
                spawn_grenade(self:get_position());
            end;
            if math.random(1, 15) == 2 then
                spawn_health(self:get_position());
            end;
            if health_bar_fg ~= nil then
                health_bar_fg:destroy();
            end;
            if health_bar_bg ~= nil then
                health_bar_bg:destroy();
            end;
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
    if hp_value < 100 then
        was_shot = true;
    end;

    local self_pos = self:get_position()
    if weapon ~= nil then
        weapon:set_position(self_pos + weapon_offset);
    end;

    if player ~= nil then
        local current_vel = self:get_linear_velocity();
        local update_vel = false;

        if player:is_destroyed() then
            print("Had error, fixed");
            find_player();
            if player:is_destroyed() then
                return;
            end;
        end;

        local player_pos = player:get_position();

        local distance = vec2_distance(player_pos, self_pos);
        
        if (distance < 15) or was_shot then
            if player_pos.x > self_pos.x then
                if current_vel.x < speed then
                    current_vel.x = speed;
                    update_vel = true;
                end;
            end;
            if player_pos.x < self_pos.x then
                if current_vel.x > -speed then
                    current_vel.x = -speed;
                    update_vel = true;
                end;
            end;
            if player_pos.y > (self_pos.y + 0.1) then
                if (contacts > 0) or touching_wall then
                    current_vel.y = jump_force;
                    update_vel = true;
                    contacts = 0;
                end;
            end;
            if update_vel then
                self:set_linear_velocity(current_vel);
            end;

            if weapon ~= nil then
                -- Adjust rotation to use our position as the pivot
                local world_position = player_pos;
                local angle = math.atan2(world_position.y - self_pos.y, world_position.x - self_pos.x)
                
                -- Set weapon's angle
                weapon:set_angle(angle)
                
                -- Calculate the new position of the weapon based on the angle
                local rotated_offset = vec2(
                    weapon_offset.x * math.cos(angle) - weapon_offset.y * math.sin(angle),
                    weapon_offset.x * math.sin(angle) + weapon_offset.y * math.cos(angle)
                )
                weapon:set_position(self_pos + rotated_offset)

                if weapon_cooldown > 0 then
                    weapon_cooldown -= 1;
                end;

                if weapon_cooldown <= 0 then
                    launch_projectile();
                end;
            end;
        end;
    else
        find_player();
    end;

    self:set_angle(0);

    if hp_value ~= prev_hp_value then
        update_health_bar(hp_value);
    elseif health_bar_bg ~= nil then
        health_bar_bg:set_position(self:get_position() + health_bar_offset);
        health_bar_fg:set_position(self:get_position() + health_bar_offset + (vec2(((hp_value / 100.0) * health_bar_width) - health_bar_width, 0)) / 2);
    end;

    prev_hp_value = hp_value;
end;

function launch_projectile()
    weapon_cooldown = 10;
    -- Get our position and velocity
    local self_pos = self:get_position()
    local self_vel = self:get_linear_velocity()
    
    -- Calculate the end point of the weapon
    local weapon_length = 1.1 / 2 -- Length of the weapon (same as size.x in the weapon creation)
    local angle = weapon:get_angle()
    local end_point = self_pos + vec2(
        weapon_length * math.cos(angle),
        weapon_length * math.sin(angle)
    )

    -- Add the projectile at the calculated end point
    local name = "Enemy Projectile";
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

    proj:temp_set_group_index(-68);
    proj:set_restitution(1);
    proj:set_friction(0);

    proj:add_component(proj_hash);
    
    -- Calculate the projectile velocity
    local velocity = vec2(
        projectile_speed * math.cos(angle),
        projectile_speed * math.sin(angle)
    ) / 2;
    
    -- Add our velocity to the projectile's velocity
    velocity = velocity + self_vel
    
    -- Set the projectile's velocity
    proj:set_linear_velocity(velocity)
end;