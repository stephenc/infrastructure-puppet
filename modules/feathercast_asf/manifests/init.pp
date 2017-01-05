#/etc/puppet/modules/feathercast_asf/manifests/init.pp

class feathercast_asf (
  $group_present                 = 'present',
  $groupname                     = 'feathercast',
  $groups                        = [],
  $service_ensure                = 'stopped',
  $service_name                  = 'feathercast',
  $shell                         = '/bin/bash',
  $user_present                  = 'present',
  $username                      = 'feathercast',

  # override below in yaml
  $parent_dir,
  $server_port                   = '',
  $connector_port                = '',
  $context_path                  = '',

  $required_packages             = ['unzip','wget','libmysql-java'],
){

# install required packages:
  package {
    $required_packages:
      ensure => 'present',
  }

  file { 'feathercast profile':
    ensure  => 'present',
    path    => "/home/${username}/.profile",
    mode    => '0644',
    owner   => $username,
    group   => $groupname,
    #source  => 'puppet:///modules/feathercast_asf/home/profile',
    require => User[$username],
  }

# wordpress specific
  $wordpress_build          = "wordpress-${wordpress_version}"
  $tarball                  = "${wordpress_build}.tar.gz"
  $download_dir             = '/tmp'
  $downloaded_tarball       = "${download_dir}/${tarball}"
  $download_url             = "https://wordpress.org/${tarball}"
  $install_dir              = "${parent_dir}/${wordpress_build}"
  $wordpress_home           = "${parent_dir}/wordpress-data"
  $current_dir              = "${parent_dir}/current"

  user {
    $username:
      ensure     => $user_present,
      name       => $username,
      home       => "/home/${username}",
      shell      => $shell,
      groups     => $groups,
      gid        => $groupname,
      managehome => true,
      require    => Group[$groupname],
      system 	 => true,
  }

  group {
    $groupname:
      ensure => $group_present,
      system => true,
  }
  
# download standalone wordpress
  exec {
    'download-wordpress':
      command => "/usr/bin/wget -O ${downloaded_tarball} ${download_url}",
      creates => $downloaded_tarball,
      timeout => 1200,
  }

  file { $downloaded_zip:
    ensure  => file,
    require => Exec['download-tarball'],
  }
  
  
# extract the download and move it
  exec {
    'extract-wordpress':
      # take out the hardcoded fecru bits   
      command => "/bin/tar -xvzf ${tarball} && mv ${wordpress_build} ${parent_dir}", # lint:ignore:80chars
      cwd     => $download_dir,
      user    => 'root',
      creates => "${install_dir}/README.html",
      timeout => 1200,
      require => [File[$downloaded_tarball],File[$parent_dir]],
  }
 
file {
    $parent_dir:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755';
    $feathercast_home:
      ensure  => directory,
      owner   => 'feathercast',
      group   => 'feathercast',
      mode    => '0755',
      require => File[$install_dir];
    $install_dir:
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      require => Exec['extract-feathercast'];
    $current_dir:
      ensure  => link,
      target  => $install_dir,
      owner   => 'root',
      group   => 'root',
      require => File[$install_dir];
    "${feathercast_home}/lib":
      ensure  => directory,
      owner   => 'feathercast',
      group   => 'feathercast',
      mode    => '0755',
      require => File[$feathercast_home];
    "${feathercast_home}/lib/mysql-connector-java-5.1.38.jar":
      ensure  => link,
      target  => '/usr/share/java/mysql-connector-java-5.1.38.jar',
      require => Package['libmysql-java'];
    "/home/${username}/.subversion":
      ensure  => directory,
      owner   => 'feathercast',
      group   => 'feathercast',
      mode    => '0755',
      require => [Package['subversion'],User[$username]];
    "/home/${username}/.subversion/servers":
      ensure  => present,
      owner   => 'feathercast',
      group   => 'feathercast',
      mode    => '0644',
      source  => "puppet:///modules/feathercast_asf/home/subversion/servers",
      require => [Package['subversion'],File["/home/${username}/.subversion"]];
  }    
}
