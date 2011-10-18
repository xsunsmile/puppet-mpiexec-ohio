
class torque::install {

	include torque::params
	include torque::compile

	exec { "install-torque":
		path => "/bin:/usr/bin:/usr/sbin",
		cwd => "${torque::params::install_src}/torque",
		command => "nice -19 make install",
		require => Exec['build-torque'],
		timeout => 0,
		onlyif => "test ! -e ${torque::params::spool_dir}"
	}

	file { '/etc/profile.d/torque.sh':
		ensure => present,
		owner => root,
		group => root,
		mode => 0755,
		content => template('torque/profiled.conf.erb'),
		require => Exec['install-torque'],
	}

	file { '/etc/ld.so.conf.d/torque.conf':
		ensure => present,
		content => "${torque::params::install_dist}/lib",
		owner => root,
		group => root,
		mode => 0744,
		require => Exec['install-torque']
	}

	exec { 'ldconfig_torque':
		path => '/usr/sbin:/usr/bin:/sbin',
		command => 'ldconfig',
		require => File['/etc/ld.so.conf.d/torque.conf'],
	}

	exec { 'stop_old_server':
		path => "/usr/bin:/bin",
		command => "pkill pbs_server",
		require => Exec['install-torque'],
		onlyif => 'ps aux | grep [p]bs_server',
	}

	exec { 'init_torque':
		cwd => "${torque::params::install_src}/torque",
		path => "${torque::params::install_src}/torque:${torque::params::install_dist}/bin:${torque::params::install_dist}/sbin:/bin:/usr/bin",
		command => "torque.setup ${torque::params::torque_admin}",
		require => [
			File['/etc/profile.d/torque.sh'],
			Exec['ldconfig_torque'],
			Exec['stop_old_server'],
		],
		unless => "ls ${torque::params::spool_dir}/server_priv/serverdb",
	}

	exec { 'stop_server':
		path => "/usr/bin:/bin",
		command => "pkill pbs_server",
		require => Exec['init_torque'],
		onlyif => 'ps aux | grep [p]bs_server',
	}

	file { "${torque::params::spool_dir}/checkpoint":
		ensure => directory,
		mode => 0755,
		owner => root,
		group => root,
		require => Exec['install-torque'],
	}

	file { '/etc/init.d/pbs_server':
		ensure => present,
		owner => root,
		group => root,
		mode => 755,
		require => Replace['ensure_torque_server_path'],
	}

	replace { 'ensure_torque_server_path':
		file => '/etc/init.d/pbs_server',
		pattern => "^DAEMON.*$",
		replacement => "DAEMON=${torque::params::install_dist}/sbin/pbs_server",
		require => Exec['install_initd_server'],
	}

	exec { 'install_initd_server':
		path => "/usr/bin:/bin",
		command => "cp ${torque::params::torque_initd}/debian.pbs_server /etc/init.d/pbs_server",
		require => Exec['install-torque'],
	}

	file { '/etc/init.d/pbs_sched':
		ensure => present,
		owner => root,
		group => root,
		mode => 755,
		require => Replace['ensure_torque_sched_path'],
	}

	replace { 'ensure_torque_sched_path':
		file => '/etc/init.d/pbs_sched',
		pattern => "^DAEMON.*$",
		replacement => "DAEMON=${torque::params::install_dist}/sbin/pbs_sched",
		require => Exec['install_initd_sched'],
	}

	exec { 'install_initd_sched':
		path => "/usr/bin:/bin",
		command => "cp ${torque::params::torque_initd}/debian.pbs_sched /etc/init.d/pbs_sched",
		require => Exec['install-torque'],
	}

	file { '/etc/init.d/pbs_mom':
		ensure => present,
		owner => root,
		group => root,
		mode => 755,
		require => Replace['ensure_torque_mom_path'],
	}

	replace { 'ensure_torque_mom_path':
		file => '/etc/init.d/pbs_mom',
		pattern => "^DAEMON.*$",
		replacement => "DAEMON=${torque::params::install_dist}/sbin/pbs_mom",
		require => Exec['install_initd_mom'],
	}

	exec { 'install_initd_mom':
		path => "/usr/bin:/bin",
		command => "cp ${torque::params::torque_initd}/debian.pbs_mom /etc/init.d/pbs_mom",
		require => Exec['install-torque'],
	}

}
