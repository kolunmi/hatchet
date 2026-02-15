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
    inline fn textIterFuncs(
        context: *Context,
        args: anytype,
    ) bool {
        if (context.active_buf) |active_buf| {
            const gtk_buf = active_buf.as(gtk.TextBuffer);
            const mark = gtk_buf.getInsert();
            var iter: gtk.TextIter = undefined;
            gtk_buf.getIterAtMark(&iter, mark);
            inline for (args) |call| {
                _ = @call(.auto, @field(gtk.TextIter, call.func), .{&iter} ++ call.args);
            }
            gtk_buf.placeCursor(&iter);
            return true;
        } else {
            return false;
        }
    }

    // FUNCS

    pub const forwardLine = struct {
        pub fn func(context: *Context) bool {
            return textIterFuncs(
                context,
                .{.{ .func = "forwardVisibleLine", .args = .{} }},
            );
        }
        pub const accel = "<primary>n";
    };
    pub const backwardLine = struct {
        pub fn func(context: *Context) bool {
            return textIterFuncs(
                context,
                .{.{ .func = "backwardVisibleLine", .args = .{} }},
            );
        }
        pub const accel = "<primary>p";
    };
    pub const forwardCursorPosition = struct {
        pub fn func(context: *Context) bool {
            return textIterFuncs(
                context,
                .{.{ .func = "forwardVisibleCursorPosition", .args = .{} }},
            );
        }
        pub const accel = "<primary>f";
    };
    pub const backwardCursorPosition = struct {
        pub fn func(context: *Context) bool {
            return textIterFuncs(
                context,
                .{.{ .func = "backwardVisibleCursorPosition", .args = .{} }},
            );
        }
        pub const accel = "<primary>b";
    };
    pub const forwardWord = struct {
        pub fn func(context: *Context) bool {
            return textIterFuncs(
                context,
                .{.{ .func = "forwardVisibleWordEnd", .args = .{} }},
            );
        }
        pub const accel = "<alt>f";
    };
    pub const backwardWord = struct {
        pub fn func(context: *Context) bool {
            return textIterFuncs(
                context,
                .{.{ .func = "backwardVisibleWordStart", .args = .{} }},
            );
        }
        pub const accel = "<alt>b";
    };
    pub const endOfLine = struct {
        pub fn func(context: *Context) bool {
            return textIterFuncs(
                context,
                .{.{ .func = "forwardToLineEnd", .args = .{} }},
            );
        }
        pub const accel = "<primary>e";
    };
    pub const startOfLine = struct {
        pub fn func(context: *Context) bool {
            return textIterFuncs(
                context,
                .{.{ .func = "setLineIndex", .args = .{0} }},
            );
        }
        pub const accel = "<primary>a";
    };

    // /FUNCS
};
