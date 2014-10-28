*	Solid, platform independent multicast.

	Current implementation state:
		SO_REUSEADDR=1 to allow different servers simultaneously.
		0.0.0.0 (IPv4) and interface index 0 (IPv6) as interface for membership
			should select OS default interface.
		On OSX, ifindex 0 does not work:
			http://lists.apple.com/archives/darwin-kernel/2014/Mar/msg00012.html
		Therefor, set ifindex explicitly to en1 (or en0).
		Join 224.0.1.187, ff02::fd, and ff05::fd.
		OSX needs ff02::1 joined explicitly.

	(Remember configuring firewall accordingly.)

	Tests:
		Desktop (Arch Linux)				ok
		Notebook (Arch Linux)				ok
		VMs
			Debian (7.7)					IPv6 fail (timeout)
			Ubuntu (12.04 on Travis CI)		IPv6 fail (timeout)
			OSX (10.9.5)					ok
