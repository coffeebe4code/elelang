const std = @import("std");

const count = 3;

const names = [count][]const u8{ "token", "span", "lexer" };
const files = [count][]const u8{ "src/token.zig", "src/span.zig", "src/lexer.zig" };

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    for (0..count) |i| {
        const s_lib = b.addStaticLibrary(.{
            .name = names[i],
            .root_source_file = .{ .path = files[i] },
            .target = target,
            .optimize = optimize,
        });

        b.installArtifact(s_lib);

        const s_tests = b.addTest(.{
            .root_source_file = .{ .path = files[i] },
            .target = target,
            .optimize = optimize,
        });

        const run_tests = b.addRunArtifact(s_tests);

        const test_step = b.step(files[i], "Run library tests");
        test_step.dependOn(&run_tests.step);
    }
}
