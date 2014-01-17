define duplicity::backup (
  $source_dir,
  $target_url,
  $includes = [],
  $excludes = [],
  $ensure   = $duplicity::manage_file,
  $minute   = $duplicity::minute,
  $hour     = $duplicity::hour,
  $month    = $duplicity::month,
  $monthday = $duplicity::monthday,
  $weekday  = $duplicity::weekday,
  $special  = $duplicity::special,
  $user     = $duplicity::user,
  $password = $duplicity::password,
  $ssh_key_file  = $duplicity::ssh_key_file,
  $full_if_older_than           = $duplicity::full_if_older_than,
  $remove_older_than            = $duplicity::remove_older_than,
  $remove_all_but_n_full        = $duplicity::remove_all_but_n_full,
  $remove_all_inc_of_but_n_full = $duplicity::remove_all_inc_of_but_n_full,) {
  # check input parameters
  validate_string($source_dir)
  validate_string($target_url)
  validate_array($includes)
  validate_array($excludes)

  # construct standard variables
  $backup_name = $name
  $backup_script = "${duplicity::config_dir}/${name}.sh"
  $log_file = "${duplicity::log_dir}/${name}.log"
  $resource_name = "duplicity.backup.${name}"

  file { $resource_name:
    ensure  => $ensure,
    path    => $backup_script,
    mode    => '0775',
    owner   => $user,
    group   => $duplicity::config_file_group,
    require => Package[$duplicity::package],
    content => template('duplicity/backup.sh.erb'),
    replace => $duplicity::manage_file_replace,
    audit   => $duplicity::manage_audit,
    noop    => $duplicity::bool_noops,
  } ->
  cron { $resource_name:
    ensure   => $ensure,
    command  => $backup_script,
    user     => $user,
    minute   => $minute,
    hour     => $hour,
    month    => $month,
    monthday => $monthday,
    weekday  => $weekday,
    special  => $special,
    audit    => $duplicity::manage_audit,
    noop     => $duplicity::bool_noops,
  }

  # todo: spaceship is probably needed to do puppi correctly
  if $duplicity::bool_puppi {
    puppi::log { $resource_name:
      log         => $log_file,
      description => "Duplicity backup : ${name}",
      audit       => $duplicity::manage_audit,
      noop        => $duplicity::bool_noops,
    }
  }
  # todo: add puppi::info
}
