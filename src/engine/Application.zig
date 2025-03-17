//! This is the main abstraction over GLFW, and OpenGL initilization
//! Responsible for running the game loop, tracking the time, and getting the inputs
const std = @import("std");
const builtin = @import("builtin");
const glfw = @import("zglfw");
const zgui = @import("zgui");
const zm = @import("zmath");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;
const zstbi = @import("zstbi");

pub const Application = struct {
    window: *glfw.Window,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, config: ApplicationConfig) !Self {
        // glfw: init & config
        glfw.init() catch {
            std.log.err("GLFW Initilization failed", .{});
            std.process.exit(1);
        };

        // glfw: window creation
        const gl_major = 3;
        const gl_minor = 3;
        glfw.windowHint(.context_version_major, gl_major);
        glfw.windowHint(.context_version_minor, gl_minor);
        glfw.windowHint(.opengl_profile, .opengl_core_profile);
        if (builtin.target.os.tag.isDarwin()) {
            glfw.windowHint(.opengl_forward_compat, true);
        }
        glfw.windowHint(.client_api, .opengl_api);
        glfw.windowHint(.doublebuffer, true);

        const window = glfw.Window.create(
            config.window.size.initial.width,
            config.window.size.initial.height,
            config.title,
            null,
        ) catch {
            std.log.err("GLFW Window creation failed", .{});
            glfw.terminate();
            std.process.exit(1);
        };

        glfw.makeContextCurrent(window);
        _ = window.setFramebufferSizeCallback(framebufferSizeCallback);

        window.setSizeLimits(
            config.window.size.limits.min_w,
            config.window.size.limits.min_h,
            config.window.size.limits.max_w,
            config.window.size.limits.max_h,
        );
        try window.setInputMode(.cursor, config.window.input.cursor);

        // OpenGL: load profile
        try zopengl.loadCoreProfile(
            glfw.getProcAddress,
            gl_major,
            gl_minor,
        );

        // zgui: init
        zgui.init(allocator);

        zgui.io.setConfigFlags(.{
            .viewport_enable = true,
            .dock_enable = true,
        });

        zgui.backend.init(window);

        // zstbi: init
        zstbi.init(allocator);
        zstbi.setFlipVerticallyOnLoad(true);

        glfw.swapInterval(1);
        return .{
            .window = window,
        };
    }
    const ApplicationConfig = struct {
        title: [:0]const u8 = "",
        window: WindowOptions = .{},
    };
    const WindowOptions = struct {
        size: SizeOptions = .{},
        input: InputOptions = .{},
    };
    const SizeOptions = struct {
        initial: InitialSizeOptions = .{},
        limits: LimitsOptions = .{},
    };
    const InitialSizeOptions = struct {
        width: c_int = 960,
        height: c_int = 540,
    };
    const LimitsOptions = struct {
        min_w: c_int = -1,
        max_w: c_int = -1,
        min_h: c_int = -1,
        max_h: c_int = -1,
    };
    const InputOptions = struct {
        cursor: glfw.Cursor.Mode = .normal,
    };

    pub fn deinit(self: *Self) void {
        zstbi.deinit();
        zgui.backend.deinit();
        zgui.deinit();
        self.window.destroy();
        glfw.terminate();
    }
};

fn framebufferSizeCallback(window: *glfw.Window, width: i32, height: i32) callconv(.c) void {
    _ = window;
    gl.viewport(
        0,
        0,
        width,
        height,
    );
}
