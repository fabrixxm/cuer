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
		Gtk.ListBox listBox;

        ListStore model;
		Gtk.RecentManager recentManager;

		public signal void history_item_activated();

        construct {
            var empty = new HistoryEmpty();
            listBox.set_placeholder(empty);
            listBox.set_header_func(this.update_header);

            model = new ListStore(typeof(RecentObject));
            listBox.bind_model(model, (obj)=>{
                var recentObject = obj as RecentObject;
                var row = new Hdy.ActionRow();
                row.set_title(recentObject.info.get_display_name());

                row.set_data("age", recentObject.info.get_age());
                row.set_data("added", recentObject.info.get_added());
                return row;
            });
        }


		public void set_recent_manager(Gtk.RecentManager recentManager) {
		    this.recentManager = recentManager;
		    this.recentManager.changed.connect(this.update);
		    this.update();
		}

		public Gtk.RecentInfo? get_current_item() {
		    return null;
		}

        public void update_header(Gtk.ListBoxRow row, Gtk.ListBoxRow? before) {
            int age = row.get_data("age");

            var label = row.get_header() as Gtk.Label;
            if (label == null) {
                label = new Gtk.Label("");
            }

            if (before == null) {
                    label.set_markup("<b>%d days ago</b>".printf(age));
                    row.set_header(label);
            } else {
                int bage = before.get_data("age");
                if (age != bage) {
                    label.set_markup("<b>%d days ago</b>".printf(age));
                    row.set_header(label);
                } else {
                    Hdy.list_box_separator_header(row, before, null);
                    }
            }
        }

		private void update() {
            debug("HistoryPage update");
            var items = this.recentManager.get_items();
            debug("items: %u", (uint) items.length);

            this.model.remove_all();
            items.foreach((item) => {
                if (true) { //item.has_application("cuer")) {
                    debug("append \"%s\"", item.get_display_name());
                    this.model.append(RecentObject.create(item));
                }
            });

            this.model.sort((obj1, obj2)=>{
                var item1 = obj1 as RecentObject;
                var item2 = obj2 as RecentObject;
                int age1 = item1.info.get_age();
                int age2 = item2.info.get_age();
                return age1 - age2;
            });

            /*
            this.box.foreach((child) => this.box.remove(child));

            if ((uint) items.length == 0) {
                var empty = new HistoryEmpty();
                this.box.pack_start(empty);
                empty.show();
            } else {
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

                            this.box.pack_start(label);
                            this.box.pack_start(listbox);
                            label.show();
                            listbox.show();
                        }

                        var label = new Gtk.Label(null);
                        label.set_markup(item.get_display_name());
                        listbox.add(label);
                        label.show();

                    }
                });
            }*/
		}
	}
}
