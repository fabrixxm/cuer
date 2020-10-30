/* notification_overlay.vala
 *
 * Copyright (C) 2020 fabrixxm
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
	[GtkTemplate (ui = "/net/kirgroup/Cuer/notification_overlay.ui")]
	public class NotificationOverlay : Gtk.Revealer {

		[GtkChild]
		Gtk.Label label;
		[GtkChild]
		Gtk.Button button;

        construct {
            debug("construct");
            button.clicked.connect(close);
            debug("/construct");
        }

        /* 'new' because we really want to override 'show' */
        public new void show(string text) {
            debug(text);
            label.set_markup(text);
            set_reveal_child(true);
        }

        public void close() {
            debug("close");
            // when reveal animation ends, 'child-revelaed' change to 'false'
            // we connect to change notification and detroy the widget.
            notify["child-revealed"].connect(destroy);
            set_reveal_child(false);
        }
    }
}


