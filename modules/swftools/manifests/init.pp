#/etc/puppet/modules/swftools/manifests/init.pp

class swftools (
  ) {

    package { 'swftools':
    ensure  => '0.9.1',
  }
}
