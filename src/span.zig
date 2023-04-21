const Token = @import("./token.zig").Token;

pub const Span = struct {
    slice: []const u8,
};

pub const FullSpan = struct {
    slice: []const u8,
    pos: usize,
    col: usize,
    row: usize,
};
