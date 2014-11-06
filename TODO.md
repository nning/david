TODO
====

Solid, platform independent multicast
-------------------------------------

### Current implementation state:

* SO_REUSEADDR=1 to allow different servers simultaneously.
* 0.0.0.0 (IPv4) and interface index 0 (IPv6) as interface for membership
  should select OS default interface.
* On OSX, ifindex 0 does not work:
  * http://lists.apple.com/archives/darwin-kernel/2014/Mar/msg00012.html
  * Therefore, set ifindex explicitly to en1 (or en0).
* Join 224.0.1.187, ff02::fd, and ff05::fd.
  * OSX needs ff02::1 joined explicitly.

(Remember configuring firewall accordingly.)

### Tests:

    Desktop (Arch Linux)        ok
    Notebook (Arch Linux)       ok
    Debian (7.7, KVM)           IPv6 fail (timeout)
    Ubuntu (12.04, Travis CI)   IPv6 fail (timeout)
    OSX (10.9.5, KVM)           ok


Better blockwise transfer support
---------------------------------

### Current implementation state:

* The server supports control usage of block messages, so block only works for
  outbound documents.

### Features to be implemented:

* Handling of blockwise PUT or POST.
* Caching of documents so that a Rack app call is not necessary for every
  block.
