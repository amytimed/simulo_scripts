local counter = 300;

function starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

local hits = 0;

if self:get_name() == "Rocket" then
    self:set_density(1000);
end;

function explosion()
    local hash = Scene:add_component({
        code = temp_load_string('./scripts/@amy/platformer/explosion.lua')
    });
    local c = Scene:add_circle({
        position = self:get_position(),
        radius = 2.5,
        color = 0xffffff,
        is_static = true;
    });
    c:temp_set_collides(false);
    c:add_component(hash);
end;

function on_collision_start(other)
    if self:get_name() == "Rocket" then
        explosion();
        self:destroy();
        return;
    end;

    if (other:get_name() == "button_inactive") or (other:get_name() == "button_active") then
        self:destroy();
        return;
    end;
    
    if self:get_name() ~= "Enemy Projectile" then
        if starts(other:get_name(), "Enemy_") then
            -- Extract the HP value from the enemy's name
            local hp_value = tonumber(string.match(other:get_name(), "Enemy_(%d+)"))
            if hp_value then
                -- Reduce HP by 10
                hp_value = hp_value - 10;
                if hp_value < 0 then
                    hp_value = 0;
                end;
                
                -- Update the enemy's name with the new HP value
                other:set_name("Enemy_" .. hp_value);

                print("Hit enemy and lowered HP to " .. tostring(hp_value));
            end;

            self:destroy();
            return;
        end;
    else
        if starts(other:get_name(), "player_") then
            -- Extract the HP value from the player's name
            local hp_value = tonumber(string.match(other:get_name(), "player_(%d+)"))
            if hp_value then
                -- Reduce HP by 10
                hp_value = hp_value - 10;
                if hp_value < 0 then
                    hp_value = 0;
                end;
                
                -- Update the player's name with the new HP value
                other:set_name("player_" .. hp_value);

                print("Hit player and lowered HP to " .. tostring(hp_value));
            end;

            self:destroy();
            return;
        end;
    end;
    
    hits += 1;
    self.color = 0x705000;

    if hits > 1 then
        self:destroy();
    end;
end;

local start_vel = nil;

function on_step()
    if self:get_name() == "Rocket" then
        if start_vel == nil then
            start_vel = self:get_linear_velocity();
        end;

        self:set_linear_velocity(start_vel);

        counter -= 1;
        if counter <= 0 then
            self:destroy();
        end;
    end;
end;