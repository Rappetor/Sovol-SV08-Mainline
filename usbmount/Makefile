.PHONY: install
install:
	install -D makerbase-automount $(DESTDIR)$(PREFIX)/bin/makerbase-automount
	install -Dm644 60-usbmount.rules $(DESTDIR)$(PREFIX)/lib/udev/rules.d/60-usbmount.rules
	install -Dm644 makerbase-automount@.service $(DESTDIR)$(PREFIX)/lib/systemd/system/makerbase-automount@.service
	install -d $(DESTDIR)/etc/makerbase-automount.d
	install -Cm644 makerbase-automount.d/* $(DESTDIR)/etc/makerbase-automount.d/

clean:
	sudo rm $(DESTDIR)$(PREFIX)/bin/makerbase-automount
	sudo rm $(DESTDIR)$(PREFIX)/lib/udev/rules.d/60-usbmount.rules
	sudo rm $(DESTDIR)$(PREFIX)/lib/systemd/system/makerbase-automount@.service
	sudo rm -rf $(DESTDIR)/etc/makerbase-automount.d