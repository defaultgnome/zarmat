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
    state: State,
    window: *glfw.Window,
    clear_color: zm.Vec,

    update_callback: ?*const fn (self: *Self, user_data: *anyopaque) void = null,
    update_user_data: ?*anyopaque = null,

    const Self = @This();

    const State = struct {
        delta_time: f32,
        last_frame: f32,
        mouse: struct {
            did_init: bool,
            last_x: f32,
            last_y: f32,
        },
    };

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
            .state = .{
                .delta_time = 0,
                .last_frame = 0,
                .mouse = .{
                    .did_init = false,
                    .last_x = 400,
                    .last_y = 400,
                },
            },
            .window = window,
            .clear_color = config.window.color,
        };
    }
    const ApplicationConfig = struct {
        title: [:0]const u8 = "",
        window: WindowOptions = .{},
    };
    const WindowOptions = struct {
        size: SizeOptions = .{},
        input: InputOptions = .{},
        color: zm.Vec = .{ 0, 0, 0, 1.0 },
    };
    const SizeOptions = struct {
        initial: InitialSizeOptions = .{},
        limits: LimitsOptions = .{},
    };
    const InitialSizeOptions = struct {
        width: c_int = 600,
        height: c_int = 800,
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

    /// This exist just because i needed to call `setUserPointer` and pass it
    /// this struct instance
    pub fn initCallbacks(self: *Self) void {
        const window = self.window;
        glfw.makeContextCurrent(window);
        window.setUserPointer(self);
        _ = window.setFramebufferSizeCallback(framebufferSizeCallback);
        _ = window.setCursorPosCallback(mouseCallback);
    }

    pub fn deinit(self: *Self) void {
        zstbi.deinit();
        zgui.backend.deinit();
        zgui.deinit();
        self.window.destroy();
        glfw.terminate();
    }

    pub fn onUpdate(self: *Self, callback: *const fn (self: *Self, user_data: *anyopaque) void, user_data: *anyopaque) void {
        self.update_callback = callback;
        self.update_user_data = user_data;
    }

    pub fn run(self: *Self) !void {
        const window = self.window;
        var state = &self.state;

        while (!window.shouldClose()) {
            //---UPDATE
            { // Update Time State
                const current_frame = @as(f32, @floatCast(glfw.getTime()));
                state.delta_time = current_frame - state.last_frame;
                state.last_frame = current_frame;
            }
            processInput(window);
            if (self.update_callback) |update| {
                if (self.update_user_data) |data| {
                    update(self, data);
                }
            }

            //---DRAW
            glfw.pollEvents();

            { // Clear
                gl.clearColor(
                    self.clear_color[0],
                    self.clear_color[1],
                    self.clear_color[2],
                    self.clear_color[3],
                );
                gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
            }

            {
                // RENDER HERE OPENGL
            }

            { // zgui
                const framebuffer_size = window.getFramebufferSize();

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

            window.swapBuffers();
        }
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

fn mouseCallback(window: *glfw.Window, xpos: f64, ypos: f64) callconv(.c) void {
    const pos_x: f32 = @floatCast(xpos);
    const pos_y: f32 = @floatCast(ypos);

    // Retrieve the instance from the user pointer
    const app = glfw.getWindowUserPointer(window, Application);
    var state = app.?.state;

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

fn processInput(window: *glfw.Window) callconv(.c) void {
    if (window.getKey(.escape) == .press) {
        window.setShouldClose(true);
    }
}
