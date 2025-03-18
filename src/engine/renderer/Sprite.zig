const std = @import("std");
const gl = @import("zopengl").bindings;

const glLogErrors = @import("opengl.zig").glLogErrors;
const Program = @import("Program.zig").Program;
const Texture2D = @import("Texture2D.zig").Texture2D;

pub const Sprite = struct {
    const Self = @This();

    vao: gl.Uint,
    vbo: gl.Uint,
    ebo: gl.Uint,
    program: Program,
    tex: Texture2D,

    pub fn init(allocator: std.mem.Allocator, sprite_path: [:0]const u8) !Self {
        var vao: gl.Uint = undefined;
        gl.genVertexArrays(1, &vao);

        var buffers = [2]gl.Uint{ undefined, undefined };
        gl.genBuffers(2, &buffers[0]);
        const vbo: gl.Uint = buffers[0];
        const ebo: gl.Uint = buffers[1];

        gl.bindVertexArray(vao);
        gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo);

        // zig fmt: off
        const vertices = [_]gl.Float {
            // positions  // tex coords
            -0.5, -0.5,   0.0, 0.0, // left-down
            -0.5,  0.5,   0.0, 1.0, // left-up
             0.5, -0.5,   1.0, 0.0, // right-down
             0.5,  0.5,   1.0, 1.0, // right-up
        };

        const indices = [_]gl.Uint {
            0, 1, 2,
            1, 2, 3,
        };
        // zig fmt: on

        gl.bufferData(
            gl.ARRAY_BUFFER,
            @intCast(@sizeOf(gl.Float) * vertices.len),
            &vertices,
            gl.STATIC_DRAW,
        );
        gl.bufferData(
            gl.ELEMENT_ARRAY_BUFFER,
            @intCast(@sizeOf(gl.Uint) * indices.len),
            &indices,
            gl.STATIC_DRAW,
        );

        gl.vertexAttribPointer(
            0,
            2,
            gl.FLOAT,
            gl.FALSE,
            4 * @sizeOf(gl.Float),
            @ptrFromInt(0),
        );
        gl.enableVertexAttribArray(0);
        gl.vertexAttribPointer(
            1,
            2,
            gl.FLOAT,
            gl.FALSE,
            4 * @sizeOf(gl.Float),
            @ptrFromInt(2 * @sizeOf(gl.Float)),
        );
        gl.enableVertexAttribArray(1);

        const program = try Program.init(
            allocator,
            "./src/engine/renderer/shaders/default.vert.glsl",
            "./src/engine/renderer/shaders/default.frag.glsl",
        );
        glLogErrors(@src());

        const tex = try Texture2D.init(sprite_path, .RGBA);
        gl.activeTexture(gl.TEXTURE0);

        gl.bindVertexArray(0);
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);
        gl.bindBuffer(gl.ARRAY_BUFFER, 0);
        Texture2D.unbind();

        return Self{
            .vao = vao,
            .vbo = vbo,
            .ebo = ebo,
            .program = program,
            .tex = tex,
        };
    }

    pub fn deinit(self: *Self) void {
        const buffers = [2]gl.Uint{ self.vbo, self.ebo };
        gl.deleteBuffers(2, &buffers[0]);
        gl.deleteVertexArrays(1, &self.vao);
        self.program.deinit();
        self.tex.deinit();
    }

    pub fn render(self: *Self) void {
        // Both line are importatnt for transperent stuff
        gl.enable(gl.BLEND);
        gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
        self.tex.bind();

        self.program.use();
        defer gl.useProgram(0);
        self.program.setInt("tex", 0);

        gl.bindVertexArray(self.vao);
        defer gl.bindVertexArray(0);

        gl.drawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, @ptrFromInt(0));
    }
};
