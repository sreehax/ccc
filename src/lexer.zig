const std = @import("std");

/// this is a doc comment
pub const Lexer = struct {
    code: [*:0]const u8,
    idx: usize,

    const Self = @This();
    pub fn next(self: *Self) Token {
        var state: State = .default;
        var ret = Token {
            .tag = .eof,
            .pos = .{ .start = self.idx, .end = undefined }
        };
        while (true) : (self.idx += 1) {
            const c = self.code[self.idx];
            switch (state) {
                .default => switch (c) {
                    0 => break,
                    '_', 'a'...'z', 'A'...'Z' => {
                        state = .identifier;
                        ret.tag = .identifier;
                    },
                    '~' => {
                        ret.tag = .op_bitnot;
                        self.idx += 1;
                        break;
                    },
                    '(' => {
                        ret.tag = .sym_lparen;
                        self.idx += 1;
                        break;
                    },
                    ')' => {
                        ret.tag = .sym_rparen;
                        self.idx += 1;
                        break;
                    },
                    '{' => {
                        ret.tag = .sym_lbrace;
                        self.idx += 1;
                        break;
                    },
                    '}' => {
                        ret.tag = .sym_rbrace;
                        self.idx += 1;
                        break;
                    },
                    '[' => {
                        ret.tag = .sym_lbracket;
                        self.idx += 1;
                        break;
                    },
                    ']' => {
                        ret.tag = .sym_rbracket;
                        self.idx += 1;
                        break;
                    },
                    ';' => {
                        ret.tag = .sym_semicolon;
                        self.idx += 1;
                        break;
                    },
                    ':' => {
                        ret.tag = .sym_colon;
                        self.idx += 1;
                        break;
                    },
                    '?' => {
                        ret.tag = .sym_question;
                        self.idx += 1;
                        break;
                    },
                    ',' => {
                        ret.tag = .sym_comma;
                        self.idx += 1;
                        break;
                    },
                    '\'' => {
                        ret.tag = .sym_chrquot;
                        self.idx += 1;
                        break;
                    },
                    '"' => {
                        ret.tag = .sym_strquot;
                        self.idx += 1;
                        break;
                    },
                    ' ', '\n', '\t', '\r' => ret.pos.start = self.idx + 1,
                    '+' => state = .plus,
                    '-' => state = .minus,
                    '*' => state = .asterisk,
                    '/' => state = .divide,
                    '%' => state = .mod,
                    '=' => state = .equal,
                    '!' => state = .bang,
                    '>' => state = .greater,
                    '<' => state = .less,
                    '&' => state = .ampersand,
                    '|' => state = .pipe,
                    '^' => state = .xor,
                    '0' => {
                        state = .zero;
                        ret.tag = .int_literal_oct;
                    },
                    '1'...'9' => {
                        state = .int_literal;
                        ret.tag = .int_literal;
                    },
                    else => {
                        ret.tag = .invalid;
                        ret.pos.end = self.idx;
                        self.idx += 1;
                        break;
                    }
                },
                .identifier => switch (c) {
                    '_', 'a'...'z', '0'...'9', 'A'...'Z' => {},
                    else => {
                        if (Token.keywords.get(self.code[ret.pos.start..self.idx])) |keyword_tag| {
                            ret.tag = keyword_tag;
                        }
                        break;
                    }
                },
                .plus => switch (c) {
                    '=' => {
                        ret.tag = .op_pluseq;
                        self.idx += 1;
                        break;
                    },
                    '+' => {
                        ret.tag = .op_inc;
                        self.idx += 1;
                        break;
                    }, else => {
                        ret.tag = .op_plus;
                        break;
                    }
                },
                .minus => switch (c) {
                    '=' => {
                        ret.tag = .op_minuseq;
                        self.idx += 1;
                        break;
                    },
                    '-' => {
                        ret.tag = .op_dec;
                        self.idx += 1;
                        break;
                    }, else => {
                        ret.tag = .op_minus;
                        break;
                    }
                },
                .asterisk => switch (c) {
                    '=' => {
                        ret.tag = .op_timeseq;
                        self.idx += 1;
                        break;
                    }, else => {
                        ret.tag = .op_asterisk;
                        break;
                    }
                },
                .divide => switch (c) {
                    '=' => {
                        ret.tag = .op_diveq;
                        self.idx += 1;
                        break;
                    }, else => {
                        ret.tag = .op_divide;
                        break;
                    }
                },
                .mod => switch (c) {
                    '=' => {
                        ret.tag = .op_modeq;
                        self.idx += 1;
                        break;
                    }, else => {
                        ret.tag = .op_mod;
                        break;
                    }
                },
                .equal => switch (c) {
                    '=' => {
                        ret.tag = .op_equality;
                        self.idx += 1;
                        break;
                    }, else => {
                        ret.tag = .op_equals;
                        break;
                    }
                },
                .bang => switch (c) {
                    '=' => {
                        ret.tag = .op_noteq;
                        self.idx += 1;
                        break;
                    }, else => {
                        ret.tag = .op_lognot;
                        break;
                    }
                },
                .greater => switch (c) {
                    '=' => {
                        ret.tag = .op_greatereq;
                        self.idx += 1;
                        break;
                    },
                    '>' => state = .greater2,
                    else => {
                        ret.tag = .op_greater;
                        break;
                    }
                },
                .greater2 => switch (c) {
                    '=' => {
                        ret.tag = .op_rshifteq;
                        self.idx += 1;
                        break;
                    },
                    else => {
                        ret.tag = .op_rshift;
                        break;
                    }
                },
                .less => switch (c) {
                    '=' => {
                        ret.tag = .op_lesseq;
                        self.idx += 1;
                        break;
                    },
                    '<' => state = .less2,
                    else => {
                        ret.tag = .op_less;
                        break;
                    }
                },
                .less2 => switch (c) {
                    '=' => {
                        ret.tag = .op_lshifteq;
                        self.idx += 1;
                        break;
                    }, else => {
                        ret.tag = .op_lshift;
                        break;
                    }
                },
                .ampersand => switch (c) {
                    '=' => {
                        ret.tag = .op_andeq;
                        self.idx += 1;
                        break;
                    },
                    '&' => {
                        ret.tag = .op_logand;
                        self.idx += 1;
                        break;
                    }, else => {
                        ret.tag = .op_ampersand;
                        break;
                    }
                },
                .pipe => switch (c) {
                    '=' => {
                        ret.tag = .op_oreq;
                        self.idx += 1;
                        break;
                    },
                    '|' => {
                        ret.tag = .op_logor;
                        self.idx += 1;
                        break;
                    }, else => {
                        ret.tag = .op_bitor;
                        break;
                    }
                },
                .xor => switch (c) {
                    '=' => {
                        ret.tag = .op_xoreq;
                        self.idx += 1;
                        break;
                    }, else => {
                        ret.tag = .op_xor;
                        break;
                    }
                },
                .int_literal => switch (c) {
                    '.' => {
                        state = .float_literal;
                        ret.tag = .float_literal;
                    },
                    '0'...'9' => {},
                    'a'...'z', 'A'...'Z', '_' => {
                        ret.tag = .invalid;
                        break;
                    },
                    else => break,
                },
                .float_literal => switch (c) {
                    '0'...'9' => {},
                    'a'...'z', 'A'...'Z', '_' => {
                        ret.tag = .invalid;
                        break;
                    },
                    else => break
                },
                .zero => switch (c) {
                    '0'...'7' => {},
                    'x' => {
                        state = .hex_number;
                        ret.tag = .int_literal_hex;
                    },
                    '8', '9', 'A'...'Z', 'a'...'w', 'y', 'z' => {
                        ret.tag = .invalid;
                        break;
                    },
                    else => break
                },
                .hex_number => switch (c) {
                    '0'...'9', 'A'...'F', 'a'...'f' => {},
                    'G'...'Z', 'g'...'z' => {
                        ret.tag = .invalid;
                        break;
                    },
                    else => break
                }
            }
        }
        if (ret.tag == .eof) {
            ret.pos.start = self.idx;
        }
        ret.pos.end = self.idx;
        return ret;
    }
    pub fn init(code: [*:0]const u8) Self {
        return Self {
            .code = code,
            .idx = 0
        };
    }
    const State = enum {
        default,
        identifier,
        plus,
        minus,
        asterisk,
        divide,
        mod,
        equal,
        bang,
        greater,
        greater2,
        less,
        less2,
        ampersand,
        pipe,
        xor,
        int_literal,
        float_literal,
        zero,
        hex_number
    };
};

