const std = @import("std");
const gio = @import("gio");

const ctx = @import("ctx.zig");
const HtApplication = @import("app.zig").HtApplication;

pub fn main() !void {
    const args = try std.process.argsAlloc(std.heap.c_allocator);
    defer std.process.argsFree(std.heap.c_allocator, args);

    const app = HtApplication.new();
    const gio_app = app.as(gio.Application);
    try ctx.initContextOnApp(gio_app);
    gio.Application.setDefault(gio_app);

    _ = gio_app.run(1, @ptrCast(args.ptr));
}
