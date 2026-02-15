const std = @import("std");
const glib = @import("glib");
const obj = @import("gobject");
const gio = @import("gio");
const gtk = @import("gtk");
const adw = @import("adwaita");
const gsv = @import("gtksourceview");

const ctx = @import("ctx.zig");
const Context = ctx.Context;

pub const funcs = struct {
    inline fn textIterFunc(
        context: *Context,
        func: []const u8,
        args: anytype,
    ) bool {
        if (context.active_buf) |active_buf| {
            const gtk_buf = active_buf.as(gtk.TextBuffer);
            const mark = gtk_buf.getInsert();
            var iter: gtk.TextIter = undefined;
            gtk_buf.getIterAtMark(&iter, mark);
            _ = @call(.auto, @field(gtk.TextIter, func), .{&iter} ++ args);
            gtk_buf.placeCursor(&iter);
            return true;
        } else {
            return false;
        }
    }

    // FUNCS

    pub const forwardLine = struct {
        pub fn func(context: *Context) bool {
            return textIterFunc(context, "forwardVisibleLine", .{});
        }
        pub const accel = "<primary>n";
    };
    pub const backwardLine = struct {
        pub fn func(context: *Context) bool {
            return textIterFunc(context, "backwardVisibleLine", .{});
        }
        pub const accel = "<primary>p";
    };
    pub const forwardCursorPosition = struct {
        pub fn func(context: *Context) bool {
            return textIterFunc(context, "forwardVisibleCursorPosition", .{});
        }
        pub const accel = "<primary>f";
    };
    pub const backwardCursorPosition = struct {
        pub fn func(context: *Context) bool {
            return textIterFunc(context, "backwardVisibleCursorPosition", .{});
        }
        pub const accel = "<primary>b";
    };
    pub const forwardWord = struct {
        pub fn func(context: *Context) bool {
            return textIterFunc(context, "forwardVisibleWordEnd", .{});
        }
        pub const accel = "<alt>f";
    };
    pub const backwardWord = struct {
        pub fn func(context: *Context) bool {
            return textIterFunc(context, "backwardVisibleWordStart", .{});
        }
        pub const accel = "<alt>b";
    };

    // /FUNCS
};