pub const Token = struct {
        tag: LexTag,
        pos: Pos,
        pub const LexTag = enum {
            identifier,        // myvariable
            int_literal,       // 123456
            int_literal_hex,   // 0xdeadbeef
            int_literal_oct,   // 0755
            float_literal,     // 3.14
            op_plus,           // +
            op_pluseq,         // +=
            op_inc,            // ++
            op_minus,          // -
            op_minuseq,        // -=
            op_dec,            // --
            op_asterisk,       // *
            op_timeseq,        // *=
            op_divide,         // /
            op_diveq,          // /=
            op_mod,            // %
            op_modeq,          // %=
            op_equals,         // =
            op_equality,       // ==
            op_lognot,         // !
            op_noteq,          // !=
            op_greater,        // >
            op_greatereq,      // >=
            op_rshift,         // >>
            op_rshifteq,       // >>=
            op_less,           // <
            op_lesseq,         // <=
            op_lshift,         // <<
            op_lshifteq,       // <<=
            op_ampersand,      // &
            op_andeq,          // &=
            op_logand,         // &&
            op_bitor,          // |
            op_oreq,           // |=
            op_logor,          // ||
            op_xor,            // ^
            op_xoreq,          // ^=
            op_bitnot,         // ~
            sym_lparen,        // (
            sym_rparen,        // )
            sym_lbrace,        // {
            sym_rbrace,        // }
            sym_lbracket,      // [
            sym_rbracket,      // ]
            sym_semicolon,     // ;
            sym_colon,         // :
            sym_question,      // ?
            sym_comma,         // ,
            sym_chrquot,       // '
            sym_strquot,       // "
            keyword_char,      // char
            keyword_const,     // const
            keyword_double,    // double
            keyword_else,      // else
            keyword_float,     // float
            keyword_if,        // if
            keyword_int,       // int
            keyword_puts,      // puts
            keyword_putc,      // putc
            keyword_short,     // short
            keyword_struct,    // struct
            keyword_unsigned,  // unsigned
            keyword_while,     // while
            eof,               // EOF
            invalid            // who knows
        };
        pub const Pos = struct {
            start: usize,
            end: usize
        };
        pub const keywords = std.ComptimeStringMap(LexTag, .{
            .{"char", .keyword_char},
            .{"const", .keyword_const},
            .{"else", .keyword_else},
            .{"float", .keyword_float},
            .{"if", .keyword_if},
            .{"int", .keyword_int},
            .{"puts", .keyword_puts},
            .{"putc", .keyword_putc},
            .{"short", .keyword_short},
            .{"struct", .keyword_struct},
            .{"unsigned", .keyword_unsigned},
            .{"while", .keyword_while},
        });
    };