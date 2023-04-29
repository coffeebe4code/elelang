const std = @import("std");
const ascii = @import("std").ascii;
const testing = std.testing;

pub const TokenError = error{
    InvalidToken,
};

pub const Token = enum(u8) {
    Import,
    Use,
    Define,
    Macro,
    Test,
    Bench,
    Mut,
    Let,
    Const,
    Once,
    Local,
    Num,
    I32,
    U32,
    U64,
    I64,
    I16,
    U16,
    U8,
    I8,
    Bit,
    F64,
    F32,
    D32,
    D64,
    If,
    Else,
    Type,
    This,
    Null,
    Char,
    String,
    Inline,
    Static,
    Switch,
    For,
    In,
    Break,
    Enum,
    Pub,
    Return,
    Async,
    Await,
    Box,
    Trait,
    Ptr,
    Match,
    Addr,
    Vol,
    True,
    False,
    Void,
    Iface,
    Gen,
    Undef,
    Never,
    Bool,
    Byte,
    Fn,
    Contract,
    Queue,
    Thread,
    Pool,
    Observe,
    Message,
    Block,
    Suspend,
    Resume,
    Export,
    OParen,
    CParen,
    OBrace,
    CBrace,
    OArray,
    CArray,
    Dot,
    Comma,
    Dollar,
    Question,
    Pound,
    Colon,
    SColon,
    Backtick,
    At,
    Lt,
    LtEq,
    Gt,
    GtEq,
    Div,
    BSlash,
    Plus,
    Rest,
    Sub,
    Mul,
    Or,
    And,
    Xor,
    LShift,
    RShift,
    Not,
    As,
    NotAs,
    OrAs,
    AndAs,
    XorAs,
    LShiftAs,
    RShiftAs,
    AndLog,
    OrLog,
    NotEquality,
    Equality,
    NotLog,
    Mod,
    Inc,
    Dec,
    AddAs,
    SubAs,
    DivAs,
    MulAs,
    ModAs,
    DQuote,
    SQuote,
    Symbol,
    Hex,
    Bin,
    Decimal,
    NewLine,
    Wsp,
    Range,
};

pub fn get_next(buf: []const u8, len: *usize) TokenError!Token {
    len.* = 0;
    const c = buf[0];
    if (ascii.isAlphabetic(c)) {
        return tokenize_chars(buf, len);
    } else if (ascii.isDigit(c)) {
        return Token.Num;
    } else {
        return switch (c) {
            ' ' => {
                len.* += skip_whitespace(buf);
                return Token.Wsp;
            },
            '"' => {
                len.* += skip_whitespace(buf);
                return Token.Wsp;
            },
            '\'' => {
                len.* += skip_whitespace(buf);
                return Token.Wsp;
            },
            '(' => {
                len.* += 1;
                return Token.OParen;
            },
            ')' => {
                len.* += 1;
                return Token.CParen;
            },
            '{' => {
                len.* += 1;
                return Token.OBrace;
            },
            '}' => {
                len.* += 1;
                return Token.CBrace;
            },
            '[' => {
                len.* += 1;
                return Token.OArray;
            },
            ']' => {
                len.* += 1;
                return Token.CArray;
            },
            '.' => {
                len.* += 1;
                return Token.Dot;
            },
            ',' => {
                len.* += 1;
                return Token.Comma;
            },
            '$' => {
                len.* += 1;
                return Token.Dollar;
            },
            '?' => {
                len.* += 1;
                return Token.Question;
            },
            '#' => {
                len.* += 1;
                return Token.Pound;
            },
            ':' => {
                len.* += 1;
                return Token.Colon;
            },
            ';' => {
                len.* += 1;
                return Token.SColon;
            },
            '\\' => {
                len.* += 1;
                return Token.BSlash;
            },
            '`' => {
                len.* += 1;
                return Token.Backtick;
            },
            '_' => {
                len.* += 1;
                return Token.Rest;
            },
            '@' => {
                len.* += 1;
                return Token.At;
            },
            '>' => {
                len.* += skip_whitespace(buf);
                return Token.Gt;
            },
            '|' => {
                return tokenize_two(buf, len, Token.OrLog, '=', Token.OrAs, '|', Token.Or);
            },
            '&' => {
                return tokenize_two(buf, len, Token.AndLog, '&', Token.And, '=', Token.AndAs);
            },
            '<' => {
                len.* += skip_whitespace(buf);
                return Token.Lt;
            },
            '+' => {
                return tokenize_two(buf, len, Token.Plus, '+', Token.Inc, '=', Token.AddAs);
            },
            '-' => {
                return tokenize_two(buf, len, Token.Sub, '-', Token.Dec, '=', Token.SubAs);
            },
            '/' => {
                return tokenize_one(buf, len, Token.Div, '=', Token.DivAs);
            },
            '*' => {
                return tokenize_one(buf, len, Token.Mul, '=', Token.MulAs);
            },
            '^' => {
                return tokenize_one(buf, len, Token.Xor, '=', Token.XorAs);
            },
            '!' => {
                return tokenize_one(buf, len, Token.Not, '=', Token.NotEquality);
            },
            '%' => {
                return tokenize_one(buf, len, Token.Mod, '=', Token.ModAs);
            },
            '~' => {
                return tokenize_one(buf, len, Token.NotLog, '=', Token.NotAs);
            },
            '=' => {
                return tokenize_one(buf, len, Token.As, '=', Token.Equality);
            },
            '\r' => {
                if (buf.len > 2) {
                    if (buf[1] == '\n') {
                        len.* = 2;
                        return Token.NewLine;
                    }
                }
                len.* = 1;
                return TokenError.InvalidToken;
            },
            '\n' => {
                len.* += 1;
                return Token.NewLine;
            },
            else => {
                return TokenError.InvalidToken;
            },
        };
    }
}

