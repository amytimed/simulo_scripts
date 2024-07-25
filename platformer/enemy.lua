local speed = 3;
local jump_force = 5;

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

function on_collision_start(other)
    contacts += 1;
    if other:get_name() == "Wall" then
        touching_wall = true;
    end;
    if starts(other:get_name(), "player_") then
        local hp_value = tonumber(string.match(other:get_name(), "player_(%d+)"))
        if hp_value then
            -- Reduce HP by 10
            hp_value = hp_value - 10;
            if hp_value < 0 then
                hp_value = 0;
            end;
            
            other:set_name("player_" .. hp_value);

            print("Hit player and lowered HP to " .. tostring(hp_value));
        end;
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

function get_player_pos()
    return player:get_position();
end;

function vec2_distance(vec1, vec2)
    local dx = vec2.x - vec1.x
    local dy = vec2.y - vec1.y
    return math.sqrt(dx * dx + dy * dy)
end

function on_step()
    local hp_value = tonumber(string.match(self:get_name(), "Enemy_(%d+)"))
    if hp_value then
        self.color = rgb_to_color(math.ceil((hp_value / 100.0) * 255), 0, 0);
        if hp_value <= 0 then
            self:destroy();
            return;
        end;
    end;
    if hp_value < 100 then
        was_shot = true;
    end;
    if player ~= nil then
        local current_vel = self:get_linear_velocity();
        local update_vel = false;

        if not pcall(get_player_pos) then
            print("Had error, fixed");
            find_player();
            if not pcall(get_player_pos) then
                return;
            end;
        end;

        local player_pos = player:get_position();

        local self_pos = self:get_position();

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
        end;
    else
        find_player();
    end;

    self:set_angle(0);
end;