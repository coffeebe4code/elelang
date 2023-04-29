const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const token = b.addStaticLibrary(.{
        .name = "token",
        .root_source_file = .{ .path = "src/token.zig" },
        .target = target,
        .optimize = optimize,
    });

    const span = b.addStaticLibrary(.{
        .name = "span",
        .root_source_file = .{ .path = "src/span.zig" },
        .target = target,
        .optimize = optimize,
    });

    const lexer = b.addStaticLibrary(.{
        .name = "lexer",
        .root_source_file = .{ .path = "src/lexer.zig" },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(token);
    b.installArtifact(span);
    b.installArtifact(lexer);

    const token_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/token.zig" },
        .target = target,
        .optimize = optimize,
    });
    const lexer_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/lexer.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_token_tests = b.addRunArtifact(token_tests);
    const run_lexer_tests = b.addRunArtifact(lexer_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_token_tests.step);
    test_step.dependOn(&run_lexer_tests.step);
}
