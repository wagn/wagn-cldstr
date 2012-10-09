New for 0.3.1:

* Made the `Runner` manually swappable, in case `ProcessRunner` doesn't work
  for some reason.
* Fixed copyright years.

New for 0.3.0:

* Support blank arguments.
* Add `CommandLine#unix?`.
* Add `CommandLine#exit_status`.
* Automatically use `POSIX::Spawn` if available.
* Add `CommandLine#environment` as a hash of extra `ENV` data..
* Add `CommandLine#runner` which produces an object that responds to `#call`.
* Fix a race condition but only on Ruby 1.9.
