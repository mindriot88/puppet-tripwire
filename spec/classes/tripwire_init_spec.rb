#!/usr/bin/env rspec

require 'spec_helper'
 
describe 'tripwire', :type => 'class' do

  context 'on a non-supported operatingsystem' do
    let :facts do {
      :osfamily => 'foo',
    }
    end
    it 'should fail' do
      expect {
        should raise_error(Puppet::Error, /Unsupported platform: foo/)
      }
    end
  end

  context 'on a supported operatingsystem, default parameters' do
    let :params do {
      :tripwire_site  => 'sitePW',
      :tripwire_local => 'localPW',
    }
    end
    let :facts do {
      :osfamily          => 'RedHat',
      :operatingsystem   => 'CentOS',
      :lsbmajdistrelease => '6',
      :architecture      => 'x86_64',
      :fqdn              => 'localhost.localdomain',
    }
    end
    it { should contain_package('tripwire').with(
      :ensure => 'present'
    )}
    it { should contain_file('site.key').with(
      :ensure  => 'present',
      :mode    => '0600',
      :owner   => 'root',
      :group   => 'root',
      :path    => '/etc/tripwire/site.key',
      :source  => 'puppet:///modules/tripwire/site.key',
      :require => 'Package[tripwire]'
    )}
#    it 'should contain File[site.key] with correct contents' do
#      verify_contents(catalogue, 'site.key', [
#        'HOSTNAME=localhost.localdomain',
#      ])
#    end
    it { should contain_file('twcfg.txt').with(
      :ensure  => 'present',
      :mode    => '0640',
      :owner   => 'root',
      :group   => 'root',
      :path    => '/etc/tripwire/twcfg.txt',
      :source  => 'puppet:///modules/tripwire/twcfg.txt',
      :require => 'Package[tripwire]'
    )}
    it { should contain_file('twpol.txt').with(
      :ensure  => 'present',
      :mode    => '0640',
      :owner   => 'root',
      :group   => 'root',
      :path    => '/etc/tripwire/twpol.txt',
      :source  => [ 'puppet:///modules/tripwire/twpol.txt-localhost.localdomain',
        'puppet:///modules/tripwire/twpol.txt-CentOS-6-x86_64',
        'puppet:///modules/tripwire/twpol.txt-CentOS-6',
        'puppet:///modules/tripwire/twpol.txt-CentOS',
        'puppet:///modules/tripwire/twpol.txt',
      ],
      :require => [ 'Package[tripwire]', 'Class[Lsb]', ]
    )}
    it { should contain_file('localhost.localdomain.twd').with(
      :ensure  => 'link',
      :target  => '/var/lib/tripwire/tripwire.twd',
      :owner   => 'root',
      :group   => 'root',
      :path    => '/var/lib/tripwire/localhost.localdomain.twd',
      :require => 'Exec[tripwire-init]'
    )}
    it { should contain_file('/etc/tripwire').with(
      :ensure  => 'directory',
      :mode    => '0700',
      :owner   => 'root',
      :group   => 'root',
      :path    => '/etc/tripwire',
      :require => 'Package[tripwire]'
    )}
    it { should contain_file('tripwire-setup-keyfiles').with(
      :ensure  => 'present',
      :mode    => '0750',
      :owner   => 'root',
      :group   => 'root',
      :path    => '/etc/tripwire/tripwire-setup-keyfiles',
      :source  => 'puppet:///modules/tripwire/tripwire-setup-keyfiles',
      :require => 'Package[tripwire]'
    )}
    it { should contain_exec('tripwire-setup-keyfiles').with(
      :command     => '/etc/tripwire/tripwire-setup-keyfiles',
      :creates     => '/etc/tripwire/local.key',
      :environment => [ 'TWLOCALPASS=localPW', 'TWSITEPASS=sitePW', ],
      :require     => [ 'File[tripwire-setup-keyfiles]', 'File[twpol.txt]', 'File[twcfg.txt]', 'File[site.key]', ]
    )}
    it { should contain_exec('tripwire-init').with(
      :command   => '/usr/sbin/tripwire --init --local-passphrase localPW --quiet',
      :creates   => '/var/lib/tripwire/tripwire.twd',
      :require   => 'Exec[tripwire-setup-keyfiles]',
      :timeout   => 10000,
      :logoutput => 'on_failure'
    )}
  end
end

