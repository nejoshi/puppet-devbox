class freemind {
	package {'freemind':
		ensure => present,

		require => Package['sun-java6-jre'],
	}
}