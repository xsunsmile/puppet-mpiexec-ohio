
class mpiexec {

	if $hostname == $torque::params::torque_master {
		require torque
		include mpiexec::params
		include mpiexec::compile
		include mpiexec::install
	} else {
		include mpiexec::pkg_install
	}

}
