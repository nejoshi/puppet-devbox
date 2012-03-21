class sublime-text-2 ($user) {
	define dirandfile ($directory, $sourceUrl, $owner) {
		file { $directory:
			ensure => directory,
			owner => $owner,
		}

		file { "$directory/$name":
			ensure => file,
			owner => $owner,
			source => $sourceUrl,
			
			require => File[$directory],
		}
	}

	untar { '/opt/Sublime Text 2':
		tarSource => $architecture ? {
			'i386' => 'puppet:///modules/sublime-text-2/Sublime Text 2 Build 2181.tar.bz2',
			'x86_64' => 'puppet:///modules/sublime-text-2/Sublime Text 2 Build 2181 x64.tar.bz2',
		},
		tarOptions => 'xvjf',
		tarFileName => 'sublime-text-2.tar.bz2',
		destDirectory => '/opt',
		owner => root,
	}

	exec { '"/opt/Sublime Text 2/sublime_text" --command exit':
		creates => "/home/$user/.config/sublime-text-2",
		environment => [ "HOME=/home/$user", "USER=$user" ],
		user => $user,

		require => Untar['/opt/Sublime Text 2'],
	}

	# setup Puppet code coloring
	dirandfile { 'Puppet.tmLanguage':
		directory => "/home/$user/.config/sublime-text-2/Packages/Puppet",
		sourceUrl => 'puppet:///modules/sublime-text-2/Puppet.tmLanguage',
		owner => $user,

		require => Exec['"/opt/Sublime Text 2/sublime_text" --command exit']
	}

	# setup CoffeeScript code coloring
	dirandfile { 'CoffeeScript.tmLanguage':
		directory => "/home/$user/.config/sublime-text-2/Packages/CoffeeScript",
		sourceUrl => 'puppet:///modules/sublime-text-2/CoffeeScript.tmLanguage',
		owner => $user,

		require => Exec['"/opt/Sublime Text 2/sublime_text" --command exit']
	}

	# setup keyboard shortcuts
	file { "/home/$user/.config/sublime-text-2/Packages/User/Default (Linux).sublime-keymap":
		ensure => file,
		owner => $user,
		source => 'puppet:///modules/sublime-text-2/Default (Linux).sublime-keymap',

		require => Exec['"/opt/Sublime Text 2/sublime_text" --command exit']
	}

	# setup font
	file { "/home/$user/.config/sublime-text-2/Packages/User/Base File.sublime-settings":
		ensure => file,
		owner => $user,
		source => 'puppet:///modules/sublime-text-2/Base File.sublime-settings',

		require => Exec['"/opt/Sublime Text 2/sublime_text" --command exit']
	}

	# create /usr/local/bin/sublime
	file { '/usr/local/bin/sublime':
		ensure => link,
		mode => 755,
		target => '/opt/Sublime Text 2/sublime_text',
		owner => root,
	}
}
