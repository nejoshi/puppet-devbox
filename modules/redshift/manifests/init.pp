class redshift ($lat, $lon, $user) {
	package { gtk-redshift:
		ensure => present,
	}

	file { "/home/$user/.config/redshift.conf":
		content => template('redshift/redshift.conf.erb'),
		mode => 644,
		owner => $user,
	}

	# TODO: check at home why this resource type doesn't work - i.e. missing /home/$user/.config/autostart/ folder or missing file /usr/share/applications/gtk-redshift.desktop
	file { "/home/$user/.config/autostart/gtk-redshift.desktop":
		ensure => link,
		mode => 644,
		owner => $user,
		target => '/usr/share/applications/gtk-redshift.desktop',

		require => [
			Package['gtk-redshift'],
			File["/home/$user/.config/redshift.conf"],
		],
	}
}