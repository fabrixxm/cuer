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
	[GtkTemplate (ui = "/org/gnome/Cuer/history.ui")]
	public class History : Gtk.ScrolledWindow {
	    public Gtk.RecentFilter filter { get; set; }

		[GtkChild]
		Gtk.Box box;

		Gtk.RecentManager recentManager;

		public signal void activated(string text);

        construct {
        }


		public void set_recent_manager(Gtk.RecentManager recentManager) {
		    this.recentManager = recentManager;
		    this.recentManager.changed.connect(this.update);
		    this.update();
		}

		private void update() {
            debug("HistoryPage update");
            var items = this.recentManager.get_items();
            debug("items: %u", (uint) items.length()  );

            this.box.foreach((child) => this.box.remove(child));

            if ((uint) items.length() == 0) {
                this.box.valign = Gtk.Align.FILL;
                var empty = new HistoryEmpty();
                this.box.pack_start(empty);
                empty.show();
            } else {

                items.sort((obj1, obj2)=>{
                    debug("Sorting");
                    var item1 = (Gtk.RecentInfo) obj1;
                    var item2 = (Gtk.RecentInfo) obj2;
                    int age1 = item1.get_age();
                    int age2 = item2.get_age();
                    return age1 - age2;
                });



                this.box.valign = Gtk.Align.START;
                int age = -1;
                Gtk.ListBox listbox = new Gtk.ListBox();
                items.foreach((item) => {
                    if (item.has_application("cuer")) {
                        if (item.get_age() != age) {
                            age = item.get_age();
                            var label = new Gtk.Label(null);
                            label.set_markup("<b>%d days ago</b>".printf(age));
                            //label.set_line_wrap(true);
                            //label.set_line_wrap_mode(Pango.WrapMode.WORD);
                            label.set_ellipsize(Pango.EllipsizeMode.MIDDLE);
                            label.set_halign(Gtk.Align.START);
                            label.set_valign(Gtk.Align.START);

                            listbox = new Gtk.ListBox();
                            listbox.set_valign(Gtk.Align.START);
                            listbox.row_activated.connect(row => {
                                var hrow = row as Hdy.ActionRow;
                                debug("row activated: %s", hrow.get_title());
                                this.activated(hrow.get_title());
                            });

                            this.box.pack_start(label);
                            this.box.pack_start(listbox);
                            label.show();
                            listbox.show();
                        }

                        var row = new Hdy.ActionRow();
                        row.set_title(item.get_display_name());
                        row.set_selectable(false);
                        listbox.add(row);
                        row.show();

                   }
                });
            }
		}
	}
}
