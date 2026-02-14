const std = @import("std");
const obj = @import("gobject");
const gio = @import("gio");
const gtk = @import("gtk");
const adw = @import("adwaita");
const gsv = @import("gtksourceview");

const utl = @import("util.zig");
const keys = @import("keys.zig");

pub fn makeWindow(app: *gtk.Application) *gtk.Window {
    const text_view = gsv.View.new();

    const header_bar = adw.HeaderBar.new();
    header_bar.setShowEndTitleButtons(1);

    const toolbar_view = adw.ToolbarView.new();
    toolbar_view.setContent(text_view.as(gtk.Widget));
    toolbar_view.addTopBar(header_bar.as(gtk.Widget));

    const win = adw.Window.new();
    const widget = win.as(gtk.Widget);
    const gtk_win = win.as(gtk.Window);

    win.setContent(toolbar_view.as(gtk.Widget));
    gtk_win.setApplication(app);

    {
        const shortcuts = gtk.ShortcutController.new();
        const controller = shortcuts.as(gtk.EventController);

        controller.setPropagationPhase(gtk.PropagationPhase.capture);
        widget.addController(controller);

        keys.addKey(
            shortcuts,
            "<primary>e",
            struct {
                pub fn cb(_widget: *gtk.Widget) bool {
                    _ = _widget;
                    std.debug.print("end of line\n", .{});
                    return true;
                }
            }.cb,
        );
    }

    return win.as(gtk.Window);
}
