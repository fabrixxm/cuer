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
	[GtkTemplate (ui = "/net/kirgroup/Cuer/window.ui")]
	public class Window : Gtk.ApplicationWindow {
		[GtkChild]
		Camera camera;

		[GtkChild]
		Gtk.Button btnCameraStop;
		[GtkChild]
		Gtk.Button btnCameraPlay;

		[GtkChild]
		Gtk.Overlay overlay;
		[GtkChild]
		Gtk.Stack stack;

		[GtkChild]
		Gtk.RecentManager recent;
		[GtkChild]
		History history;

		[GtkChild]
		Hdy.ViewSwitcher topStackSwitcher;
		[GtkChild]
		Hdy.ViewSwitcherBar bottomStackSwitcher;

        private Gst.DeviceMonitor monitor;


		construct {
		    set_icon_name("net.kirgroup.Cuer");

		    configure_event.connect(configure_callback);

		    Gtk.CssProvider cssProvider = new Gtk.CssProvider();
		    cssProvider.load_from_resource("/net/kirgroup/Cuer/cuer.css");

            //var styleContext = get_style_context();
            get_style_context().add_provider(cssProvider, 1);

            this.setup_device_monitor();

			camera.notify["state"].connect(this.updateBtns);

			btnCameraPlay.clicked.connect(camera.play);
			btnCameraStop.clicked.connect(camera.stop);


			camera.code_ready.connect(on_code);
			stack.notify.connect((sender, property) => {
                this.updateBtns();
            });

            history.activated.connect(this.on_history_item_activated);
            history.set_recent_manager(recent);

            adapt();
		}

		public bool device_monitor_bus_watch(Gst.Bus bus, Gst.Message message) {
		    Gst.Device device;
            switch( message.type) {
                case Gst.MessageType.DEVICE_ADDED:
                    message.parse_device_added(out device);
                    debug("Device added: %s", device.get_display_name());
                    break;
                case Gst.MessageType.DEVICE_REMOVED:
                    message.parse_device_removed(out device);
                    debug("Device removed: %s", device.get_display_name());
                    break;
                default:
                    break;
            }

		    return Source.CONTINUE;
		}

		private void setup_device_monitor() {
		    this.monitor = new Gst.DeviceMonitor();

		    var bus = monitor.get_bus();
		    bus.add_watch(Priority.DEFAULT, this.device_monitor_bus_watch );

		    var caps = new Gst.Caps.empty_simple("video/x-raw");
            this.monitor.add_filter("Video/Source", caps);

            this.monitor.start();

            var devices = this.monitor.get_devices();
            devices.foreach((dev)=>{
                debug(dev.get_display_name());
            });
		}

		private void adapt() {
		    // this will toggle switcher at precise sizes,
		    // instead I could connect to squeezer's "notify::visible-child", let
		    // squeezer decide when hide top switcher and set bottom switcher reveal
		    // when top switcher is hidden...
            int w = get_allocated_width();
            topStackSwitcher.set_visible( w >= 700 );
            bottomStackSwitcher.set_reveal( w < 700 );
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

            var notif = new NotificationOverlay();
            overlay.add_overlay(notif);
            notif.show("<b>" + code + "</b>\n<small>" + _("Text copied in clipboard") + "</small>");
		}

		public void on_history_item_activated(string text){
			show_notification(text);
		}
	}
}

