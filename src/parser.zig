const Token = @import("./token.zig").Token;
const TokenError = @import("./token.zig").TokenError;
const Lexer = @import("./lexer.zig").Lexer;
const Ast = @import("./ast.zig").Ast;
const ast = @import("./ast.zig");
const Span = @import("./span.zig").Span;
const AstTag = @import("./ast.zig").AstTag;
const Allocator = @import("std").mem.Allocator;
const std = @import("std");
const ArrayList = @import("std").ArrayList;
const testing = @import("std").testing;

const stdout = std.io.getStdOut().writer();

const ParserError = error{
    InvalidExpectedToken,
    ExpectedOneOfFound,
};

const Parser = struct {
    lexer: Lexer,
    asts: ArrayList(Ast),

    pub fn init(lexer: Lexer, allocator: Allocator) anyerror!Parser {
        var asts: ArrayList(Ast) = std.ArrayList(Ast).init(allocator);
        return Parser{
            .lexer = lexer,
            .asts = asts,
        };
    }

    pub fn deinit(self: *Parser) void {
        self.asts.deinit();
    }

    pub fn parse_low_bin(self: *Parser) anyerror!?*Ast {
        const mb_left = try self.parse_high_bin();
        if (mb_left) |left| {
            const mb_bin = try self.lexer.collect_if_of(&[2]Token{ Token.Mul, Token.Div, Token.Mod });
            const bin = try expect_some_val(mb_bin, "low_bin");
            const right = try expect_some_val(try self.high_bin());
            const local = ast.make_binop(left, bin, right);

            try self.asts.append(local);
            return &self.asts.items[self.asts.items.len - 1];
        }
        return null;
    }

    pub fn parse_high_bin(self: *Parser) anyerror!?*Ast {
        const mb_left = try self.unary();
        if (mb_left) |left| {
            const mb_bin = try self.lexer.collect_if_of(&[2]Token{ Token.Plus, Token.Sub });
            const bin = try expect_some_val(mb_bin, "high_bin");
            const right = try expect_some_val(try self.unary());
            const local = ast.make_binop(left, bin, right);
            try self.asts.append(local);
            return &self.asts.items[self.asts.items.len - 1];
        }
        return null;
    }

    pub fn unary(self: *Parser) anyerror!?*Ast {
        const span = try self.lexer.collect_if_of(&[2]Token{ Token.Plus, Token.Sub });
        if (span) |capture| {
            const rhs = try expect_some_val(try self.unary(), "unary");
            const local = ast.make_unop(rhs, capture);
            try self.asts.append(local);
            return &self.asts.items[self.asts.items.len - 1];
        }
        return try self.parse_num();
    }

    pub fn parse_num(self: *Parser) anyerror!?*Ast {
        const span = try self.lexer.collect_if(Token.Num);
        if (span) |capture| {
            const local = ast.make_num(capture);
            try self.asts.append(local);
            return &self.asts.items[self.asts.items.len - 1];
        }
        return null;
    }
};

fn expect_some_val(expr: anyerror!?*Ast, message: []const u8) anyerror!*Ast {
    return expr catch {
        try stdout.print("{s}\n", .{message});
        return ParserError.ExpectedOneOfFound;
    } orelse {
        try stdout.print("{s}\n", .{message});
        return ParserError.ExpectedOneOfFound;
    };
}

test "parse high bin" {
    const buf = "5 + 5";
    const lex = Lexer.new(buf, .{ .skip = true });
    var parser = try Parser.init(lex, std.testing.allocator);
    defer parser.deinit();
    const result = try parser.parse_high_bin();
    const left = result.?.*.BinOp[0].*.Num;
    const op = result.?.*.BinOp[1];
    const right = result.?.*.BinOp[0].*.Num;

    try testing.expect(std.mem.eql(u8, left.slice, buf[0..1]));
    try testing.expect(op.token == Token.Plus);
    try testing.expect(std.mem.eql(u8, right.slice, buf[4..5]));
}

test "parse num" {
    const buf = "5";
    const lex = Lexer.new(buf, .{});
    var parser = try Parser.init(lex, std.testing.allocator);
    defer parser.deinit();
    const result = try parser.parse_num();

    try testing.expect(result.?.*.Num.token == Token.Num);
}