inline fn tokenize_one(
    buf: []const u8,
    len: *usize,
    def_tok: Token,
    comp: u8,
    comp_tok: Token,
) Token {
    if (buf.len > 2) {
        if (buf[1] == comp) {
            len.* = 2;
            return comp_tok;
        }
    }
    len.* = 1;
    return def_tok;
}

inline fn tokenize_two(
    buf: []const u8,
    len: *usize,
    def_tok: Token,
    comp1: u8,
    comp1_tok: Token,
    comp2: u8,
    comp2_tok: Token,
) Token {
    if (buf.len > 2) {
        if (buf[1] == comp1) {
            len.* = 2;
            return comp1_tok;
        } else if (buf[1] == comp2) {
            len.* = 2;
            return comp2_tok;
        }
    }
    len.* = 1;
    return def_tok;
}

inline fn word_len_check(buf: []const u8) usize {
    var len: usize = 1;
    while (buf.len != len) {
        const c = buf[len];
        if (ascii.isAlphabetic(c)) {
            len += 1;
        } else {
            switch (c) {
                '_', '-' => {
                    len += 1;
                },
                else => {
                    break;
                },
            }
        }
    }
    return len;
}

inline fn tokenize_chars(buf: []const u8, len: *usize) Token {
    var token: Token = undefined;
    len.* = word_len_check(buf);
    token = .Symbol;
    var check = buf[0..len.*];
    for (keywords, 0..) |word, idx| {
        if (word.len == len.*) {
            if (std.mem.eql(u8, word, check)) {
                token = @intToEnum(Token, idx);
                return token;
            }
        }
    }
    return token;
}

inline fn skip_whitespace(buf: []const u8) usize {
    var len: usize = 1;
    while (buf.len != len) {
        const c = buf[len];
        if (c == ' ') {
            len += 1;
        } else {
            break;
        }
    }
    return len;
}

const keywords = [_][]const u8{
    "import",
    "use",
    "define",
    "macro",
    "test",
    "bench",
    "mut",
    "let",
    "const",
    "once",
    "local",
    "num",
    "i32",
    "u32",
    "u64",
    "i64",
    "i16",
    "u16",
    "u8",
    "i8",
    "bit",
    "f64",
    "f32",
    "d32",
    "d64",
    "if",
    "else",
    "type",
    "this",
    "null",
    "char",
    "string",
    "inline",
    "static",
    "switch",
    "for",
    "in",
    "break",
    "enum",
    "pub",
    "return",
    "async",
    "await",
    "box",
    "trait",
    "ptr",
    "match",
    "addr",
    "vol",
    "true",
    "false",
    "void",
    "iface",
    "generic",
    "undef",
    "never",
    "bool",
    "byte",
    "fn",
    "contract",
    "queue",
    "thread",
    "pool",
    "observe",
    "message",
    "block",
    "suspend",
    "resume",
    "export",
};

test "word len check regular" {
    const buf = "hello";
    const len = word_len_check(buf);

    try testing.expect(len == 5);
}

