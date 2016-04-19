#/etc/puppet/modules/build_slaves/manifests/jenkins.pp

include apt

class build_slaves::jenkins (
  $nexus_password   = '',
  $npmrc_password    = '',
  $jenkins_pub_key  = '',
  $jenkins_packages = []
  ) {

  require stdlib
  require build_slaves

  apt::ppa { 'ppa:ubuntu-lxc/lxd-stable': 
    ensure => present,
  }->

  package { 'golang':
    ensure => present,
  }

  group { 'jenkins':
    ensure => present,
  }

  group { 'docker':
    ensure => present,
  }->

  user { 'jenkins':
    ensure     => present,
    require    => Group['jenkins'],
    shell      => '/bin/bash',
    managehome => true,
    groups     => ['docker', 'jenkins'],
  }

  file {'/home/jenkins/tools':
    ensure => 'directory',
    owner  => 'jenkins',
    group  => 'jenkins',
  }

  file {'/home/jenkins/tools/clover':
    ensure  => 'link',
    target  => '/usr/local/jenkins/clover'
    require => File['/usr/local/jenkins/clover'],
    owner   => 'jenkins',
    group   => 'jenkins',
  }

  file {'/home/jenkins/tools/findbugs':
    ensure  => 'link',
    target  => '/usr/local/jenkins/findbugs'
    require => File['/usr/local/jenkins/findbugs'],
    owner   => 'jenkins',
    group   => 'jenkins',
  }

  file {'/home/jenkins/tools/forrest':
    ensure  => 'link',
    target  => '/usr/local/jenkins/forrest'
    require => File['/usr/local/jenkins/forrest'],
    owner   => 'jenkins',
    group   => 'jenkins',
  }

 file {'/home/jenkins/tools/java':
    ensure  => 'link',
    target  => '/usr/local/jenkins/java'
    require => File['/usr/local/jenkins/java'],
    owner   => 'jenkins',
    group   => 'jenkins',
  }

  file {'/home/jenkins/tools/jiracli':
    ensure  => 'link',
    target  => '/usr/local/jenkins/jiracli'
    require => File['/usr/local/jenkins/jiracli'],
    owner   => 'jenkins',
    group   => 'jenkins',
  }

  file { '/home/jenkins/env.sh':
    ensure => present,
    mode   => '0755',
    source => 'puppet:///modules/build_slaves/jenkins_env.sh',
    owner  => 'jenkins',
    group  => 'jenkins',
  }

  file { '/etc/ssh/ssh_keys/jenkins.pub':
    ensure  => present,
    mode    => '0640',
    source  => 'puppet:///modules/build_slaves/jenkins.pub',
    owner   => 'jenkins',
    group   => 'root',
  }

  file { '/home/jenkins/.m2':
    ensure  => directory,
    require => User['jenkins'],
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0755'
  }

  file { '/home/jenkins/.buildr':
    ensure  => directory,
    require => User['jenkins'],
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0755'
  }

  file { '/home/jenkins/.m2/settings.xml':
    ensure  => present,
    require => File['/home/jenkins/.m2'],
    path    => '/home/jenkins/.m2/settings.xml',
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0640',
    content => template('build_slaves/m2_settings.erb')
  }

  file { '/home/jenkins/.m2/toolchains.xml':
    ensure  => present,
    require => File['/home/jenkins/.m2'],
    path    => '/home/jenkins/.m2/toolchains.xml',
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0640',
    source => 'puppet:///modules/build_slaves/toolchains.xml',
  }

  file { '/home/jenkins/.buildr/settings.yaml':
    ensure  => present,
    require => File['/home/jenkins/.buildr'],
    path    => '/home/jenkins/.buildr/settings.yaml',
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0640',
    content => template('build_slaves/buildr_settings.erb')
  }

  file { '/home/jenkins/.npmrc':
    ensure  => present,
    path    => '/home/jenkins/.npmrc',
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0640',
    content => template('build_slaves/npmrc.erb')
  }

  file { '/etc/security/limits.d/jenkins.conf':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/build_slaves/jenkins_limits.conf',
    require => File['/etc/security/limits.d'],
  }

  file_line { 'USERGROUPS_ENAB':
    path  => '/etc/login.defs',
    line  => 'USERGROUPS_ENAB no',
    match => '^USERGROUPS_ENAB.*'
  }

  package { $jenkins_packages:
    ensure   => installed,
  }

  service { 'apache2':
    ensure => 'stopped',
  }


}
