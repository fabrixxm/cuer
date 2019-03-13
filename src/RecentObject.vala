namespace Cuer {

class RecentObject : Object {
    public  Gtk.RecentInfo info;

    public static RecentObject create(Gtk.RecentInfo info) {
        var ro = new RecentObject();
        ro.info = info;
        return ro;
    }
}
}
