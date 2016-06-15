#/etc/puppet/modules/comdev_server/manifests/init.pp

class comdev_server (

) {

  vcsrepo { '/srv/nearby_people':
    ensure   => latest,
    provider => svn,
    source   => 'https://svn.apache.org/repos/asf/comdev/nearby_people',
  }

  file { '/srv/nearby_people/local_settings.py' :
    source  => '/srv/nearby_people/local_settings.py.example',
    require => Vcsrepo['/srv/nearby_people']
  }

  file { '/srv/nearby_people/data/uid-created.ldif' :
    ensure  => present,
    require => Vcsrepo['/srv/nearby_people']
  }

  file { '/srv/nearby_people/django-1.3' :
    ensure  => directory,
    require => Vcsrepo['/srv/nearby_people']
  }

  exec { '/srv/nearby_people/django-1.3' :
    command  => 'wget -qO- https://www.djangoproject.com/download/1.3.7/tarball/ | tar xz --strip-components=1',
    cwd     => '/srv/nearby_people/django-1.3',
    require => 'File[/srv/nearby_people/django-1.3]',
    creates => '/srv/nearby_people/django-1.3/README',
    path    => '/usr/bin:/bin'
  }

}

