/* history.vala
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
	[GtkTemplate (ui = "/org/gnome/Cuer/history.ui")]
	public class History : Gtk.ScrolledWindow {
		private Gtk.RecentManager rm;
		[GtkChild]
		Gtk.ListStore store;

		construct {
			this.rm = Gtk.RecentManager.get_default();
			this.rm.changed.connect(this.updatelist);
			this.updatelist();
		}

		public History () {
			Object ();
		}

		public void updatelist() {
			this.store.clear();
			Gtk.TreeIter iter;
			foreach(Gtk.RecentInfo info in this.rm.get_items()) {
				if (info.has_application("cuer")){
					stdout.printf(": %s\n", info.get_display_name());
					this.store.append(out iter);
					this.store.set(iter,
					 	0 , info.get_display_name(),
					 	1 , "some time ago"
					);
				}
			}
		}




	}
}
