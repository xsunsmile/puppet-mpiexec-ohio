
class mpiexec::pkg_install {

	$version = $mpiexec::params::mpiexec_version
	$arch = $architecture ? {
		/x86_64|amd64/ => 'amd64',
		default => 'i386',
	}

	file { "/tmp/mpiexec-${version}_${arch}.deb":
		ensure => present,
		source => "puppet:///mpiexec/mpiexec-${version}_${arch}.deb",
	}

	file { "/tmp/mpiexec_doc-${version}_${arch}.deb":
		ensure => present,
		source => "puppet:///mpiexec/mpiexec_doc-${version}_${arch}.deb",
	}

	exec { 'install-mpiexec-package':
		path => "/usr/bin",
		user => "root",
		command => "sudo dpkg -i /tmp/mpiexec*-${version}_${arch}.deb",
		require => [
			File["/tmp/mpiexec-${version}_${arch}.deb"],
			File["/tmp/mpiexec_doc-${version}_${arch}.deb"],
		],
		onlyif => "test ! -e ${mpiexec::params::install_dist}/bin/mpiexec",
	}

}
