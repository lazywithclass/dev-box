class javascript {
  exec{ 'fetch-nave':
    command => '/usr/bin/wget -q https://raw.githubusercontent.com/isaacs/nave/master/nave.sh -O /home/vagrant/bin/nave.sh',
    creates => '/home/vagrant/bin/nave.sh',
  }
  file{ '/home/vagrant/bin/nave.sh':
    mode => 0755,
    require => Exec['fetch-nave'],
  }
}
