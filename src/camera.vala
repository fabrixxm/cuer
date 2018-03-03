/* camera.vala
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

using Gst;

namespace Cuer {
	class Camera : Gtk.Frame {
		Element qrcodedec;
		Pipeline pipeline;

		public signal void code_ready(string code);

	    public Gst.State state {
		    get {
		    	if (pipeline == null) return Gst.State.NULL;
		    	return pipeline.current_state;
		    }
		    set {}
		}

		construct {
			Gtk.Widget video_area;

			var source = ElementFactory.make ("v4l2src", "source");
			qrcodedec = ElementFactory.make ("qrcodedec", "qrcodedec1");
			var videoconvert = ElementFactory.make ("videoconvert", "convert1");
			var gtksink = ElementFactory.make ("gtksink", "sink");
			gtksink.get ("widget", out video_area);

			// Build the pipeline:
			pipeline = new Gst.Pipeline ("test-pipeline");

			if (source == null || qrcodedec == null || gtksink == null ||
				videoconvert == null || pipeline == null) {
					stderr.puts ("Not all elements could be created.\n");
					return;
			}

			pipeline.add_many (source, qrcodedec, videoconvert, gtksink);


			if ( !source.link(qrcodedec) || !qrcodedec.link(videoconvert) || !videoconvert.link(gtksink) ) {
				stderr.puts ("Elements could not be linked.\n");
				return;
			}

			// qrcode event
			Signal.connect_swapped(qrcodedec, "qrcode", (Callback) on_qrcode, this);


			// qrcodedec.qrcode.connect(on_qrcode);


			Gst.Bus bus = pipeline.get_bus();
			bus.add_watch (0, bus_callback);

			/*
 			var vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    	    vbox.pack_start (video_area);


			Gtk.Label label = new Gtk.Label("Cam");
			vbox.pack_start(label, false);

			add(vbox);*/
			add(video_area);

			show_all();
		}

		~Camera() {
			pipeline.set_state (Gst.State.NULL);
		}

		private bool bus_callback (Gst.Bus bus, Gst.Message message) {
		    switch (message.type) {
		    case MessageType.ERROR:
		        GLib.Error err;
		        string debug;
		        message.parse_error (out err, out debug);
		        stderr.printf ("Error: %s\n", err.message);
		        break;
		    case MessageType.EOS:
		        stdout.printf ("end of stream\n");
		        break;
		    case MessageType.STATE_CHANGED:
		        Gst.State oldstate;
		        Gst.State newstate;
		        Gst.State pending;
		        message.parse_state_changed (out oldstate, out newstate,
		                                     out pending);

		        //stdout.printf ("state changed: %s->%s:%s\n",
		          //             oldstate.to_string (), newstate.to_string (),
		            //           pending.to_string ());


				this.state = newstate;
		        break;
		    default:
		        break;
		    }

		    return true;
		}

		[GtkCallback]
		public void play() {
			// Start playing:
			Gst.StateChangeReturn ret = pipeline.set_state (Gst.State.PLAYING);
			if (ret == Gst.StateChangeReturn.FAILURE) {
				stderr.printf ("Unable to set the pipeline to the playing state.\n");
				return;
			}

		}

		[GtkCallback]
		public void stop() {
			// Stop playing:
			Gst.StateChangeReturn ret = pipeline.set_state (Gst.State.PAUSED);
			if (ret == Gst.StateChangeReturn.FAILURE) {
				stderr.printf ("Unable to set the pipeline to the playing state.\n");
				return;
			}
		}

		[GtkCallback]
		private void on_qrcode(string codestr) {
			this.code_ready(codestr);
		}
	}
}
