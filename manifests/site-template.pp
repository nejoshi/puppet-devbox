stage { preconfig:
	before => Stage['main']
}

node devbox {
	$email = ''
	$fullName = ''
	$ubuntuUsername = ''

	$canonicalArchiveRepoUrl = 'http://archive.canonical.com/ubuntu'
	$googleChromeRepoUrl = 'http://dl.google.com/linux/chrome/deb'
	$ppaSublimeText2RepoUrl = 'http://ppa.launchpad.net/webupd8team/sublime-text-2/ubuntu'
	$ubuntuArchiveRepoUrl = 'http://archive.ubuntu.com/ubuntu'
	$virtualboxRepoUrl = 'http://download.virtualbox.org/virtualbox/debian'

	# Don't uncomment ubuntu-default-setup below even when testing, as many modules rely on it.  If you don't want to run apt-get update constantly, then set runUpdate to false.
	class { ubuntu-default-setup:
		user => $ubuntuUsername,
		runUpdate => true,

		canonicalArchiveRepoUrl => $canonicalArchiveRepoUrl,
		googleChromeRepoUrl => $googleChromeRepoUrl,
		ppaSublimeText2RepoUrl => $ppaSublimeText2RepoUrl,
		ubuntuArchiveRepoUrl => $ubuntuArchiveRepoUrl,
		virtualboxRepoUrl => $virtualboxRepoUrl,

		stage => preconfig,
	}

	# main
	include filezilla
	class { 'git-settings':
		fullName => $fullName,
		email => $email,
		user => $ubuntuUsername,
	}
	include google-chrome
	include libreoffice
	include meld
	include remmina
	class { 'ssh-client':
		user => $ubuntuUsername,
	}
	class { 'sublime-text-2':
		user => $ubuntuUsername,
	}
	class { ubuntu-desktop-setup:
		user => $ubuntuUsername,
	}
	include virtualbox
	include vlc
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
