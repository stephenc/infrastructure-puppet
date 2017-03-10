#/etc/puppet/modules/imagemagick/manifests/init.pp

class imagemagick (
  ) {

  class { "imagemagick::install":
  }

}