test "word len check _" {
    const buf = "hello_there";
    const len = word_len_check(buf);

    try testing.expect(len == 11);
}

test "word len check -" {
    const buf = "hello-there ";
    const len = word_len_check(buf);

    try testing.expect(len == 11);
}

test "skip whitespace" {
    const buf = "     hello";
    var len: usize = undefined;
    const tok = try get_next(buf, &len);

    try testing.expect(len == 5);
    try testing.expect(tok == Token.Wsp);
}

test "keywords tokens" {
    var buf: []const u8 = "macro";
    var len: usize = 0;
    var tok = tokenize_chars(buf, &len);

    try testing.expect(len == 5);
    try testing.expect(tok == Token.Macro);

    buf = "const";
    len = 0;
    tok = tokenize_chars(buf, &len);

    try testing.expect(len == 5);
    try testing.expect(tok == Token.Const);

    buf = "local";
    len = 0;
    tok = tokenize_chars(buf, &len);

    try testing.expect(len == 5);
    try testing.expect(tok == Token.Local);

    buf = "true";
    len = 0;
    tok = tokenize_chars(buf, &len);

    try testing.expect(len == 4);
    try testing.expect(tok == Token.True);

    buf = "string";
    len = 0;
    tok = tokenize_chars(buf, &len);

    try testing.expect(len == 6);
    try testing.expect(tok == Token.String);

    buf = "pub";
    len = 0;
    tok = tokenize_chars(buf, &len);

    try testing.expect(len == 3);
    try testing.expect(tok == Token.Pub);

    buf = "resume";
    len = 0;
    tok = tokenize_chars(buf, &len);

    try testing.expect(len == 6);
    try testing.expect(tok == Token.Resume);

    buf = "export";
    len = 0;
    tok = tokenize_chars(buf, &len);

    try testing.expect(len == 6);
    try testing.expect(tok == Token.Export);
}

test "get next singular" {
    var buf: []const u8 = "(){}[].,$?#:;_\\`@";
    var len: usize = 0;
    var tok = try get_next(buf, &len);

    try testing.expect(len == 1);
    try testing.expect(tok == Token.OParen);

    len = 0;
    tok = try get_next(buf[1..], &len);

    try testing.expect(len == 1);
    try testing.expect(tok == Token.CParen);

    len = 0;
    tok = try get_next(buf[2..], &len);

    try testing.expect(len == 1);
    try testing.expect(tok == Token.OBrace);

    len = 0;
    tok = try get_next(buf[3..], &len);

    try testing.expect(len == 1);
    try testing.expect(tok == Token.CBrace);

    len = 0;
    tok = try get_next(buf[4..], &len);

    try testing.expect(len == 1);
    try testing.expect(tok == Token.OArray);

    len = 0;
    tok = try get_next(buf[5..], &len);

    try testing.expect(len == 1);
    try testing.expect(tok == Token.CArray);

    len = 0;
    tok = try get_next(buf[6..], &len);

    try testing.expect(len == 1);
    try testing.expect(tok == Token.Dot);

    len = 0;
    tok = try get_next(buf[7..], &len);

    try testing.expect(len == 1);
    try testing.expect(tok == Token.Comma);

    len = 0;
    tok = try get_next(buf[8..], &len);

    try testing.expect(len == 1);
    try testing.expect(tok == Token.Dollar);

    len = 0;
    tok = try get_next(buf[9..], &len);

    try testing.expect(len == 1);
    try testing.expect(tok == Token.Question);

    len = 0;
    tok = try get_next(buf[10..], &len);

    try testing.expect(len == 1);
    try testing.expect(tok == Token.Pound);

    len = 0;
    tok = try get_next(buf[11..], &len);

    try testing.expect(len == 1);
    try testing.expect(tok == Token.Colon);

    len = 0;
    tok = try get_next(buf[12..], &len);

    try testing.expect(len == 1);
    try testing.expect(tok == Token.SColon);

    len = 0;
    tok = try get_next(buf[13..], &len);

    try testing.expect(len == 1);
    try testing.expect(tok == Token.Rest);

    len = 0;
    tok = try get_next(buf[14..], &len);

    try testing.expect(len == 1);
    try testing.expect(tok == Token.BSlash);

    len = 0;
    tok = try get_next(buf[15..], &len);

    try testing.expect(len == 1);
    try testing.expect(tok == Token.Backtick);

    len = 0;
    tok = try get_next(buf[16..], &len);

    try testing.expect(len == 1);
    try testing.expect(tok == Token.At);
}
