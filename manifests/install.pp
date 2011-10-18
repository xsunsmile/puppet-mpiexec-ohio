
class mpiexec::install {

	include mpiexec::params
	include mpiexec::compile

	exec { "install-mpiexec":
		path => "/bin:/usr/bin:/usr/sbin",
		cwd => "${mpiexec::params::install_src}/mpiexec",
		command => "nice -19 make install",
		require => Exec['build-mpiexec'],
		timeout => 600,
	}

}
