const std = @import("std");
const t = @import("tokenizer.zig");
pub fn main() void {
    const testing = \\
\\unsigned char *testing1234(int argc, char *argv[]) {
\\    while (argc != 0) {
\\        puts(argv[argc--]);
\\    }
\\    return NULL;
\\}
;
    var tok = t.Tokenizer.init(testing);
    var token = tok.next();
    while (token.tag != .eof) : (token = tok.next()) {
        std.debug.print("parsed token [{s}] {s}\n", .{@tagName(token.tag), tok.code[token.pos.start..token.pos.end]});
    }
}