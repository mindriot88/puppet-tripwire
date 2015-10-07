# == Class: tripwire::params
#
# This class handles OS-specific configuration of the tripwire module.  It
# looks for variables in top scope (probably from an ENC such as Dashboard).  If
# the variable doesn't exist in top scope, it falls back to a hard coded default
# value.
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#
class tripwire::params {
#    content => $operatingsystem ? {
#      /(centos|redhat|oel)/ => $operatingsystemrelease ? {
#        "5"     => template("tripwire/twpol.txt-CentOS-5.erb"),
#        "4"     => template("tripwire/twpol.txt-CentOS-4.erb"),
#        default => template("tripwire/twpol.txt-CentOS.erb"),
#      },
#      Fedora                => $operatingsystemrelease ? {
#        "12"    => $architecture ? {
#          "i686"    => template("tripwire/twpol.txt-Fedora-12-i686.erb"),
#          "x86_64"  => template("tripwire/twpol.txt-Fedora-12-x86_64.erb"),
#          "powerpc" => template("tripwire/twpol.txt-Fedora-12-powerpc.erb"),
#          default   => template("tripwire/twpol.txt-Fedora-12.erb"),
#        default => template("tripwire/twpol.txt-Fedora.erb"),
#      default               => template("tripwire/twpol.txt.erb"),
#    },
}
