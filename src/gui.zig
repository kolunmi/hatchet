const std = @import("std");
const obj = @import("gobject");
const gio = @import("gio");
const gtk = @import("gtk");
const adw = @import("adwaita");
const gsv = @import("gtksourceview");

const utl = @import("util.zig");
const keys = @import("keys.zig");
const ctx = @import("ctx.zig");
const nav = @import("nav.zig");

pub fn makeWindow(app: *gtk.Application) *gtk.Window {
    const view = makeSourceView(.{nav.main_view_funcs});

    const overlay = gtk.Overlay.new();
    overlay.setChild(view.as(gtk.Widget));

    const header_bar = adw.HeaderBar.new();
    header_bar.setShowEndTitleButtons(1);

    const toolbar_view = adw.ToolbarView.new();
    toolbar_view.setContent(overlay.as(gtk.Widget));
    toolbar_view.addBottomBar(header_bar.as(gtk.Widget));

    const win = adw.Window.new();
    win.setContent(toolbar_view.as(gtk.Widget));
    const widget = win.as(gtk.Widget);
    widget.setSizeRequest(250, 400);
    const gtk_win = win.as(gtk.Window);
    gtk_win.setApplication(app);

    const context = ctx.getGlobalContext();
    context.active_view = view;

    return win.as(gtk.Window);
}

pub const PickerMap = std.StringArrayHashMap(ctx.ActionFunc);
/// This function sets the global context's buffer to the picker's buffer
/// automatically
pub fn makePicker(
    map: PickerMap,
    name: [:0]const u8,
) !*gtk.Frame {
    const view = makeSourceView(.{});
    const gtk_view = view.as(gtk.TextView);
    const buffer = gtk_view.getBuffer();

    var iterator = map.iterator();
    while (iterator.next()) |entry| {
        var iter: gtk.TextIter = undefined;
        buffer.getEndIter(&iter);
        buffer.insert(&iter, @ptrCast(entry.key_ptr.ptr), @intCast(entry.key_ptr.len));
        iter.forwardToEnd();
        buffer.insert(&iter, "\n", 1);
    }

    const frame = gtk.Frame.new(name);
    frame.setChild(view.as(gtk.Widget));

    const context = ctx.getGlobalContext();
    context.active_view = view;

    var iter: gtk.TextIter = undefined;
    buffer.getStartIter(&iter);
    buffer.placeCursor(&iter);

    return frame;
}

pub fn getActiveWidgets() struct {
    window: ?*adw.Window,
    overlay: ?*gtk.Overlay,
    main_view: ?*gtk.TextView,
} {
    var window: ?*adw.Window = null;
    var overlay: ?*gtk.Overlay = null;
    var main_view: ?*gtk.TextView = null;

    if (gio.Application.getDefault()) |app| {
        const gtk_app: *gtk.Application = @ptrCast(app);
        if (gtk_app.getActiveWindow()) |win| {
            window = @ptrCast(win);
            const toolbar_view: *adw.ToolbarView = @ptrCast(window.?.getContent().?);
            overlay = @ptrCast(toolbar_view.getContent().?);
            main_view = @ptrCast(overlay.?.getChild());
        }
    }

    return .{
        .window = window,
        .overlay = overlay,
        .main_view = main_view,
    };
}

fn makeSourceView(keymaps: anytype) *gsv.View {
    const text_view = gsv.View.new();
    const gtk_text_view = text_view.as(gtk.TextView);
    gtk_text_view.setMonospace(1);
    const text_view_widget = text_view.as(gtk.Widget);
    text_view_widget.addCssClass("monospace");

    const shortcuts = gtk.ShortcutController.new();
    keys.addKeys(shortcuts, nav.basic_funcs);
    inline for (keymaps) |funcs| {
        keys.addKeys(shortcuts, funcs);
    }
    const controller = shortcuts.as(gtk.EventController);
    controller.setPropagationPhase(gtk.PropagationPhase.capture);
    const widget = text_view.as(gtk.Widget);
    widget.addController(controller);

    return text_view;
}
