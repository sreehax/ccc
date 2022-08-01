const std = @import("std");
const Tokenizer = @import("Tokenizer.zig");
pub fn main() void {
    const testing = "unsigned char *ptr = 1;";
    var tok = Tokenizer.init(testing);
    var token = tok.next();
    while (token.tag != .eof) : (token = tok.next()) {
        std.debug.print("{}: {s}\n", .{token.tag, tok.code[token.pos.start..token.pos.end]});
    }
}
