#/usr/local/etc/puppet/modules/base/manifests/init.pp

class base (
  $basepackages   = [],
  $gempackages    = [],
  $purgedpackages = [],
  $pkgprovider    = '',
  $rsync_secrets  = '',
) {

  $packages = hiera_array('base::basepackages', [])

  package { $packages:
    ensure =>  installed,
  }

  package { $gempackages:
    ensure   => installed,
    provider => 'gem',
  }

  package { $purgedpackages:
    ensure => purged,
  }

  # hiera_hash+create_resources used to instantiate puppet "defines"
  # via hiera/yaml, since there is no associated class.

  $hosts = hiera_hash('base::hosts', {})
  create_resources(host, $hosts)

  $perl_module = hiera_hash('perl::module', {})
  create_resources(perl::module, $perl_module)

  $logrotate_rule = hiera_hash('logrotate::rule', {})
  create_resources(logrotate::rule, $logrotate_rule)

  $crons = hiera_hash('cron', {})
  create_resources(cron, $crons)

  $files = hiera_hash('file', {})
  create_resources(file, $files)

  $rsync_modules = hiera_hash('rsync::server::module', {})
  create_resources(rsync::server::module, $rsync_modules)

  $stunnels = hiera_hash('stunnel::tun', {})
  create_resources(stunnel::tun, $stunnels)

  $awscli_profile = hiera_hash('awscli::profile', {})
  create_resources(awscli::profile, $awscli_profile)

  $vcsrepo = hiera_hash('vcsrepo',{})
  create_resources(vcsrepo, $vcsrepo)

  $certonly = hiera_hash('letsencrypt::certonly',{})
  create_resources(letsencrypt::certonly, $certonly)

  $cacerts = hiera_hash('ca_cert::ca',{})
  create_resources(ca_cert::ca, $cacerts)

  $tcinstance = hiera_hash('tomcat::instance',{})
  create_resources(tomcat::instance, $tcinstance)

  $tcservice = hiera_hash('tomcat::service',{})
  create_resources(tomcat::service, $tcservice)

  $tcwar = hiera_hash('tomcat::war', {})
  create_resources(tomcat::war, $tcwar)

  $tcconfig = hiera_hash('tomcat::config',{})
  create_resources(tomcat::config, $tcconfig)

  $tcinstall = hiera_hash('tomcat::install',{})
  create_resources(tomcat::install, $tcinstall)

  class { "base::install::${::asfosname}::${::asfosrelease}":
  }
}
