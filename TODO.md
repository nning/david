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


More detailed CoAP implementation
---------------------------------

### Examples for missing or unsufficient features:

* Message Deduplication (4.5.)
* Transmission Parameters (4.8.)
* Request/Response Matching (5.3.2.) (became transparent in connection to
  observe transmissions)
* "For a new Confirmable message, the initial timeout is set to a random
  duration (often not an integral number of seconds) between ACK_TIMEOUT and
  (ACK_TIMEOUT * ACK_RANDOM_FACTOR) (see Section 4.8)"
* Validation of ETag
* Request validations and error responses


Non-blocking I/O
----------------

* Check if I/O in Rack environment blocks or can block and what possibilities
  exist to make it non-blocking.


Observe
-------

* Garbage collection.
* Observe on .well-known/core returns "Resource not observable" but Observe
  actor still calls Rails in tick.
