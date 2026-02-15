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
    pub const forwardChar = struct {
        pub fn func(context: *Context) bool {
            if (context.active_buf) |active_buf| {
                const gtk_buf = active_buf.as(gtk.TextBuffer);
                const mark = gtk_buf.getInsert();
                var iter: gtk.TextIter = undefined;
                gtk_buf.getIterAtMark(&iter, mark);
                _ = iter.forwardChar();
                gtk_buf.placeCursor(&iter);
                return true;
            } else {
                return false;
            }
        }
        pub const accel = "<primary>f";
    };
};
