class ubuntu-default-setup ($user, $runUpdate) {
	define addAptKey($email) {
		# $name refers to URL
		exec { "/usr/bin/wget -q -O - $name | /usr/bin/apt-key add -":
			unless => "/usr/bin/apt-key list | /bin/grep $email",
			user => root,

			before => Exec['apt-get update'],
		}
	}

	appendLineToFile { 'add pup alias':
		file => "/home/$user/.bashrc",
		line => 'alias pup=\"sudo puppet /etc/puppet/manifests/site.pp\"',
		user => $user,
	}

	file { '/etc/sudoers':
		source => 'puppet:///modules/ubuntu-default-setup/sudoers',
		mode => 440,
		owner => root,
		group => root,
	}

	# ensure we're using the main server because others can be missing files
	file { '/etc/apt/sources.list':
		source => 'puppet:///modules/ubuntu-default-setup/sources.list',
		mode => 644,
		owner => root,
		group => root,
	}

	# add apt keys in case user wants to install software (this is done in ubuntu-default-setup to avoid running apt-get update multiple times)
	addAptKey { 'https://dl-ssl.google.com/linux/linux_signing_key.pub':
		email => 'linux-packages-keymaster@google.com',
	}
	addAptKey { 'http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc':
		email => 'info@virtualbox.org',
	}

	exec { 'apt-get update':
		command => $runUpdate ? {
			true => 'apt-get update',
			false => 'echo apt-get update not run due to runUpdate set to false',
		},
		path => [
			'/bin',
			'/usr/bin',
		],
		user => root,

		require => File['/etc/apt/sources.list'],
	}

	# install packages that aren't included in the base installation
	# note: wget is included in the base installation
	package {[
		'git',
		'curl',
	]:
		ensure => present,

		require => Exec['apt-get update'],
	}

	# remove unneeded packages
	package {[
		'aisleriot',
		'evolution-common',
		'gbrainy',
		'gnome-mahjongg',
		'gnome-sudoku',
		'gnomine',
		'indicator-me',
		'indicator-messages',
		'libevolution'
	]:
		ensure => absent,
	}
	
	# create global package directory
	file { '/opt':
		ensure => 'directory',
	}

	file { '/opt/packages':
		ensure => 'directory',

		require => File['/opt'],
	}

	# create user packages directory
	file { "/home/$user/packages":
		ensure => directory,
	}
}

define appendLineToFile($file, $line, $user) {
	# $name can refer to anything
	exec { "echo \"\\n$line\" >> \"$file\"":
		path => '/bin',
		unless => "grep -Fx \"$line\" \"$file\"",
		user => $user,
	}
}

define gconf($type, $value, $user) {
	# $name refers to the key being modified
	exec { "gconftool-2 --config-source xml:readwrite:/home/$user/.gconf --set \"$name\" --type $type \"$value\"":
		path => '/usr/bin',
		unless => "test \"`gconftool-2 --config-source xml:readwrite:/home/$user/.gconf --get \"$name\"`\" = \"$value\"",
		user => $user,
	}
}

define installDebFile($package, $source) {
	# $name refers to the local filename to place in /opt/packages

	file { "/opt/packages/$name":
		source => $source,

		require => File['/opt/packages'],
	}

	package { $package:
		provider => dpkg,
		ensure   => present,
		source   => "/opt/packages/$name",

		require => [
			File["/opt/packages/$name"],
		],
	}
}

define untar($tarSource, $tarOptions, $tarFileName, $destDirectory, $owner) {
	# $name refers to the destination file or directory it creates
	file { "/opt/packages/$tarFileName":
		ensure => file,
		mode => 774,
		owner => root,
		source => $tarSource,

		require => File['/opt/packages'],
	}

	exec { "tar $tarOptions \"/opt/packages/$tarFileName\" -C \"$destDirectory\"":
		creates => $name,
		path => '/bin',
		user => root,

		require => File["/opt/packages/$tarFileName"],
	}

	file { $name:
		ensure => present,
		recurse => true,
		owner => $owner,

		require => Exec["tar $tarOptions \"/opt/packages/$tarFileName\" -C \"$destDirectory\""],
	}
}
