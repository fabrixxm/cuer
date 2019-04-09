/* main.vala
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

int main (string[] args) {
	//Gtk.init (ref args);
    Intl.setlocale (LocaleCategory.ALL, "");
    Intl.textdomain (Build.GETTEXT_PACKAGE);
    debug("textdomain: %s", Build.GETTEXT_PACKAGE);

	Hdy.init (ref args);
	Gst.init (ref args);
	Notify.init ("Cuer");

	var app = new Gtk.Application ("net.kirgroup.Cuer", ApplicationFlags.FLAGS_NONE);
	app.activate.connect (() => {
		var win = app.active_window;
		if (win == null) {
			var cwin = new Cuer.Window (app);
			cwin.present_and_play();
		} else {
			win.present();
		}
	});

	return app.run (args);
}
