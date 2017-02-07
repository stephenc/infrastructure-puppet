##/etc/puppet/modules/buildbot_slave/manifests/docker.pp

class buildbot_slave::docker ( ) {

  require buildbot_slave

  package { 'docker-engine':                                                         
      ensure => 'present',                                                      
  }    

  group { 'docker':
      ensure => present,
  }->

  user { $buildbot_slave::username:
      require    => Group[$buildbot_slave::groupname, 'docker'],
  }

}
