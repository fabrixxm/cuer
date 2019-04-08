/* window.vala
 *
 * Copyright (C) 2018 fabrixxm
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Cuer {
	[GtkTemplate (ui = "/org/gnome/Cuer/window.ui")]
	public class Window : Gtk.ApplicationWindow {
		[GtkChild]
		Camera camera;

		[GtkChild]
		Gtk.Button btnCameraStop;
		[GtkChild]
		Gtk.Button btnCameraPlay;
		[GtkChild]
		Gtk.Stack stack;

		[GtkChild]
		Gtk.RecentManager recent;
		[GtkChild]
		Gtk.RecentFilter recentFilter;
		[GtkChild]
		History history;

		[GtkChild]
		Gtk.StackSwitcher topStackSwitcher;
		[GtkChild]
		Gtk.StackSwitcher bottomStackSwitcher;




		construct {
		    set_icon_name("org.gnome.Cuer");

		    configure_event.connect(configure_callback);

		    Gtk.CssProvider cssProvider = new Gtk.CssProvider();
		    cssProvider.load_from_resource("/org/gnome/Cuer/cuer.css");

            //var styleContext = get_style_context();
            get_style_context().add_provider(cssProvider, 1);

			camera.notify["state"].connect(this.updateBtns);

			btnCameraPlay.clicked.connect(camera.play);
			btnCameraStop.clicked.connect(camera.stop);


			camera.code_ready.connect(on_code);
			stack.notify.connect((sender, property) => {
                this.updateBtns();
            });

            history.filter = recentFilter;
            history.activated.connect(this.on_history_item_activated);
            history.set_recent_manager(recent);

            adapt();
		}

		private void adapt() {
            int w = get_allocated_width();
            topStackSwitcher.set_visible( w >= 700 );
            bottomStackSwitcher.set_visible( w < 700 );
            /*
            if (w >= 700) {
                stack.child_set_property(camera, "icon-name", "");
                stack.child_set_property(history, "icon-name", "");
            } else {
                stack.child_set_property(camera, "icon-name", "org.gnome.Cuer-symbolic");
                stack.child_set_property(history, "icon-name", "document-open-recent-symbolic");
            }
            */
		}

		private bool configure_callback(Gtk.Widget window, Gdk.EventConfigure event) {
            adapt();
            return false;
		}

		public Window (Gtk.Application app) {
			Object (application: app);
		}

		public void present_and_play() {
			this.present();
			camera.play();
		}


		public void updateBtns() {
			btnCameraPlay.visible = camera.state == Gst.State.PAUSED && this.stack.visible_child_name == "page_scan";
			btnCameraStop.visible = camera.state == Gst.State.PLAYING && this.stack.visible_child_name == "page_scan";
		}

		//[GtkCallback]
		public void on_code(string code){
			camera.stop();

			recent.add_full(code, Gtk.RecentData() {
				display_name = code,
				description = "",
				mime_type = "text/plain",
				app_name = "cuer",
				app_exec = "cuer",
				groups = new string[0],
				is_private = true
			});

			show_notification(code);
		}

		public void show_notification(string code) {
			Gtk.Clipboard clip = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD);
			clip.set_text(code, code.length);

			debug("show notification: %s", code);

			string summary = "QRCode";
			try {
				Notify.Notification notification = new Notify.Notification (summary, code, "org.gnome.Cuer");
				/* notification.add_action ("action-name", "Open in browser", (notification, action) => {
					try {
						notification.close ();
					} catch (Error e) {
						debug ("Error: %s", e.message);
					}
				});*/
				notification.show ();
			} catch (Error e) {
				critical("Error: %s", e.message);
			}
		}

		public void on_history_item_activated(string text){
			show_notification(text);
		}
	}
}

