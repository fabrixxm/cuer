/* window.vala
 *
 * Copyright (C) 2017 fabrixxm
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
		History history;

		[GtkChild]
		Gtk.Button btnCameraStop;
		[GtkChild]
		Gtk.Button btnCameraPlay;
		[GtkChild]
		Gtk.Button btnHistoryClear;
		[GtkChild]
		Gtk.Stack stack;

		construct {
			camera.notify["state"].connect(this.updateBtns);

			btnCameraPlay.clicked.connect(camera.play);
			btnCameraStop.clicked.connect(camera.stop);

			camera.code_ready.connect(on_code);

		}

		public Window (Gtk.Application app) {
			Object (application: app);
		}

		public void present_and_play() {
			this.present();
			camera.play();
		}

		[GtkCallback]
		public void toggleHistory() {
			if(this.stack.visible_child_name == "page0") {
				this.stack.set_visible_child_full( "page1", Gtk.StackTransitionType.SLIDE_LEFT );
				this.camera.stop();
			} else {
				this.stack.set_visible_child_full( "page0", Gtk.StackTransitionType.SLIDE_RIGHT );
				this.camera.play();
			}

			this.updateBtns();
		}

		public void updateBtns() {
			btnCameraPlay.visible = camera.state == Gst.State.PAUSED && this.stack.visible_child_name == "page0";
			btnCameraStop.visible = camera.state == Gst.State.PLAYING && this.stack.visible_child_name == "page0";
			btnHistoryClear.visible = this.stack.visible_child_name == "page1";
		}

		//[GtkCallback]
		public void on_code(string code){
			camera.stop();

			Gtk.Clipboard clip = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD);
			clip.set_text(code, code.length);


			Gtk.RecentManager rm = Gtk.RecentManager.get_default();
			rm.add_full(code, Gtk.RecentData() {
				display_name = code,
				description = "",
				mime_type = "text/plain",
				app_name = "",
				app_exec = "",
				groups = new string[0],
				is_private = true
			});


			stdout.printf("%s\n", code);

			string summary = "QRCode found";
			try {
				Notify.Notification notification = new Notify.Notification (summary, code, null);
				notification.add_action ("action-name", "Open in browser", (notification, action) => {
					try {
						notification.close ();
					} catch (Error e) {
						debug ("Error: %s", e.message);
					}
				});
				notification.show ();
			} catch (Error e) {
				error ("Error: %s", e.message);
			}
		}

	}
}

