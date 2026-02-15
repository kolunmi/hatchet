const std = @import("std");
const glib = @import("glib");
const obj = @import("gobject");
const gio = @import("gio");
const gtk = @import("gtk");
const adw = @import("adwaita");
const gsv = @import("gtksourceview");

const nav = @import("nav.zig");
const ctx = @import("ctx.zig");

const KeyHandler = *const fn (widget: *gtk.Widget) bool;

pub fn addKey(
    controller: *gtk.ShortcutController,
    accelerator: [*:0]const u8,
    handler: KeyHandler,
) void {
    if (gtk.ShortcutTrigger.parseString(accelerator)) |trigger| {
        const action = gtk.CallbackAction.new(
            struct {
                pub fn cb(
                    widget: *gtk.Widget,
                    args: ?*glib.Variant,
                    user_data: ?*anyopaque,
                ) callconv(.c) c_int {
                    _ = args;
                    const func: KeyHandler = @ptrCast(user_data.?);
                    if (func(widget)) {
                        return 1;
                    } else {
                        return 0;
                    }
                }
            }.cb,
            @ptrCast(@constCast(handler)),
            null,
        );
        const shortcut = gtk.Shortcut.new(trigger, action.as(gtk.ShortcutAction));
        controller.addShortcut(shortcut);
    }
}

pub fn addDefaultKeys(controller: *gtk.ShortcutController) void {
    inline for (@typeInfo(nav.funcs).@"struct".decls) |decl| {
        const key = @field(nav.funcs, decl.name);
        if (@typeInfo(key) == .@"struct") {
            const func = @field(key, "func");
            const accel = @field(key, "accel");
            addKey(
                controller,
                accel,
                struct {
                    pub fn cb(_widget: *gtk.Widget) bool {
                        _ = _widget;
                        const context = ctx.getGlobalContext();
                        return func(context);
                    }
                }.cb,
            );
        }
    }
}
