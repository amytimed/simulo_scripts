self:set_angle(0);

local trigger = Scene:add_box({
    name = "Rifle Trigger",
    size = vec2(0.04, 0.15),
    position = self:get_position() + vec2(-0.3, -0.15),
    is_static = false,
    color = 0xa0a0a0,
});

trigger:set_angle(0.8);

local pivot = self:get_position() + vec2(-0.35, -0.1);

Scene:add_circle({ position = pivot, radius = 0.01, color = 0xffffff, is_static = true });

Scene:add_hinge_at_world_point({
    point = pivot,
    object_a = self,
    object_b = trigger,
});