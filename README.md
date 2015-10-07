Puppet Tripwire Module
======================

master branch: [![Build Status](https://secure.travis-ci.org/razorsedge/puppet-tripwire.png?branch=master)](http://travis-ci.org/razorsedge/puppet-tripwire)
develop branch: [![Build Status](https://secure.travis-ci.org/razorsedge/puppet-tripwire.png?branch=develop)](http://travis-ci.org/razorsedge/puppet-tripwire)

Introduction
------------

This module installs and configures the [Open Source Tripwire](http://sourceforge.net/projects/tripwire/) package.

Actions:

* Installs tripwire.
* Configures tripwire.

OS Support:

* RedHat family - untested
* SuSE family   - presently unsupported (patches welcome)
* Debian family - presently unsupported (patches welcome)

Class documentation is available via puppetdoc.

Examples
--------

Parameterized Class:

    class { 'tripwire';
      tripwire_site  = 'sitePassPhrase',
      tripwire_local = 'nodePassPhrase',
    }


Notes
-----

* None

Issues
------

* Completely untested.

TODO
----

* Convert configuration files to templates.
* Require stahnma/puppet-module-epel.
* Validate input via stdlib.
* Apply normal razorsedge/puppet patterns ($ensure/$autoupgrade).

Contributing
------------

Please see DEVELOP.md for contribution information.

License
-------

Please see LICENSE file.

Copyright
---------

Copyright (C) 2012 Mike Arnold <mike@razorsedge.org>

[razorsedge/puppet-tripwire on GitHub](https://github.com/razorsedge/puppet-tripwire)

[razorsedge/tripwire on Puppet Forge](http://forge.puppetlabs.com/razorsedge/tripwire)

