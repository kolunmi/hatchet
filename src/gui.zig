const std = @import("std");
const obj = @import("gobject");
const gio = @import("gio");
const gtk = @import("gtk");
const adw = @import("adwaita");
const gsv = @import("gtksourceview");

const utl = @import("util.zig");
const keys = @import("keys.zig");
const ctx = @import("ctx.zig");

pub fn makeWindow(app: *gtk.Application) *gtk.Window {
    const text_view = gsv.View.new();
    const gtk_text_view = text_view.as(gtk.TextView);

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

    const shortcuts = gtk.ShortcutController.new();
    keys.addDefaultKeys(shortcuts);
    const controller = shortcuts.as(gtk.EventController);
    controller.setPropagationPhase(gtk.PropagationPhase.capture);
    widget.addController(controller);

    const context = ctx.getGlobalContext();
    // can't use `.as()` here since subclass checking apparently doesn't work
    // across packages in the gir bindings we're using
    context.active_buf = @ptrCast(gtk_text_view.getBuffer());

    return win.as(gtk.Window);
}
