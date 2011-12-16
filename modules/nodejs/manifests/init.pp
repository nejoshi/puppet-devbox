class nodejs {
	package { 'libssl-dev':
		ensure => present,
	}

	file { '/opt/packages/node-v0.6.6.tar.gz':
		ensure => file,
		owner => root,
		group => root,
		source => 'puppet:///modules/nodejs/node-v0.6.6.tar.gz',
	}

	exec { 'untar nodejs':
		command => '/bin/tar -xvzf node-v0.6.6.tar.gz',
		creates => '/opt/packages/node-v0.6.6',
		cwd => '/opt/packages',
		group => root,
		user => root,

		require => [
			File['/opt/packages/node-v0.6.6.tar.gz'],
			Package['libssl-dev'],
		]
	}

	exec { 'configure nodejs':
		command => '/opt/packages/node-v0.6.6/configure',
		creates => '/opt/packages/node-v0.6.6/build/default',
		cwd => '/opt/packages/node-v0.6.6',
		group => root,
		path => '/usr/bin',
		user => root,

		require => [
			Exec['untar nodejs'],
			Package['libssl-dev'],
		]
	}

	exec { 'install nodejs':
		command => 'make install',
		creates => '/usr/local/bin/node',
		cwd => '/opt/packages/node-v0.6.6',
		group => root,
		path => [
			'/bin',
			'/usr/bin',
		],
		timeout => 0,
		user => root,

		require => Exec['configure nodejs'],
	}

	exec {'install npm':
		command => 'curl http://npmjs.org/install.sh | clean=yes sh',
		creates => '/usr/local/bin/npm',
		group => root,
		path => [
			'/usr/bin',
			'/usr/local/bin',
			'/bin'
		],
		user => root,

		require => [
			Exec['install nodejs'],
			Package['curl'],
		]
	}

	define installNpmPackage ($creates) {
		# $name refers to package name
		exec {"npm install -g $name":
			creates => $creates,
			group => root,
			path => [
				'/bin',
				'/usr/bin',
				'/usr/local/bin'
			],
			user => root,

			require => [
				Exec['install npm'],
			]
		}
	}

	installNpmPackage {'coffee-script':
		creates => '/usr/local/bin/coffee',
	}

	installNpmPackage {'expresso':
		creates => '/usr/local/bin/expresso',
	}

	installNpmPackage {'less':
		creates => '/usr/local/bin/lessc',
	}

	installNpmPackage {'uglify-js':
		creates => '/usr/local/bin/uglifyjs',
	}
}