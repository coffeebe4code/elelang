const tokenizer = @import("./token.zig");
const Token = @import("./token.zig").Token;
const TokenError = @import("./token.zig").TokenError;
const Span = @import("./span.zig").Span;

const LexerError = error{
    InvalidCollectOnNull,
};

pub const Lexer = struct {
    peeked: ?Span,
    buf: []const u8,
    curr: usize,

    pub fn lexer_init(buffer: []const u8) Lexer {
        return Lexer{
            null,
            buffer,
            0,
        };
    }

    pub fn collect_if(self: Lexer, token: Token) anyerror!?Span {
        _ = token;
        if (self.peeked) |capture| {
            self.curr += capture.len;
            var tmp = capture;
            self.peeked = null;
            return tmp;
        }
        return LexerError.InvalidCollectOnNull;
    }

    pub fn collect(self: Lexer) LexerError!Span {
        if (self.peeked) |capture| {
            self.curr += capture.len;
            var tmp = capture;
            self.peeked = null;
            return tmp;
        }
        return LexerError.InvalidCollectOnNull;
    }

    pub fn peek(self: Lexer) TokenError!?*Span {
        if (!self.peeked) {
            return &self.peeked;
        }
        const len = 0;
        const token = try tokenizer.get_next(self.buf[self.curr], &len);
        if (!token) {
            self.peeked = null;
        } else {
            self.peeked = Span{
                .slice = self.buf[self.curr .. self.curr + len],
                .token = token.?,
            };
        }
        return &self.peeked;
    }

    pub fn has_token_consume(self: Lexer, token: Token) TokenError!bool {
        if (try self.peek()) |peeked| {
            if (peeked.token == token) {
                return true;
            }
        }
        return false;
    }
};
