const std = @import("std");
const adw = @import("adwaita");
const gtk = @import("gtk");
const gio = @import("gio");
const gobject = @import("gobject");
const glib = @import("glib");

const gui = @import("gui.zig");

pub const HtApplication = extern struct {
    parent_instance: Parent,

    pub const Parent = adw.Application;

    pub const getGObjectType = gobject.ext.defineClass(HtApplication, .{
        .classInit = &Class.init,
    });

    pub fn new() *HtApplication {
        return gobject.ext.newInstance(HtApplication, .{
            .application_id = "io.github.kolunmi.Hatchet",
            .flags = gio.ApplicationFlags{},
        });
    }

    pub fn as(app: *HtApplication, comptime T: type) *T {
        return gobject.ext.as(T, app);
    }

    fn activateImpl(app: *HtApplication) callconv(.c) void {
        const win = gui.makeWindow(app.as(gtk.Application));
        win.present();
    }

    pub const Class = extern struct {
        parent_class: Parent.Class,

        pub const Instance = HtApplication;

        pub fn as(class: *Class, comptime T: type) *T {
            return gobject.ext.as(T, class);
        }

        fn init(class: *Class) callconv(.c) void {
            gio.Application.virtual_methods.activate.implement(class, &activateImpl);
        }
    };
};
