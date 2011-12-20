stage { preconfig:
	before => Stage['main']
}

node devbox {
	$email = 'chris.khoo@gmail.com'
	$fullName = 'Chris Khoo'
	$dualMonitorsLeftMonitorWidth = 1680
	$redshiftLat = -27.453911
	$redshiftLong = 153.026505
	$ubuntuUsername = 'ubuntu'

	# Don't uncomment ubuntu-default-setup below even when testing, as many modules rely on it.  If you don't want to run apt-get update constantly, then set runUpdate to false.
	class { ubuntu-default-setup:
		user => $ubuntuUsername,
		runUpdate => true,

		stage => preconfig,
	}

	# main
	class { 'ack-grep':
		user => $ubuntuUsername,
	}
	include alarm-clock-applet
	include ant
	include filezilla
	class { 'git-settings':
		fullName => $fullName,
		email => $email,
		user => $ubuntuUsername,
	}
	include freemind
	include google-chrome
	class { lamp:
		rootPassword => 'root',
		timezone => 'Australia/Brisbane',
		user => $ubuntuUsername,
	}
	include libreoffice
	include meld
	class { 'metacity-shortcuts':
		switchWindowXOffset => $dualMonitorsLeftMonitorWidth,
		user => $ubuntuUsername,
	}
	include nodejs
	include octave
	class { redshift:
		lat => $redshiftLat,
		lon => $redshiftLong,
		user => $ubuntuUsername,
	}
	include ruby
	include skype
	class { 'ssh-client':
		user => $ubuntuUsername,
	}
	class { 'sublime-text-2':
		user => $ubuntuUsername,
	}
	class { ubuntu-desktop-setup:
		user => $ubuntuUsername,
	}
	include syncftp
	include virtualbox
}

node serverbox {
	$ubuntuUsername = 'ubuntu-server'

	class { ubuntu-default-setup:
		user => $ubuntuUsername,
		runUpdate => true,

		stage => preconfig,
	}

	class { gitolite:
		user => $ubuntuUsername,
	}
}

node ubuntu-server inherits serverbox {}
node default inherits devbox {}
