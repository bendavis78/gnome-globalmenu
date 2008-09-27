using GLib;
using Gdk;
using Gtk;
using DBus;
using XML;
namespace Gnomenu {
	[DBus (name = "org.gnome.GlobalMenu.Client")]
	public class Client:DBusView {
		Connection conn;
		public string bus;
		dynamic DBus.Object dbus;
		dynamic DBus.Object server;
		public Client(Document document) {
			this.document = document;
			this.path = "/org/gnome/GlobalMenu/Application";
		}
		construct {
			conn = Bus.get(DBus.BusType.SESSION);
			dbus = conn.get_object("org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus");
			server = conn.get_object("org.gnome.GlobalMenu.Server", "/org/gnome/GlobalMenu/Server", "org.gnome.GlobalMenu.Server");
			
			Rand rand = new Rand();
			uint r;
			do {
				string str = rand.next_int().to_string().strip();
				bus = "org.gnome.GlobalMenu.Applications." + Environment.get_prgname() + "-" + str;
				message("Obtaining BUS name: %s", bus);
				r = dbus.RequestName (bus, (uint) 0);
			} while(r != DBus.RequestNameReply.PRIMARY_OWNER);
		}
		public string QueryXID(string xid) {
			weak Document.Widget node = find_window_by_xid(xid);
			if(node != null) {
				return node.name;
			}
			return "";
		}

		private weak Document.Widget? find_window_by_xid(string xid) {
			foreach (weak XML.Node node in document.root.children) {
				if(node is Document.Widget) {
					weak Document.Widget widget = node as Document.Widget;
					if(widget.get("xid") == xid) {
						return widget;
					}
				}
			}
			return null;
		}
		private void add_widget(string? parent, string name, int pos = -1) {
			weak XML.Node node = document.lookup(name);
			weak XML.Node parent_node;
			if(parent == null) {
				parent_node = document.root;
			}
			else {
				parent_node = document.lookup(parent);
			}
			if(node == null) {
				string[] names = {"name"};
				string[] values = {name};
				XML.Document.Tag node = document.CreateTagWithAttributes("widget", names, values);
				parent_node.insert(node, pos);
			}
		}
		private void remove_widget(string name) {
			weak Document.Widget node = document.lookup(name) as Document.Widget;
			if(node != null) {
				assert(node.parent != null);
				node.parent.remove(node);
				node = null;
			}
		}
		[DBus (visible = false)]
		protected void register_window(string name, string xid) {
			weak Document.Widget node = document.lookup(name) as Document.Widget;
			if(node != null) {
				node.set("xid", xid);
				try {
					server.RegisterWindow(this.bus, xid);
				} catch(GLib.Error e) {
					warning("%s", e.message);
				}
			}
		}
		[DBus (visible = false)]
		protected void unregister_window(string name) {
			weak Document.Widget node = document.lookup(name) as Document.Widget;
			if(node != null) {
				weak string xid = node.get("xid");
				try {
					server.RemoveWindow(this.bus, xid);
				} catch(GLib.Error e) {
					warning("%s", e.message);
				}
				node.unset("xid");
			}

		}
		public static int test(string[] args) {
			Gtk.init(ref args);
			MainLoop loop = new MainLoop(null, false);
			Document document = new Document();
			Client c = new Client(document);
			c.add_widget(null, "window1");
			c.add_widget(null, "window2");
			c.add_widget("window1", "menu1");
			c.add_widget("window2", "menu2");
			c.register_window("window1", "0000000");
			c.register_window("window2", "0000001");
//			c.remove_widget("window1");
			loop.run();
			return 0;
		}
	}
}
