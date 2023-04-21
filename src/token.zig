const std = @import("std");
const ascii = @import("std").ascii;
const testing = std.testing;

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
    WString,
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
    WBox,
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
    Suspend,
    Resume,
    Block,
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
    Range,
};

pub fn get_next(buf: []const u8, len: *usize) anyerror!?Token {
    len.* = 0;
    const c = buf.*;
    if (ascii.isAlphabetic(c)) {
        len.* += 1;
        tokenize_chars(buf, len);
    } else if (ascii.isDigit(c)) {} else {
        return switch (c) {
            ' ' => {
                skip_whitespace();
                return .Wsp;
            },
        };
    }
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

inline fn tokenize_chars(buf: []const u8, len: *usize) void {
    var token = undefined;
    len.* = word_len_check(buf, len);
    token = .Symbol;
    for (keywords) |word| {
        if (word.len == len.*) {
            if (std.mem.eql([]u8, word, buf[0 .. len.* - 1])) {}
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

const keywords = [_]u8{
    "import",
    "define",
    "macro",
    "test",
    "bench",
    "mut",
    "let",
    "const",
    "once",
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
    "gen",
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
