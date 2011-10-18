class mpiexec::compile {

	$mongodb_host = extlookup('mongodb_host')

	file { "${mpiexec::params::install_src}":
		ensure => directory,
		owner => root,
		group => root,
		mode => 0777,
	}

	file { "${mpiexec::params::install_src}/fetch.sh":
		ensure => present,
		owner => root,
		group => root,
		mode => 0755,
		source => "puppet:///mpiexec/fetch.sh",
		require => File["${mpiexec::params::install_src}"],
	}

	exec { "download-mpiexec":
		cwd => "${mpiexec::params::install_src}",
		command => "/bin/sh fetch.sh ${mpiexec::params::mpiexec_version}",
		timeout => 600,
		require => File["${mpiexec::params::install_src}/fetch.sh"],
	}

	file { "${mpiexec::params::install_src}/mpiexec":
		ensure => directory,
		mode => 0777,
		require => Exec['download-mpiexec'],
	}

	exec { "configure-mpiexec":
		path => "/bin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin",
		cwd => "${mpiexec::params::install_src}/mpiexec",
		command => "nice -19 sh configure ${mpiexec::params::compile_args} 2>&1 | tee -a compile.log",
		require => [ File["${mpiexec::params::install_src}/mpiexec"], Package['build-essential'] ],
		onlyif => "test ! -e ${mpiexec::params::install_src}/mpiexec/config.log",
	}

	exec { "build-mpiexec":
		path => "/bin:/usr/bin:/usr/sbin",
		cwd => "${mpiexec::params::install_src}/mpiexec",
		command => "nice -19 make",
		require => Exec['configure-mpiexec'],
	}

	fpm::mpiexec{ 'mpiexec':
		source_type => 'dir',
		package_type => 'deb',
		package_src => "${mpiexec::params::install_src}/mpiexec",
		package_version => "${mpiexec::params::mpiexec_version}",
		build_dirname => '/tmp/build_mpiexec',
		broker_dir => '/etc/puppet/modules/mpiexec/files',
		repo => "mongodb://${mongodb_host}:27017/inters_debs/${architecture}/_/tmp/mpiexec*.deb",
	}

}
