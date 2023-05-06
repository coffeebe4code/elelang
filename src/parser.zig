const Token = @import("./token.zig").Token;
const TokenError = @import("./token.zig").TokenError;
const Lexer = @import("./lexer.zig").Lexer;
const Ast = @import("./ast.zig").Ast;
const Span = @import("./span.zig").Span;
const AstTag = @import("./ast.zig").AstTag;
const Allocator = @import("std").mem.Allocator;
const std = @import("std");
const testing = @import("std").testing;

const ParserError = error{
    InvalidExpectedToken,
};

const Parser = struct {
    lexer: Lexer,
    asts: []Ast,

    pub fn init(lexer: *Lexer, allocator: Allocator) Parser {
        return Parser{
            .lexer = lexer,
            .asts = std.ArrayList(Ast).initCapacity(allocator, 100),
        };
    }

    pub fn deinit(self: *Parser) void {
        self.asts.deinit();
    }

    pub fn num(self: *Parser) TokenError!?*Ast {
        const span = try self.lexer.collect_if(Token.Num);
        if (span) |capture| {
            const ast = Ast.make_num(capture);

            try self.asts.append(ast);
            return &self.asts[self.asts.Slice.len - 1];
        }
        return null;
    }
};

test "parse num" {
    const buf = "5";
    var lex = Lexer.new(buf);
    var parser = Parser.init(lex, std.testing.allocator);
    defer parser.deinit();
    const result = try parser.num();

    try testing.expect(result.?.* == Ast{
        .num = Span{
            .slice = "5",
            .token = Token.Num,
        },
    });
}
