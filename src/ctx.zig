const std = @import("std");
const glib = @import("glib");
const obj = @import("gobject");
const gio = @import("gio");
const gtk = @import("gtk");
const adw = @import("adwaita");
const gsv = @import("gtksourceview");

pub const ActionFunc = *const fn (*Context) anyerror!bool;

pub const allocator = std.heap.c_allocator;

pub const Context = struct {
    const BufsType = std.ArrayList(*gsv.Buffer);
    bufs: BufsType,

    active_buf: ?*gsv.Buffer,

    pub fn create() !*Context {
        var bufs = try BufsType.initCapacity(allocator, 8);
        errdefer bufs.deinit(allocator);

        const self = try allocator.create(Context);
        errdefer allocator.destroy(self);

        self.* = .{
            .bufs = bufs,
            .active_buf = null,
        };

        return self;
    }

    pub fn destroy(self: *Context) void {
        self.bufs.deinit(allocator);
        allocator.destroy(self);
    }
};

const data_key = "HtCtx";

pub fn initContextOnApp(app: *gio.Application) !void {
    const object = app.as(obj.Object);

    const context = try Context.create();
    object.setDataFull(
        data_key,
        context,
        struct {
            pub fn cb(ptr: ?*anyopaque) callconv(.c) void {
                const _context: *Context = @ptrCast(@alignCast(ptr.?));
                _context.destroy();
            }
        }.cb,
    );
}

pub fn getContextFromApp(app: *gio.Application) ?*Context {
    const object = app.as(obj.Object);
    return @ptrCast(@alignCast(object.getData(data_key)));
}

pub fn getGlobalContext() *Context {
    if (gio.Application.getDefault()) |app| {
        if (getContextFromApp(app)) |context| {
            return @ptrCast(context);
        } else {
            @panic("Default GApplication has no associated context");
        }
    } else {
        @panic("Default GApplication not set");
    }
}
