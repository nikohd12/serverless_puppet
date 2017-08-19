class bon_voyage {

	$anchor = [ 'vim', 'curl', 'git' ]
	package { $anchor: ensure => 'installed' } 	# Package Installation
	
	user { 'monitor':
		ensure	=>	'present',
		home	=>	'/home/monitor/',
		shell	=>	'bin/bash',
		} 	# User Creation
	
	file { '/home/monitor/scripts/':
		ensure	=>	'directory',
		} 	# Fetching Memory_Check
		
	exec { 'memory_check':
		command	=>	"/usr/bin/wget -q https://raw.githubusercontent.com/nikojaro/memory_check/master/memory_check.sh -O /home/monitor/scripts/memory_check.sh"
		creates	=>	"/home/monitor/scripts/memory_check.sh",
		}
	
	file { '/home/monitor/scripts/memory_check.sh':
		mode =>	0755,
		require => Exec["memory_check"],
		}
	

	file { '/home/monitor/src/':
		ensure	=>	'directory',
		} # Creating Symbolink Link
		
	file { '/home/monitor/src/my_memory_check.sh':
		ensure	=>	'link',
		target	=>	'/home/monitor/scripts/memory_check.sh',
		}
	
	file { '/home/monitor/crontab.txt':
		ensure	=>	'file',
		content	=> "*/10 * * * * /home/monitor/src/my_memory_check.sh",
		} # Crontab Creation
	
	class sethostname {
		file { '/etc/hostname':
			ensure  => 'present',
			owner   => 'root',
			group   => 'root',
			mode    => '0644',
			content => "bpx.server.local",
			notify  => Exec['set-hostname'],
		}
		exec { 'set-hostname':
			command => '/bin/hostname -F /etc/hostname',
			unless  => "/usr/bin/test `hostname` = `/bin/cat /etc/hostname`",
			notify  => Service[:params::service_name],
		}
	} # Bonus: Set Hostname
	
	class { 'timezone':
		timezone => 'PHT',
		} # Bonus: Timezone 'puppet module install saz-timezone --version 3.5.0'
}
