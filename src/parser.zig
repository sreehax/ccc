const std = @import("std");
const lexer = @import("lexer.zig");

pub const TokenContainer = struct {
    tag: lexer.Token.LexTag,
    start: u32
};
pub const AstTag = enum { todo };
pub const AstNode = struct {
    tag: AstTag,
    token: u32,
    info: struct {
        lhs: u32,
        rhs: u32
    }
};
pub const TokenList = std.MultiArrayList(TokenContainer);
pub const AstNodeList = std.MultiArrayList(AstNode);

pub const AstContainer = struct {
    code: [*:0]const u8,
    tokens: TokenList.Slice,
    // nodes: AstNodeList.Slice,

    pub fn deinit(self: *AstContainer, alloc: std.mem.Allocator) void {
        self.tokens.deinit(alloc);
        // self.nodes.deinit(alloc);
        self.* = undefined;
    }
};

pub fn parse(alloc: std.mem.Allocator, code: [*:0]const u8) !AstContainer {
    var tokens = TokenList{};
    defer tokens.deinit(alloc);

    var lex = lexer.Lexer.init(code);
    while (true) {
        const tok = lex.next();
        try tokens.append(alloc, .{
            .tag = tok.tag,
            .start = @intCast(u32, tok.pos.start)
        });
        if (tok.tag == .eof) break;
    }

    return AstContainer {
        .code = code,
        .tokens = tokens.toOwnedSlice(),
        // .nodes = undefined
    };
}