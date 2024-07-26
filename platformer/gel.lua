local counter = 240;
local done = false;

function on_step()
    if done then
        return;
    end;

    counter -= 1;
    if counter <= 0 then
        self:set_restitution(1);
        self.color = 0x6797ff;
    end;
end;