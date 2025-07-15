const std = @import("std");
const sokol = @import("sokol");
const shd = @import("shader");
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;
const slog = sokol.log;

const State = struct {
    gfx: struct {
        pipeline: sg.Pipeline = .{},
        bindings: sg.Bindings = .{},
        pass_action: sg.PassAction = .{},
    } = .{},
};
var state: State = .{};

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

export fn frame() void {
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

export fn input(ev: ?*const sapp.Event) void {
    _ = ev;
}

export fn cleanup() void {
    sg.shutdown();
}
