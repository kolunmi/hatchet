const std = @import("std");
const glib = @import("glib");
const obj = @import("gobject");
const gio = @import("gio");
const gtk = @import("gtk");
const adw = @import("adwaita");
const gsv = @import("gtksourceview");

const gui = @import("gui.zig");
const ctx = @import("ctx.zig");
const Context = ctx.Context;

pub const basic_funcs = struct {
    inline fn textIterFuncs(
        context: *Context,
        args: anytype,
    ) !bool {
        if (context.active_view) |view| {
            const gtk_view: *gtk.TextView = @ptrCast(view);
            const buffer = gtk_view.getBuffer();

            const gtk_buffer = buffer.as(gtk.TextBuffer);
            const mark = gtk_buffer.getInsert();
            var iter: gtk.TextIter = undefined;
            gtk_buffer.getIterAtMark(&iter, mark);
            inline for (args) |call| {
                _ = @call(.auto, @field(gtk.TextIter, call.func), .{&iter} ++ call.args);
            }
            gtk_buffer.placeCursor(&iter);
            return true;
        } else {
            return false;
        }
    }

    // FUNCS

    pub const forwardLine = struct {
        pub fn func(context: *Context) !bool {
            return textIterFuncs(
                context,
                .{.{ .func = "forwardVisibleLine", .args = .{} }},
            );
        }
        pub const accel = "<primary>n";
    };
    pub const backwardLine = struct {
        pub fn func(context: *Context) !bool {
            return textIterFuncs(
                context,
                .{.{ .func = "backwardVisibleLine", .args = .{} }},
            );
        }
        pub const accel = "<primary>p";
    };
    pub const forwardCursorPosition = struct {
        pub fn func(context: *Context) !bool {
            return textIterFuncs(
                context,
                .{.{ .func = "forwardVisibleCursorPosition", .args = .{} }},
            );
        }
        pub const accel = "<primary>f";
    };
    pub const backwardCursorPosition = struct {
        pub fn func(context: *Context) !bool {
            return textIterFuncs(
                context,
                .{.{ .func = "backwardVisibleCursorPosition", .args = .{} }},
            );
        }
        pub const accel = "<primary>b";
    };
    pub const forwardWord = struct {
        pub fn func(context: *Context) !bool {
            return textIterFuncs(
                context,
                .{.{ .func = "forwardVisibleWordEnd", .args = .{} }},
            );
        }
        pub const accel = "<alt>f";
    };
    pub const backwardWord = struct {
        pub fn func(context: *Context) !bool {
            return textIterFuncs(
                context,
                .{.{ .func = "backwardVisibleWordStart", .args = .{} }},
            );
        }
        pub const accel = "<alt>b";
    };
    pub const endOfLine = struct {
        pub fn func(context: *Context) !bool {
            return textIterFuncs(
                context,
                .{.{ .func = "forwardToLineEnd", .args = .{} }},
            );
        }
        pub const accel = "<primary>e";
    };
    pub const startOfLine = struct {
        pub fn func(context: *Context) !bool {
            return textIterFuncs(
                context,
                .{.{ .func = "setLineIndex", .args = .{0} }},
            );
        }
        pub const accel = "<primary>a";
    };

    // /FUNCS
};

pub const main_view_funcs = struct {
    pub const commands = struct {
        pub fn func(context: *Context) !bool {
            _ = context;
            const widgets = gui.getActiveWidgets();
            if (widgets.overlay) |overlay| {
                var map = gui.PickerMap.init(ctx.allocator);
                errdefer map.deinit();
                inline for (@typeInfo(basic_funcs).@"struct".decls) |decl| {
                    const key = @field(basic_funcs, decl.name);
                    if (@typeInfo(key) == .@"struct") {
                        const _func = @field(key, "func");
                        try map.put(decl.name, _func);
                    }
                }

                const picker = try gui.makePicker(map, "Commands");
                const widget = picker.as(gtk.Widget);
                widget.setMarginStart(10);
                widget.setMarginEnd(10);
                widget.setMarginTop(10);
                widget.setMarginBottom(10);
                widget.setHalign(.fill);
                widget.setValign(.end);
                widget.setSizeRequest(-1, 200);
                overlay.addOverlay(widget);

                const view = picker.getChild().?;
                _ = view.grabFocus();
            }

            return false;
        }
        pub const accel = "<alt>x";
    };
};
