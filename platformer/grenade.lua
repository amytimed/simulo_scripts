local counter = 300;
local flash_interval = 10;
local flash_1 = false;

function explosion()
    local hash = Scene:add_component({
        code = temp_load_string('./scripts/@amy/platformer/explosion.lua')
    });
    local c = Scene:add_circle({
        position = self:get_position(),
        radius = 2.5,
        color = 0xffffff,
        is_static = true,
        name = "Light"
    });
    c:temp_set_collides(false);
    c:add_component(hash);
end;

function on_step()
    counter -= 1;
    if counter < 100 then
        if (counter % flash_interval) == 0 then
            if flash_1 then
                self.color = 0x50a050
                flash_1 = false;
            else
                self.color = 0xff0000
                flash_1 = true; -- ik theres simpler way, too lazy
            end
        end
    end;
    if counter <= 0 then
        explosion();
        self:destroy();
    end;
end;