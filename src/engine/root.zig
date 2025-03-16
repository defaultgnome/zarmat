pub const Application = @import("application.zig").Application;
// TODO: should we directly a zmath Vec? @Vector ?
// but the .x and .y is pretty neat
pub const Vec2 = struct {
    x: f32,
    y: f32,

    pub fn init(x: f32, y: f32) @This() {
        return .{
            .x = x,
            .y = y,
        };
    }

    pub fn identity() @This() {
        return .{
            .x = 0,
            .y = 0,
        };
    }
};
