#/etc/puppet/modules/imagemagick/manifests/init.pp

class imagemagick (
  ) {

    package { 'imagemagick':
    ensure  => present,
  }

}
