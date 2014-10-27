Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/node' ] }

file { '/home/vagrant/bin':
  ensure => 'directory',
  owner => 'vagrant',
  group => 'vagrant'
}

file { '/home/vagrant/workspace':
  ensure => 'directory',
  owner => 'vagrant',
  group => 'vagrant'
}

class nodejs {
  exec { 'install-curl':
    command => 'apt-get install curl --assume-yes'
  }
  exec { 'get-nave':	
    command => 'wget https://raw.github.com/isaacs/nave/master/nave.sh -O /home/vagrant/bin/nave',
    require => Exec['install-curl'],
    creates => '/home/vagrant/bin/nave'
  }
  file { '/home/vagrant/bin/nave':
    mode => 744,
    owner => 'vagrant',
    group => 'vagrant',
    require => Exec['get-nave']
  }
  exec { 'node':	
    command => '/home/vagrant/bin/nave usemain stable',
    creates => '/usr/local/bin/node',
    require => File['/home/vagrant/bin/nave']
  }
}

include nodejs
