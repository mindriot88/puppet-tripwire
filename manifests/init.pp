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
#    tripwire_site  = 'sitePassPhrase',
#    tripwire_local = 'nodePassPhrase',
#  }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2012 Mike Arnold, unless otherwise noted.
#
class tripwire (
  $tripwire_site,
  $tripwire_local
) inherits tripwire::params {
  package { 'tripwire':
    ensure => 'present',
  }

  file { 'site.key':
    ensure  => 'present',
    mode    => '0600',
    owner   => 'root',
    group   => 'root',
    require => Package['tripwire'],
    path    => '/etc/tripwire/site.key',
    source  => 'puppet:///modules/tripwire/site.key',
  }

  file { 'twcfg.txt':
    ensure  => 'present',
    mode    => '0640',
    owner   => 'root',
    group   => 'root',
    require => Package['tripwire'],
    path    => '/etc/tripwire/twcfg.txt',
    source  => 'puppet:///modules/tripwire/twcfg.txt',
  }

  file { 'twpol.txt':
    ensure  => 'present',
    mode    => '0640',
    owner   => 'root',
    group   => 'root',
    require => [ Package['tripwire'], Class['lsb'], ],
    path    => '/etc/tripwire/twpol.txt',
    source  => [
      "puppet:///modules/tripwire/twpol.txt-${::fqdn}",
      "puppet:///modules/tripwire/twpol.txt-${::operatingsystem}-${::lsbmajdistrelease}-${::architecture}",
      "puppet:///modules/tripwire/twpol.txt-${::operatingsystem}-${::lsbmajdistrelease}",
      "puppet:///modules/tripwire/twpol.txt-${::operatingsystem}",
      'puppet:///modules/tripwire/twpol.txt',
    ],
  }

  file { "${::fqdn}.twd":
    ensure  => 'link',
    target  => '/var/lib/tripwire/tripwire.twd',
    owner   => 'root',
    group   => 'root',
    require => Exec['tripwire-init'],
    path    => "/var/lib/tripwire/${::fqdn}.twd",
  }

  file { '/etc/tripwire':
    ensure  => 'directory',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    require => Package['tripwire'],
    path    => '/etc/tripwire',
  }

  file { 'tripwire-setup-keyfiles':
    ensure  => 'present',
    mode    => '0750',
    owner   => 'root',
    group   => 'root',
    require => Package['tripwire'],
    path    => '/etc/tripwire/tripwire-setup-keyfiles',
    source  => 'puppet:///modules/tripwire/tripwire-setup-keyfiles',
  }

  exec { 'tripwire-setup-keyfiles':
    command     => '/etc/tripwire/tripwire-setup-keyfiles',
    creates     => '/etc/tripwire/local.key',
    environment => [
      "TWLOCALPASS=${tripwire_local}",
      "TWSITEPASS=${tripwire_site}",
    ],
    require     => [
      File['tripwire-setup-keyfiles'],
      File['twpol.txt'],
      File['twcfg.txt'],
      File['site.key'],
    ],
  }

  exec { 'tripwire-init':
    command   => "/usr/sbin/tripwire --init --local-passphrase ${tripwire_local} --quiet",
    creates   => '/var/lib/tripwire/tripwire.twd',
    #path      => '/sbin:/usr/sbin:/usr/local/sbin',
    require   => Exec['tripwire-setup-keyfiles'],
    timeout   => 10000,
    logoutput => on_failure,
  }

#  exec { 'tripwire-update-policy':
#    command     => "/usr/sbin/tripwire --update-policy -Z low --local-passphrase $tripwire_local --site-passphrase $tripwire_site --quiet /etc/tripwire/twpol.txt",
#    cwd         => '/etc/tripwire',
#    refreshonly => 'true',
#    subscribe   => File['twpol.txt'],
#    timeout     => 10000,
#    logoutput   => on_failure,
#  }
}
