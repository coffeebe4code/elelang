const std = @import("std");
const ascii = @import("std").ascii;
const testing = std.testing;

const TokenError = error{
    InvalidToken,
};

pub const Token = enum(u8) {
    Import,
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

pub fn get_next(buf: []const u8, len: *usize) anyerror!?Token {
    len.* = 0;
    const c = buf[0];
    if (ascii.isAlphabetic(c)) {
        return tokenize_chars(buf, len);
    } else if (ascii.isDigit(c)) {} else {
        return switch (c) {
            ' ' => {
                len.* += skip_whitespace(buf);
                return Token.Wsp;
            },
            else => {
                return TokenError.InvalidToken;
            },
        };
    }
    return TokenError.InvalidToken;
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
    std.debug.print("check {s}\n", .{check});
    for (keywords, 0..) |word, idx| {
        if (word.len == len.*) {
            if (std.mem.eql(u8, word, check)) {
                std.debug.print("match {s}\n", .{word});
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
    try testing.expect(tok.? == Token.Wsp);
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

    std.debug.print("result {}\n", .{tok});
    try testing.expect(len == 6);
    std.debug.print("result {}\n", .{tok});
    try testing.expect(tok == Token.Export);
    std.debug.print("result {}\n", .{tok});
}
