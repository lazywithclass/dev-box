class javascript {
  exec { 'fetch-nave':
    command => '/usr/bin/wget -q https://raw.githubusercontent.com/isaacs/nave/master/nave.sh -O /home/vagrant/bin/nave.sh',
    creates => '/home/vagrant/bin/nave.sh'
  }
  exec { 'make-nave-executable':	
    command => "/bin/chmod 744 /home/vagrant/bin/nave.sh",
    require => Exec['fetch-nave']
  }
  exec { 'install-nodejs-stable':
    command => '/home/vagrant/bin/nave.sh usemain stable',
    require => Exec['make-nave-executable']
  }
}
