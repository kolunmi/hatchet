const std = @import("std");
const obj = @import("gobject");

/// sets swap flag
pub fn connect(
    object: *obj.Object,
    signal: [*:0]const u8,
    handler: *const fn () callconv(.c) void,
    data: ?*anyopaque,
) void {
    _ = obj.signalConnectData(
        object,
        signal,
        handler,
        data,
        null,
        obj.ConnectFlags.flags_swapped,
    );
}
