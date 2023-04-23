const token = @import("./token.zig").Token;

pub const Span = struct {
    slice: []const u8,
    token: token.Token,
};

pub const FullSpan = struct {
    slice: []const u8,
    token: token.Token,
    pos: usize,
    col: usize,
    row: usize,
};
