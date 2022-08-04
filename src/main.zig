const std = @import("std");
const l = @import("lexer.zig");
const parser = @import("parser.zig");
pub fn main() void {
    const testing =
\\int main(int argc, char *argv[]) {
\\    for (int i=0; i < argc; i++) {
\\        puts(argv[i]);
\\    }
\\    return 0;
\\}
;
    var lexer = l.Lexer.init(testing);
    var token = lexer.next();
    while (token.tag != .eof) : (token = lexer.next()) {
        std.debug.print("parsed token [{s}] {s}\n", .{@tagName(token.tag), lexer.code[token.pos.start..token.pos.end]});
    }
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();

    var ast = parser.parse(alloc, testing) catch return;
    defer ast.deinit(alloc);
}