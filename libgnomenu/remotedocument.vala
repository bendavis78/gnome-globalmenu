using GLib;
using Gtk;
using Gnomenu;
using XML;
using DBus;

namespace Gnomenu {
	public class RemoteDocument: Document {
		private Parser parser;
		private dynamic DBus.Object remote;
		private dynamic DBus.Connection conn;
		private XML.Node _root;
		public XML.Node root {
			get {
				return _root;
			}
		}
		public string path {get; construct;}
		public string bus {get; construct;}
		
		public RemoteDocument(string bus, string path) {
			this.path = path;
			this.bus = bus;
		}
		construct {
			_root = new XML.Document.Root(this);
			conn = Bus.get(DBus.BusType.SESSION);
			remote = conn.get_object(bus, path, "org.gnome.GlobalMenu.Document");
			remote.Inserted += remote_inserted;
			remote.Removed += remote_removed;
			remote.Updated += remote_updated;
			parser = new XML.Parser(this);

			string clients = remote.QueryRoot(0);
			parser.parse(clients);
			this.activated += (doc, node) => {
				try {
					remote.Activate(node.name);
				} catch(GLib.Error e){
					warning("%s", e.message);
				}
			};
		}
		private void remote_inserted(dynamic DBus.Object remote, string parentname, string nodename, int pos) {
			weak XML.Node parent = lookup(parentname);
			try {
				string s = remote.QueryNode(nodename, 0);
				if(s == null) {
					warning("remote document didn't reply");
					return;
				}
				parser.parse_child(parent, s, pos);
			} catch(GLib.Error e){
				warning("%s", e.message);
			}
		}
		private void remote_removed(dynamic DBus.Object remote, string parentname, string nodename) {
			weak XML.Node parent = lookup(parentname);
			weak XML.Node node = lookup(nodename);
			parent.remove(node);
		}
		private void remote_updated(dynamic DBus.Object remote, string nodename, string propname) {
			weak XML.Document.Tag node = lookup(nodename) as XML.Document.Tag;
			message("updated %s", nodename);
			try {
				string s = remote.QueryNode(nodename, 0);
				if(s == null) {
					warning("remote document didn't reply");
					return;
				}
				parser.update_tag(node, propname, s);
			} catch(GLib.Error e){
				warning("%s", e.message);
			}
		}

		public static int test(string[] args) {
			Gtk.init(ref args);
			MainLoop loop = new MainLoop(null, false);
			RemoteDocument document = new RemoteDocument("org.gnome.GlobalMenu.Server", "/org/gnome/GlobalMenu/Server");
			ListView viewer = new ListView(document);
			Gtk.Window window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);
			window.add(viewer);
			window.show_all();
			loop.run();
			return 0;
		}
	}
}
