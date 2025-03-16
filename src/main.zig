const std = @import("std");
const engine = @import("engine");

pub fn main() !void {
    // Allocators
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    // Game Init
    var app = try engine.Application.init(allocator, .{
        .title = "ZARMAT",
        .window = .{
            .color = .{ 0.5, 0.5, 0.5, 1.0 },
            .size = .{
                .limits = .{
                    .min_w = 400,
                    .max_w = -1,
                    .min_h = 600,
                    .max_h = -1,
                },
            },
            .input = .{
                .cursor = .normal,
            },
        },
    });
    defer app.deinit();
    app.initCallbacks();

    var game_state = GameState{ .cube_pos = engine.Vec2.identity() };

    // TODO: i don't like this way of plugining function to the "mainframe"
    // i want a more open way, maybe working with the window, and setting the event and loop ourself?
    // just calling some 'app.start()' and 'app.end()' function each frame?
    app.onUpdate(update, @ptrCast(&game_state));
    // TODO: create a Sprite and render it
    try app.run();
}

fn update(app: *engine.Application, user_data: *anyopaque) void {
    const delta_time = app.state.delta_time;
    const game_state: *GameState = @ptrCast(@alignCast(user_data));
    game_state.cube_pos.x += 1 * delta_time;
}

const GameState = struct {
    cube_pos: engine.Vec2,
};
