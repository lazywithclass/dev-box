Exec { 
  path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/', '/usr/local/bin' ],
  timeout => 999999
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
  exec { 'system-update':
    command => 'apt-get update'
  }
  exec { 'system-upgrade':
    command => 'apt-get upgrade -y',
    require => Exec['system-update']
  }
  exec { 'system-dist-upgrade':
    command => 'apt-get upgrade -y',
    require => Exec['system-upgrade']
  }
  package { 
    ['tree', 'mplayer', 'xubuntu-desktop', 'zsh', 'terminator', 'gimp', 'virtualbox-guest-dkms', 'virtualbox-guest-utils', 'virtualbox-guest-x11', 'vim', 'tmux', 'fortune-mod', 'texinfo', 'expect', 'htop', 'calibre', 'erlang', 'markdown']: 
      ensure => 'installed',
      require => Exec['system-update']
  }
  file { '/home/vagrant/.gitconfig':
    ensure => 'link',
    owner => 'vagrant',
    group => 'vagrant',
    force => 'true',
    target => '/home/vagrant/workspace/dotfiles/gitconfig',
    require => Exec['clone-dotfiles']
  }
  file { '/home/vagrant/.bashrc':
    ensure => 'link',
    owner => 'vagrant',
    group => 'vagrant',
    force => 'true',
    target => '/home/vagrant/workspace/dotfiles/bashrc.sh',
    require => Exec['clone-dotfiles']
  }
  exec { 'get-oh-my-zsh':
    command => 'git clone https://github.com/robbyrussell/oh-my-zsh.git /home/vagrant/.oh-my-zsh',
    user => 'vagrant',
    group => 'vagrant',
    creates => '/home/vagrant/.oh-my-zsh'
  }
  exec { 'get-scm-breeze':
    command => 'git clone https://github.com/ndbroadbent/scm_breeze.git /home/vagrant/.scm_breeze',
    user => 'vagrant',
    group => 'vagrant',
    creates => '/home/vagrant/.scm_breeze'
  }
  file { '/home/vagrant/.zshrc':
    ensure => 'link',
    owner => 'vagrant',
    group => 'vagrant',
    force => 'true',
    target => '/home/vagrant/workspace/dotfiles/zshrc.sh',
    require => [ Exec['get-oh-my-zsh'], Exec['clone-dotfiles'] ]
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
  exec { 'use-the-emacs-ppa':
    command => 'add-apt-repository ppa:ubuntu-elisp/ppa -y',
    require => Package['python-software-properties'],
    unless => 'test -e /usr/bin/emacs-snapshot'
  }
  exec { 'update-for-emacs':
    command => 'apt-get update',
    require => Exec['use-the-emacs-ppa'],
    unless => 'test -e /usr/bin/emacs-snapshot'
  }
  package { 'emacs-snapshot':
    ensure => 'installed',
    require => Exec['update-for-emacs']
  }
  file { '/home/vagrant/.emacs.d':
    ensure => 'link',
    force => 'true',
    target => '/home/vagrant/workspace/dotfiles/emacs.d',
    require => [ Package['emacs-snapshot'], Exec['clone-dotfiles'] ]
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
  exec { 'clone-emacs-nav':
    command => 'git clone git@github.com:lazywithclass/emacs-nav.git /home/vagrant/workspace/emacs-nav',
    user => 'vagrant',
    creates => '/home/vagrant/workspace/emacs-nav',
    require => File['/home/vagrant/workspace']
  }
  exec { 'clone-jgarth':
    command => 'git clone git@github.com:lazywithclass/jgarth.git /home/vagrant/workspace/jgarth',
    user => 'vagrant',
    creates => '/home/vagrant/workspace/jgarth',
    require => File['/home/vagrant/workspace']
  }
  exec { 'clone-dynamodb-transactions':
    command => 'git clone https://github.com/awslabs/dynamodb-transactions.git /home/vagrant/workspace/dynamodb-transactions',
    user => 'vagrant',
    creates => '/home/vagrant/workspace/dynamodb-transactions',
    require => File['/home/vagrant/workspace']
  }
}

class chrome {
  exec { 'get-the-key':
    command => 'wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -',
    require => Package['python-software-properties'],
    unless => 'test -e /usr/bin/google-chrome'
  }
  exec { 'add-key-to-repository':
    command => 'sh -c \'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list\'',
    require => Exec['get-the-key'],
    unless => 'test -e /usr/bin/google-chrome'
  }
  exec { 'update-for-chrome':
    command => 'apt-get update',
    require => Exec['add-key-to-repository'],
    unless => 'test -e /usr/bin/google-chrome'
  }
  package { 'google-chrome-stable':
    ensure => 'installed',
    require => Exec['update-for-chrome']
  }
}

class skype {
  exec { 'use-the-skype-ppa':
    command => 'add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner"',
    require => Package['python-software-properties'],
    unless => 'test -e /usr/bin/skype'
  }
  exec { 'update-for-skype':
    command => 'apt-get update',
    require => Exec['use-the-skype-ppa'],
    unless => 'test -e /usr/bin/skype'
  }
  package { 'skype':
    ensure => 'present',
    require => Exec['update-for-skype']
  }
}

class monaco {
  file { '/usr/share/fonts/truetype/custom':
    ensure => 'directory'
  }
  exec { 'install-font':
    command => 'wget http://jorrel.googlepages.com/Monaco_Linux.ttf -P /usr/share/fonts/truetype/custom && fc-cache -f -v',
    creates => '/usr/share/fonts/truetype/custom/Monaco_Linux.ttf',
    require => File['/usr/share/fonts/truetype/custom']
  }
}

class frida {
  exec { 'install-easy_install':
    command => 'wget https://bootstrap.pypa.io/ez_setup.py -O - | sudo python',
    unless => 'test -e /usr/local/bin/easy_install'
  }
  exec { 'install-frida':
    command => 'easy_install frida',
    creates => '/usr/local/lib/python2.7/dist-packages/frida-1.6.7-py2.7-linux-x86_64.egg'
  }
}

class java {
  exec { 'use-the-webupd8team-ppa':
    command => 'add-apt-repository ppa:webupd8team/java -y',
    require => Package['python-software-properties'],
    unless => 'test -e /usr/bin/java'
  }
  exec { 'update-for-java':
    command => 'apt-get update',
    require => Exec['use-the-webupd8team-ppa'],
    unless => 'test -e /usr/bin/java'
  }
}

include system
include nodejs
include emacs
include workspace
include chrome
include skype
include monaco
include frida
include java
