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
            if (gio.Application.getDefault()) |app| {
                const gtk_app: *gtk.Application = @ptrCast(app);
                if (gtk_app.getActiveWindow()) |win| {
                    var map = gui.PickerMap.init(ctx.allocator);
                    errdefer map.deinit();
                    inline for (@typeInfo(basic_funcs).@"struct".decls) |decl| {
                        const key = @field(basic_funcs, decl.name);
                        if (@typeInfo(key) == .@"struct") {
                            const _func = @field(key, "func");
                            try map.put(decl.name, _func);
                        }
                    }

                    const adw_win: *adw.Window = @ptrCast(win);
                    const child: *adw.ToolbarView = @ptrCast(adw_win.getContent().?);
                    const overlay: *gtk.Overlay = @ptrCast(child.getContent().?);

                    const main_view = overlay.getChild().?;
                    main_view.setSensitive(0);

                    const view = try gui.makePicker(map, "Commands");
                    const widget = view.as(gtk.Widget);
                    widget.setMarginStart(10);
                    widget.setMarginEnd(10);
                    widget.setMarginTop(10);
                    widget.setMarginBottom(10);
                    widget.setHalign(.fill);
                    widget.setValign(.end);
                    widget.setSizeRequest(-1, 200);
                    overlay.addOverlay(widget);
                }
            }
            return false;
        }
        pub const accel = "<alt>x";
    };
};
