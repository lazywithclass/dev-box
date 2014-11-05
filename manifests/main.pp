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

package { 'python-software-properties':
  ensure => 'installed',
  require => Exec['system-update']
}  

class system {
  package { 
    ['tree', 'mplayer', 'xubuntu-desktop', 'zsh', 'terminator', 'gimp']: 
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

# check to avoid adding ppa and updating every time
class emacs {
  exec { 'use-the-emacs-ppa':
    command => 'add-apt-repository ppa:ubuntu-elisp/ppa -y',
    require => Package['python-software-properties'],
    unless => 'test -f /usr/bin/emacs-snapshot'
  }
  exec { 'update-for-emacs':
    command => 'apt-get update',
    require => Exec['use-the-emacs-ppa'],
    unless => 'test -f /usr/bin/emacs-snapshot'
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

# check to avoid adding ppa and updating every time
class chrome {
  exec { 'get-the-key':
    command => 'wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -',
    require => Package['python-software-properties'],
    unless => 'test -f /usr/bin/google-chrome'
  }
  exec { 'add-key-to-repository':
    command => 'sh -c \'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list\'',
    require => Exec['get-the-key'],
    unless => 'test -f /usr/bin/google-chrome'
  }
  exec { 'update-for-chrome':
    command => 'apt-get update',
    require => Exec['add-key-to-repository'],
    unless => 'test -f /usr/bin/google-chrome'
  }
  package { 'google-chrome-stable':
    ensure => 'installed',
    require => Exec['update-for-chrome']
  }
}

# check to avoid adding ppa and updating every time
class skype {
  exec { 'use-the-skype-ppa':
    command => 'add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner"',
    require => Package['python-software-properties'],
    unless => 'test -f /usr/bin/skype'
  }
  exec { 'update-for-skype':
    command => 'apt-get update',
    require => Exec['use-the-skype-ppa'],
    unless => 'test -f /usr/bin/skype'
  }
  package { 'skype':
    ensure => 'present',
    require => Exec['update-for-skype']
  }
}

include system
include nodejs
include emacs
include workspace
include chrome
include skype
