class ruby ($user, $rubyVersion) {
	package {'ruby':
		ensure => present,
	}

	exec { '/usr/bin/curl -s https://rvm.beginrescueend.com/install/rvm | /bin/bash':
		creates => "/home/$user/.rvm/bin/rvm",
		environment => [ "HOME=/home/$user", "USER=$user" ],
		user => $user,

		require => [
			Package['curl'],
			Package['git'],
			Package['ruby'],
		],
	}

	appendLineToFile { 'add rvm settings to .bashrc':
		file => "/home/$user/.bashrc",
		line => "[[ -s \\\"/home/$user/.rvm/scripts/rvm\\\" ]] && source \\\"/home/$user/.rvm/scripts/rvm\\\"",
		user => $user,

		require => Exec['/usr/bin/curl -s https://rvm.beginrescueend.com/install/rvm | /bin/bash'],
	}

	exec { "/home/$user/.rvm/bin/rvm install $rubyVersion":
		environment => [ "HOME=/home/$user", "USER=$user" ],
		timeout => 0,
		unless => "/home/$user/.rvm/bin/rvm use | /bin/grep $rubyVersion",
		user => $user,

		require => AppendLineToFile['add rvm settings to .bashrc'],
	}

	exec { "/home/$user/.rvm/bin/rvm use $rubyVersion --default":
		environment => [ "HOME=/home/$user", "USER=$user" ],
		unless => "/home/$user/.rvm/bin/rvm use | /bin/grep $rubyVersion",
		user => $user,

		require => Exec["/home/$user/.rvm/bin/rvm install $rubyVersion"],
	}

	define installGem {
		exec { "/home/$user/.rvm/bin/gem install $name":
			environment => [ "HOME=/home/$user", "USER=$user" ],
			unless => "/home/$user/.rvm/bin/gem list --local $name | /bin/grep $name",
			timeout => 600,
			user => $user,

			require => Exec["/home/$user/.rvm/bin/rvm use $rubyVersion --default"],
		}
	}

	installGem { 'bundler': }
	installGem { 'lolcat': }
	installGem { 'rails': }
}
