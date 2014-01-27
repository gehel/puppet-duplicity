# Class: duplicity::params
#
# This class defines default parameters used by the main module class duplicity
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to duplicity class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class duplicity::params {
  # ## Application related parameters

  $package = $::operatingsystem ? {
    default => 'duplicity',
  }

  $paramiko_package = $::operatingsystem ? {
    default => 'python-paramiko',
  }

  $config_dir = $::operatingsystem ? {
    default => '/usr/local/share/duplicity',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }

  $log_dir = $::operatingsystem ? {
    default => '/var/log/duplicity',
  }

  # General Settings
  $my_class = ''
  $source_dir = ''
  $source_dir_purge = false
  $template = ''
  $options = ''
  $version = 'present'
  $absent = false
  $puppi = false
  $puppi_helper = 'standard'
  $audit_only = false
  $noops = false
  $backups = {
  }

  # Default values for scheduling

  $minute = '0'
  $hour = '*'
  $month = undef
  $monthday = undef
  $weekday = undef
  $special = undef

  # duplicity params
  $user = 'root'
  $password = ''
  $ssh_key_file = undef
  $install_paramiko = true
  $paramiko_version = 'present'

  $full_if_older_than = '1M'
  $remove_older_than = undef
  $remove_all_but_n_full = undef
  $remove_all_inc_of_but_n_full = undef

}
