Exec { 
  path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/', '/usr/local/bin' ],
  timeout => 999999
}

exec { 'system-update':
  command => 'apt-get update'
}

file { '/home/vagrant/bin':
  ensure => 'directory',
  owner => 'vagrant',
  group => 'vagrant'
}

class system {
  package { 
    ['tree', 'mplayer', 'xubuntu-desktop', 'zsh']: 
      ensure => 'installed',
      require => Exec['system-update']
  }
}

class nodejs {
  package { 'curl':
    ensure => 'installed',
    require => Exec['system-update']
  }
  exec { 'get-nave':	
    command => 'wget https://raw.github.com/isaacs/nave/master/nave.sh -O /home/vagrant/bin/nave',
    creates => '/home/vagrant/bin/nave',
    require => Package['curl']
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

class emacs {
  package { 'python-software-properties':
    ensure => 'installed',
    require => Exec['system-update']
  }  
  exec { 'use-the-ppa':
    command => 'add-apt-repository ppa:ubuntu-elisp/ppa -y',
    require => Package['python-software-properties'],
    onlyif => 'whereis emacs && return 1'
  }
  exec { 'update-for-emacs':
    command => 'apt-get update',
    require => Exec['use-the-ppa'],
    onlyif => 'whereis emacs && return 1'
  }
  package { 'emacs-snapshot':
    ensure => 'installed',
    require => Exec['update-for-emacs']
  }
}

class workspace {
  file { '/home/vagrant/workspace':
    ensure => 'directory',
    owner => 'vagrant',
    group => 'vagrant'
  }
  exec { 'clone-dotfiles':
    command => 'git clone git@github.com:lazywithclass/dotfiles.git /home/vagrant/workspace/dotfiles',
    user => 'vagrant',
    creates => '/home/vagrant/workspace/dotfiles',
    require => File['/home/vagrant/workspace']
  }
}


include system
include nodejs
include emacs
include workspace
