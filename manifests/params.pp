
class mpiexec::params {

	$mpiexec_version = extlookup('mpiexec_version')
	$install_dist = extlookup('mpiexec_install_dist')
	$install_src = extlookup('mpiexec_install_src')

	$compile_args_extra = extlookup('mpiexec_complie_args_extra')
	$compile_args = "--with-default-comm=mpich-p4"

}
