class libreoffice {
	package { 'libreoffice':
		ensure => present,

		require => Package['sun-java6-jre'],
	}
}