NULL =
SUBDIRS = \
	src \
        extension \
	$(NULL)

#	globalmenu-plugin 

DISTCHECK_CONFIGURE_FLAGS = --enable-introspection

AM_CPPFLAGS = \
		$(NULL)

gsettingsdir = $(GSCHEMASDIR)
gsettings_DATA= org.globalmenu.gschema.xml

dbusdir = $(SERVICESDIR)
dbus_DATA = org.globalmenu.manager.service

profiledir = $(sysconfdir)/profile.d
profile_DATA = globalmenu.sh

org.globalmenu.manager.service: org.globalmenu.manager.service.in Makefile
	sed "s;@BINDIR@;$(bindir);" < $< > $@
install-data-hook:
	echo dest is $(DESTDIR)
	$(GLIB_COMPILE_SCHEMAS) $(DESTDIR)$(GSCHEMASDIR)

uninstall-hook:
	$(GLIB_COMPILE_SCHEMAS) $(DESTDIR)$(GSCHEMASDIR)

man_MANS = gnome-globalmenu.1

EXTRA_DIST = \
	org.globalmenu.manager.service.in \
	org.globalmenu.gschema.xml \
	globalmenu.sh \
	$(man_MANS) \
	$(doc_DATA) \
	intltool-extract.in \
	intltool-merge.in \
	intltool-update.in \
	$(NULL)

DISTCLEANFILES = \
	intltool-extract \
	intltool-merge \
	intltool-update \
	$(NULL)


CLEANFILES = org.globalmenu.manager.service


doc_DATA = README COPYING ChangeLog AUTHORS INSTALL

