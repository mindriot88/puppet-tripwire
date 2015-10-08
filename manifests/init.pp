# == Class: tripwire
#
# This class handles installing and configuring the Open Source Tripwire
# package.
#
# === Parameters:
#
# [*tripwire_site*]
#   The passphrase for the site.key file.
#   Default: none
#
# [*tripwire_local*]
#   The passphrase for the local.key file.
#   Default: none
#
# [*tripwire_emailto*]
#   An array of email addresses used for tripwires email reporting.
#   Default: undef
#
# === Actions:
#
# Installs tripwire.
# Configures tripwire.
#
# === Requires:
#
# Nothing.
#
# === Sample Usage:
#
#  class { 'tripwire':
#    tripwire_site  => 'sitePassPhrase',
#    tripwire_local => 'nodePassPhrase',
#    tripwire_emailto => [ "joe@example.com", "jane@example.com" ];
#  }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>, Jason Pereira <jason.pereira@sohonet.com>
#
# === Copyright:
#
# Copyright (C) 2012 Mike Arnold, unless otherwise noted.
#
class tripwire (
  $tripwire_site,
  $tripwire_local,
  $tripwire_emailto = undef,
) inherits tripwire::params {

  package { 'tripwire':
    ensure => 'present',
  }

  file { 'twcfg.txt':
    ensure  => 'present',
    mode    => '0640',
    owner   => 'root',
    group   => 'root',
    require => Package['tripwire'],
    path    => '/etc/tripwire/twcfg.txt',
    content => template("tripwire/twcfg.txt.erb"),
  }

  file { 'twpol.txt':
    ensure  => 'present',
    mode    => '0640',
    owner   => 'root',
    group   => 'root',
    require => Package['tripwire'],
    path    => '/etc/tripwire/twpol.txt',
    content  => [
	template("tripwire/twpol.txt.erb"),
    ],
  }

  file { '/etc/tripwire':
    ensure  => 'directory',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    require => Package['tripwire'],
    path    => '/etc/tripwire',
  }

  exec { 'tripwire-gen-key':
    command   => "/bin/rm /etc/tripwire/site.key /etc/tripwire/${::hostname}-local.key && /usr/sbin/twadmin --generate-keys --local-passphrase ${tripwire_local} --site-passphrase ${tripwire_site} --site-keyfile /etc/tripwire/site.key --local-keyfile /etc/tripwire/${::hostname}-local.key",
    creates => [
	"/var/lib/tripwire/${::hostname}.twd",
    ],
    require     => [
	File['twpol.txt'],
	File['twcfg.txt'],
    ],
    refreshonly => false,
    timeout   => 10000,
    logoutput => on_failure,
  }

  exec { 'tripwire-create-cfg':
    command   => "/usr/sbin/twadmin --create-cfgfile -S /etc/tripwire/site.key -Q ${tripwire_site}  /etc/tripwire/twcfg.txt",
    require   => [
        File['twpol.txt'],
        File['twcfg.txt'],
    ],
    subscribe  => [
	Exec['tripwire-gen-key'],
	File['twcfg.txt'],
    ],
    refreshonly => true,
    timeout   => 10000,
    logoutput => on_failure,
  }

  exec { 'tripwire-create-polfile':
    command   => "/usr/sbin/twadmin --create-polfile -e /etc/tripwire/twpol.txt",
    require   => [
        File['twpol.txt'],
        File['twcfg.txt'],
    ],
    subscribe  => Exec['tripwire-gen-key'],
    refreshonly => true,
    timeout   => 10000,
    logoutput => on_failure,
  }

  exec { 'tripwire-init':
    command   => "/usr/sbin/tripwire --init --local-passphrase ${tripwire_local} --quiet",
    creates   => '/var/lib/tripwire/tripwire.twd',
    refreshonly => true,
    require   => [
	Exec['tripwire-gen-key'],
	Exec['tripwire-create-cfg'],
	Exec['tripwire-create-polfile'],
    ],
    subscribe  => Exec['tripwire-create-polfile'],
    timeout   => 10000,
    logoutput => on_failure,
  }

  exec { 'tripwire-update-policy':
    command     => "/usr/sbin/tripwire --update-policy --secure-mode low --local-passphrase $tripwire_local --site-passphrase $tripwire_site --quiet /etc/tripwire/twpol.txt",
    cwd         => '/etc/tripwire',
    refreshonly => 'true',
    subscribe   => File['twpol.txt'],
    onlyif	=> "/usr/bin/test -e /var/lib/tripwire/${::hostname}.twd",
    timeout     => 10000,
    logoutput   => on_failure,
  }

}
