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
            .size = .{
                .initial = .{
                    .width = 800,
                    .height = 600,
                },
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

    try app.run();
}
