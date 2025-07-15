const std = @import("std");
const sokol = @import("sokol");
const shd = @import("shader");
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;
const slog = sokol.log;

// MAIN
pub fn main() !void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .event_cb = input,
        .cleanup_cb = cleanup,
        .width = 640,
        .height = 480,
        .window_title = "zarmat",
        .icon = .{
            .sokol_default = true,
        },
        .logger = .{ .func = slog.func },
    });
}

export fn init() void {
    gfx.init();
}

export fn frame() void {
    // run the game at a fixed tick rate regardless of frame rate
    var frame_time_ns = @as(f32, @floatCast(sapp.frameDuration() * 1000000000.0));
    // clamp max frame duration (so the timing isn't messed up when stepping in debugger)
    if (frame_time_ns > MaxFrameTimeNS) {
        frame_time_ns = MaxFrameTimeNS;
    }

    state.timing.time_accum += @as(i32, @intFromFloat(frame_time_ns));
    if (state.timing.time_accum > TickDurationNS - TickToleranceNS) {
        state.timing.time_accum = 0;
        state.timing.tick += 1;

        // call the top-level game mode tick function
        // switch (state.game_mode) {
        //     .Menu => introTick(),
        //     .Game => gameTick(),
        // }
    }
    gfx.frame();
    // sound.frame(@as(i32, @intFromFloat(frame_time_ns)));
}

export fn input(ev: ?*const sapp.Event) void {
    _ = ev;
}

export fn cleanup() void {
    sg.shutdown();
}

// STATE
const TickDurationNS = 16_666_667;
const MaxFrameTimeNS = 33_333_333.0; // max duration of a frame in nanoseconds
const TickToleranceNS = 1_000_000; // max time tolerance of a game tick in nanoseconds

const GameMode = enum {
    Menu,
    Game,
};

const State = struct {
    game_mode: GameMode = .Menu,

    timing: struct {
        tick: u32 = 0,
        time_accum: i32 = 0,
    } = .{},

    gfx: struct {
        pipeline: sg.Pipeline = .{},
        bindings: sg.Bindings = .{},
        pass_action: sg.PassAction = .{},
    } = .{},
};
var state: State = .{};

// INTERNAL
const gfx = struct {
    pub fn init() void {
        sg.setup(.{
            .environment = sglue.environment(),
            .logger = .{ .func = slog.func },
        });

        // zig fmt: off
        const vertices = [_]f32{
            0.0,  0.5, 0.5,     1.0, 0.0, 0.0, 1.0,
            0.5, -0.5, 0.5,     0.0, 1.0, 0.0, 1.0,
            -0.5, -0.5, 0.5,     0.0, 0.0, 1.0, 1.0
        };
        // zig fmt: on
        state.gfx.bindings.vertex_buffers[0] = sg.makeBuffer(.{
            .data = sg.asRange(&vertices),
        });

        {
            var pip_desc: sg.PipelineDesc = .{
                .shader = sg.makeShader(shd.displayShaderDesc(sg.queryBackend())),
            };
            pip_desc.layout.attrs[shd.ATTR_display_position].format = .FLOAT3;
            pip_desc.layout.attrs[shd.ATTR_display_color0].format = .FLOAT4;
            state.gfx.pipeline = sg.makePipeline(pip_desc);
        }

        state.gfx.pass_action.colors[0] = sg.ColorAttachmentAction{
            .load_action = .CLEAR,
            .clear_value = .{ .r = 0.0, .g = 0.0, .b = 0.0, .a = 1.0 },
        };
    }

    pub fn frame() void {
        sg.beginPass(.{
            .action = state.gfx.pass_action,
            .swapchain = sglue.swapchain(),
        });
        sg.applyPipeline(state.gfx.pipeline);
        sg.applyBindings(state.gfx.bindings);
        sg.draw(0, 3, 1);
        sg.endPass();
        sg.commit();
    }
};
