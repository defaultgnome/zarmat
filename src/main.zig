const std = @import("std");
const engine = @import("engine");
const glfw = @import("zglfw");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;
const zgui = @import("zgui");
const zm = @import("zmath");
const Application = engine.Application;
const Sprite = engine.renderer.Sprite;

pub fn main() !void {
    // Allocators
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    // Game Init
    var app = try Application.init(allocator, .{
        .title = "ZARMAT",
    });
    defer app.deinit();
    _ = app.window.setCursorPosCallback(mouseCallback);

    // Initialize the board sprite
    var pawn = try Sprite.init(
        allocator,
        "./assets/sprites/pieces/pawn_black.png",
    );
    defer pawn.deinit();

    while (!app.window.shouldClose()) {
        //---UPDATE
        { // Update Time State
            const current_frame = @as(f32, @floatCast(glfw.getTime()));
            state.delta_time = current_frame - state.last_frame;
            state.last_frame = current_frame;
        }
        processInput(app.window);
        // UPDATE LOGIC HERE

        //---DRAW
        glfw.pollEvents();

        { // Clear
            gl.clearColor(0.5, 0.5, 0.5, 1);
            gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        }

        {
            // RENDER HERE OPENGL
            pawn.render();
        }

        { // zgui
            const framebuffer_size = app.window.getFramebufferSize();

            zgui.backend.newFrame(@intCast(framebuffer_size[0]), @intCast(framebuffer_size[1]));

            // RENDER HERE UI

            zgui.backend.draw();

            { // Enable Multi-Viewports
                const ctx = glfw.getCurrentContext();
                zgui.updatePlatformWindows();
                zgui.renderPlatformWindowsDefault();
                glfw.makeContextCurrent(ctx);
            }
        }

        // Catch all incase we forgot
        engine.renderer.glLogErrors(@src());

        app.window.swapBuffers();
    }
}

const GameState = struct {
    delta_time: f32 = 0,
    last_frame: f32 = 0,
    mouse: struct {
        did_init: bool = false,
        last_x: f32 = 0,
        last_y: f32 = 0,
    },
};

var state = GameState{
    .mouse = .{},
};

fn processInput(window: *glfw.Window) callconv(.c) void {
    if (window.getKey(.left_control) == .press) {
        if (window.getKey(.q) == .press) {
            window.setShouldClose(true);
        }
    }
}

fn mouseCallback(window: *glfw.Window, xpos: f64, ypos: f64) callconv(.c) void {
    _ = window;
    const pos_x: f32 = @floatCast(xpos);
    const pos_y: f32 = @floatCast(ypos);

    // Without this the mouse jump on first event
    if (state.mouse.did_init == false) {
        state.mouse.last_x = pos_x;
        state.mouse.last_y = pos_y;
        state.mouse.did_init = true;
    }

    // const offset_x = pos_x - state.mouse.last_x;
    // const offset_y = state.mouse.last_y - pos_y;
    state.mouse.last_x = pos_x;
    state.mouse.last_y = pos_y;
}
