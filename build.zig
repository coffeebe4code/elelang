const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
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

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
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

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build test`
    // This will evaluate the `test` step rather than the default, which is "install".
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_token_tests.step);
    test_step.dependOn(&run_lexer_tests.step);
}
