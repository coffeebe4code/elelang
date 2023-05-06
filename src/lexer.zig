const tokenizer = @import("./token.zig");
const Token = @import("./token.zig").Token;
const TokenError = @import("./token.zig").TokenError;
const Span = @import("./span.zig").Span;
const testing = @import("std").testing;
const std = @import("std");

pub const Lexer = struct {
    peeked: ?Span,
    buf: []const u8,
    curr: usize,

    pub fn new(buffer: []const u8) Lexer {
        return Lexer{
            .peeked = null,
            .buf = buffer,
            .curr = 0,
        };
    }

    pub fn collect_if_of(self: *Lexer, tokens: []const Token) TokenError!?Span {
        const peeked = try self.peek();
        if (peeked.*) |capture| {
            for (tokens) |tok| {
                if (capture.token == tok) {
                    return self.collect();
                }
            }
        }
        return null;
    }

    pub fn collect_if(self: *Lexer, token: Token) TokenError!?Span {
        const peeked = try self.peek();
        if (peeked.*) |capture| {
            if (capture.token == token) {
                return self.collect();
            }
        }
        return null;
    }

    pub fn collect(self: *Lexer) TokenError!?Span {
        const peeked = try self.peek();
        if (peeked.*) |capture| {
            self.curr += capture.slice.len;
            var tmp = capture;
            self.peeked = null;
            return tmp;
        }
        return null;
    }

    pub fn peek_seek(self: *Lexer) TokenError!*const ?Span {
        if (self.peeked != null) {
            return &self.peeked;
        }
        var len: usize = 0;
        if (self.curr != self.buf.len) {
            const token = try tokenizer.get_next_seek(self.buf[self.curr..], &len);
            self.peeked = Span{
                .slice = self.buf[self.curr .. self.curr + len],
                .token = token,
            };
        }
        return &self.peeked;
    }

    pub fn peek(self: *Lexer) TokenError!*const ?Span {
        if (self.peeked != null) {
            return &self.peeked;
        }
        var len: usize = 0;
        if (self.curr != self.buf.len) {
            const token = try tokenizer.get_next(self.buf[self.curr..], &len);
            self.peeked = Span{
                .slice = self.buf[self.curr .. self.curr + len],
                .token = token,
            };
        }
        return &self.peeked;
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

test "collect if of" {
    const buf = "const";
    var lex = Lexer.new(buf);

    var collect = try lex.collect_if_of(&[_]Token{ .Let, .Const });

    try testing.expect(std.mem.eql(u8, collect.?.slice, buf[0..5]));
    try testing.expect(collect.?.token == Token.Const);
}

test "collect if of" {
    const buf = "const";
    var lex = Lexer.new(buf);

    var collect = try lex.collect_if(Token.Const);

    try testing.expect(std.mem.eql(u8, collect.?.slice, buf[0..5]));
    try testing.expect(collect.?.token == Token.Const);
    collect = try lex.collect();
}

test "collect if" {
    const buf = "const";
    var lex = Lexer.new(buf);

    const peeked = try lex.peek();
    _ = peeked;
    var collect = try lex.collect_if(Token.Const);

    try testing.expect(std.mem.eql(u8, collect.?.slice, buf[0..5]));
    try testing.expect(collect.?.token == Token.Const);
}

test "peek and collect" {
    const buf = "let x = 5;";
    var lex = Lexer.new(buf);

    try testing.expect((try lex.peek()).*.?.token == Token.Let);
    var collect = try lex.collect();

    try testing.expect(std.mem.eql(u8, collect.?.slice, buf[0..3]));
    try testing.expect(collect.?.token == Token.Let);

    try testing.expect((try lex.peek()).*.?.token == Token.Wsp);
    collect = try lex.collect();

    try testing.expect(std.mem.eql(u8, collect.?.slice, buf[3..4]));
    try testing.expect(collect.?.token == Token.Wsp);

    try testing.expect((try lex.peek()).*.?.token == Token.Symbol);
    collect = try lex.collect();

    try testing.expect(std.mem.eql(u8, collect.?.slice, buf[4..5]));
    try testing.expect(collect.?.token == Token.Symbol);

    _ = try lex.peek();
    collect = try lex.collect();

    var peeked = (try lex.peek()).*.?;

    try testing.expect(peeked.token == Token.As);
    collect = try lex.collect();

    try testing.expect(std.mem.eql(u8, collect.?.slice, buf[6..7]));
    try testing.expect(collect.?.token == Token.As);

    _ = try lex.peek();
    collect = try lex.collect();

    peeked = (try lex.peek()).*.?;

    try testing.expect(peeked.token == Token.Num);
    collect = try lex.collect();

    try testing.expect(std.mem.eql(u8, collect.?.slice, buf[8..9]));
    try testing.expect(collect.?.token == Token.Num);

    try testing.expect((try lex.peek()).*.?.token == Token.SColon);
    collect = try lex.collect();

    try testing.expect(std.mem.eql(u8, collect.?.slice, buf[9..10]));
    try testing.expect(collect.?.token == Token.SColon);
}
