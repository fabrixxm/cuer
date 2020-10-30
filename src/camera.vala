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
			var videoconvert1 = ElementFactory.make ("videoconvert", "convert1");
			qrcodedec = ElementFactory.make ("qrcodedec", "qrcodedec1");
			var videoconvert2 = ElementFactory.make ("videoconvert", "convert2");
			var gtksink = ElementFactory.make ("gtksink", "sink");
			gtksink.get ("widget", out video_area);

			// Build the pipeline:
			pipeline = new Gst.Pipeline ("test-pipeline");

			if (source == null || videoconvert1 == null || qrcodedec == null || gtksink == null ||
				videoconvert2 == null || pipeline == null) {
					critical("Not all elements could be created.");
					return;
			}

			pipeline.add_many (source, videoconvert1, qrcodedec, videoconvert2, gtksink);


			if ( !source.link(videoconvert1) || !videoconvert1.link(qrcodedec) || !qrcodedec.link(videoconvert2) || !videoconvert2.link(gtksink) ) {
				critical("Elements could not be linked.");
				return;
			}

			// qrcode event
			//Signal.connect_swapped(qrcodedec, "qrcode", (Callback) on_qrcode, this);
			// qrcodedec.qrcode.connect(on_qrcode);
			Gst.Bus bus = pipeline.get_bus();
			bus.add_watch (0, bus_callback);

			add(video_area);

			show_all();
		}

		~Camera() {
			pipeline.set_state (Gst.State.NULL);
		}

		private bool bus_callback (Gst.Bus bus, Gst.Message message) {
		    switch (message.type) {
		        case MessageType.ERROR:
		            GLib.Error err; string debugstr;
		            message.parse_error (out err, out debugstr);
		            debug(debugstr);
		            critical(err.message);
		            break;
		        case MessageType.EOS:
		            debug("end of stream");
		            break;
		        case MessageType.STATE_CHANGED:
		            Gst.State oldstate;
		            Gst.State newstate;
		            Gst.State pending;
		            message.parse_state_changed (out oldstate, out newstate,
		                                         out pending);

		            debug("state changed: %s->%s:%s\n",
                            oldstate.to_string (), newstate.to_string (),
                            pending.to_string ());


				    this.state = newstate;
		            break;
		        case MessageType.ELEMENT:
                    Gst.Structure* s = message.get_structure();
                    if(s->get_name() == "qrcode") {
                        this.code_ready(s->get_string("symbol"));
                    }
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
				critical("Unable to set the pipeline to the playing state.");
				return;
			}

		}

		[GtkCallback]
		public void stop() {
			// Stop playing:
			Gst.StateChangeReturn ret = pipeline.set_state (Gst.State.PAUSED);
			if (ret == Gst.StateChangeReturn.FAILURE) {
				critical("Unable to set the pipeline to the playing state.");
				return;
			}
		}

		[GtkCallback]
		private void on_qrcode(string codestr) {
		    debug("on_qrcode: %s", codestr);
			//this.code_ready(codestr);
		}
	}
}
