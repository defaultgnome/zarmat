const std = @import("std");
const sokol = @import("sokol");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const sokol_dep = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
    });

    const sokol_mod = sokol_dep.module("sokol");

    const shdc_dep = sokol_dep.builder.dependency("shdc", .{});
    const shader_mod = try sokol.shdc.createModule(b, "shader", sokol_mod, .{
        .shdc_dep = shdc_dep,
        .input = "src/shader.glsl",
        .output = "shader.zig",
        .slang = .{
            .glsl410 = true,
            .hlsl4 = true,
            .metal_macos = true,
        },
    });

    const game_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    game_mod.addImport("sokol", sokol_mod);
    game_mod.addImport("shader", shader_mod);

    const game_exe = b.addExecutable(.{
        .name = "zarmat",
        .root_module = game_mod,
    });

    b.installArtifact(game_exe);

    const run_cmd = b.addRunArtifact(game_exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the game");
    run_step.dependOn(&run_cmd.step);

    const game_unit_tests = b.addTest(.{
        .root_module = game_mod,
    });

    const run_game_unit_tests = b.addRunArtifact(game_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_game_unit_tests.step);
}
