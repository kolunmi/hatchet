const std = @import("std");
const gio = @import("gio");
const gtk = @import("gtk");
const adw = @import("adwaita");
const gsv = @import("gtksourceview");

pub fn makeWindow(app: *gtk.Application) *gtk.Window {
    const text_view = gsv.View.new();

    const header_bar = adw.HeaderBar.new();
    header_bar.setShowEndTitleButtons(1);

    const toolbar_view = adw.ToolbarView.new();
    toolbar_view.setContent(text_view.as(gtk.Widget));
    toolbar_view.addTopBar(header_bar.as(gtk.Widget));

    const win = adw.Window.new();
    win.setContent(toolbar_view.as(gtk.Widget));

    const gtk_win = win.as(gtk.Window);
    gtk_win.setApplication(app);

    return win.as(gtk.Window);
}
