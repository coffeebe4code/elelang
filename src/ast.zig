const Token = @import("./token.zig").Token;
const Span = @import("./span.zig").Span;

pub const AstTag = enum {
    BinOp,
    UnOp,
    Ident,
};

pub const Ast = union(AstTag) {
    binop: .{ *Ast, Token, *Ast },
    unop: .{ *Ast, Token },
    ident: .{*Span},
    num: .{*Span},
};

pub fn make_binop(left: *Ast, op: Token, right: *Ast) Ast {
    return Ast{
        .binop = .{ left, op, right },
    };
}

pub fn make_unop(expr: *Ast, op: Token) Ast {
    return Ast{
        .unop = .{ expr, op },
    };
}

pub fn make_ident(span: *Span) Ast {
    return Ast{
        .ident = .{span},
    };
}

pub fn make_num(span: *Span) Ast {
    return Ast{
        .num = .{span},
    };
}
