const tokenizer = @import("./token.zig");
const Token = @import("./token.zig").Token;
const TokenError = @import("./token.zig").TokenError;
const Span = @import("./span.zig").Span;
const testing = @import("std").testing;
const std = @import("std");

const LexerError = error{
    InvalidCollectOnNull,
};

const Lexer = struct {
    curr_peek: ?Span,
    buf: []const u8,
    curr: usize,

    pub fn new(buffer: []const u8) Lexer {
        return Lexer{
            .curr_peek = null,
            .buf = buffer,
            .curr = 0,
        };
    }

    pub fn collect_if(self: Lexer, token: Token) anyerror!?Span {
        _ = token;
        if (self.curr_peek) |capture| {
            self.curr += capture.len;
            var tmp = capture;
            self.curr_peek = null;
            return tmp;
        }
        return LexerError.InvalidCollectOnNull;
    }

    pub fn collect(self: Lexer) LexerError!Span {
        if (self.curr_peek) |capture| {
            self.curr += capture.len;
            var tmp = capture;
            self.curr_peek = null;
            return tmp;
        }
        return LexerError.InvalidCollectOnNull;
    }

    pub fn peek(self: Lexer) TokenError!*const ?Span {
        if (self.curr_peek != null) {
            return &self.curr_peek;
        }
        var len: usize = 0;
        if (self.curr != self.buf.len - 1) {
            const token = try tokenizer.get_next(self.buf[self.curr..], &len);
            self.curr_peek = Span{
                .slice = self.buf[self.curr .. self.curr + len],
                .token = token.?,
            };
        }
        return &self.curr_peek;
    }

    pub fn has_token_consume(self: Lexer, token: Token) TokenError!bool {
        if (try self.peek()) |capture| {
            if (capture.token == token) {
                return true;
            }
        }
        return false;
    }
};

test "peek and collect" {
    const buf = "let x = 5;";
    var lex = Lexer.new(buf);
    var span = try lex.peek();

    try testing.expect(std.mem.eql(u8, span.*.?.slice, buf));
    try testing.expect(span.*.?.token == Token.Let);
}
