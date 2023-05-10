const Token = @import("./token.zig").Token;
const Span = @import("./span.zig").Span;

pub const AstTag = enum {
    BinOp,
    UnOp,
    Ident,
    Num,
};

pub const Ast = union(AstTag) {
    BinOp: struct { *Ast, Span, *Ast },
    UnOp: struct { *Ast, Span },
    Ident: Span,
    Num: Span,
};

pub fn make_binop(left: *Ast, op: Span, right: *Ast) Ast {
    return Ast{
        .BinOp = .{ left, op, right },
    };
}

pub fn make_unop(expr: *Ast, op: Span) Ast {
    return Ast{
        .UnOp = .{ expr, op },
    };
}

pub fn make_ident(span: *Span) Ast {
    return Ast{
        .Ident = span,
    };
}

pub fn make_num(span: Span) Ast {
    return Ast{
        .Num = span,
    };
}
