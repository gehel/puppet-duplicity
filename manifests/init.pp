# = Class: duplicity
#
# This is the main duplicity class
#
#
# == Parameters
#
# Standard class parameters
# Define the general class behaviour and customizations
#
# [*my_class*]
#   Name of a custom class to autoload to manage module's customizations
#   If defined, duplicity class will automatically "include $my_class"
#   Can be defined also by the (top scope) variable $duplicity_myclass
#
# [*source*]
#   Sets the content of source parameter for main configuration file
#   If defined, duplicity main config file will have the param: source => $source
#   Can be defined also by the (top scope) variable $duplicity_source
#
# [*source_dir*]
#   If defined, the whole duplicity configuration directory content is retrieved
#   recursively from the specified source
#   (source => $source_dir , recurse => true)
#   Can be defined also by the (top scope) variable $duplicity_source_dir
#
# [*source_dir_purge*]
#   If set to true (default false) the existing configuration directory is
#   mirrored with the content retrieved from source_dir
#   (source => $source_dir , recurse => true , purge => true)
#   Can be defined also by the (top scope) variable $duplicity_source_dir_purge
#
# [*template*]
#   Sets the path to the template to use as content for main configuration file
#   If defined, duplicity main config file has: content => content("$template")
#   Note source and template parameters are mutually exclusive: don't use both
#   Can be defined also by the (top scope) variable $duplicity_template
#
# [*options*]
#   An hash of custom options to be used in templates for arbitrary settings.
#   Can be defined also by the (top scope) variable $duplicity_options
#
# [*version*]
#   The package version, used in the ensure parameter of package type.
#   Default: present. Can be 'latest' or a specific version number.
#   Note that if the argument absent (see below) is set to true, the
#   package is removed, whatever the value of version parameter.
#
# [*absent*]
#   Set to 'true' to remove package(s) installed by module
#   Can be defined also by the (top scope) variable $duplicity_absent
#
# [*puppi*]
#   Set to 'true' to enable creation of module data files that are used by puppi
#   Can be defined also by the (top scope) variables $standard42_puppi and $puppi
#
# [*puppi_helper*]
#   Specify the helper to use for puppi commands. The default for this module
#   is specified in params.pp and is generally a good choice.
#   You can customize the output of puppi commands for this module using another
#   puppi helper. Use the define puppi::helper to create a new custom helper
#   Can be defined also by the (top scope) variables $standard42_puppi_helper
#   and $puppi_helper
#
# [*audit_only*]
#   Set to 'true' if you don't intend to override existing configuration files
#   and want to audit the difference between existing files and the ones
#   managed by Puppet.
#   Can be defined also by the (top scope) variables $duplicity_audit_only
#   and $audit_only
#
# [*noops*]
#   Set noop metaparameter to true for all the resources managed by the module.
#   Basically you can run a dryrun for this specific module if you set
#   this to true. Default: false
#
# Default class params - As defined in duplicity::params.
# Note that these variables are mostly defined and used in the module itself,
# overriding the default values might not affected all the involved components.
# Set and override them only if you know what you're doing.
# Note also that you can't override/set them via top scope variables.
#
# [*package*]
#   The name of duplicity package
#
# [*config_dir*]
#   Main configuration directory. Used by puppi
#
# [*backups*]
#   Hash defining all backups to run
#
# == Examples
#
# You can use this class in 2 ways:
# - Set variables (at top scope level on in a ENC) and "include duplicity"
# - Call duplicity as a parametrized class
#
# See README for details.
#
class duplicity (
  $my_class     = params_lookup('my_class'),
  $source       = params_lookup('source'),
  $source_dir   = params_lookup('source_dir'),
  $source_dir_purge             = params_lookup('source_dir_purge'),
  $template     = params_lookup('template'),
  $options      = params_lookup('options'),
  $version      = params_lookup('version'),
  $absent       = params_lookup('absent'),
  $puppi        = params_lookup('puppi', 'global'),
  $puppi_helper = params_lookup('puppi_helper', 'global'),
  $audit_only   = params_lookup('audit_only', 'global'),
  $noops        = params_lookup('noops'),
  $package      = params_lookup('package'),
  $config_dir   = params_lookup('config_dir'),
  $backups      = params_lookup('backups'),
  $log_dir      = params_lookup('log_dir'),
  $minute       = params_lookup('minute'),
  $hour         = params_lookup('hour'),
  $month        = params_lookup('month'),
  $monthday     = params_lookup('monthday'),
  $weekday      = params_lookup('weekday'),
  $special      = params_lookup('special'),
  $ssh_key_file = params_lookup('ssh_key_file'),
  $full_if_older_than           = params_lookup('full_if_older_than'),
  $remove_older_than            = params_lookup('remove_older_than'),
  $remove_all_but_n_full        = params_lookup('remove_all_but_n_full'),
  $remove_all_inc_of_but_n_full = params_lookup('remove_all_inc_of_but_n_full'),) inherits duplicity::params {
  $config_file_mode = $duplicity::params::config_file_mode
  $config_file_owner = $duplicity::params::config_file_owner
  $config_file_group = $duplicity::params::config_file_group

  $bool_source_dir_purge = any2bool($source_dir_purge)
  $bool_absent = any2bool($absent)
  $bool_puppi = any2bool($puppi)
  $bool_audit_only = any2bool($audit_only)
  $bool_noops = any2bool($noops)

  # ## Definition of some variables used in the module
  $manage_package = $duplicity::bool_absent ? {
    true  => 'absent',
    false => $duplicity::version,
  }

  $manage_file = $duplicity::bool_absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_audit = $duplicity::bool_audit_only ? {
    true  => 'all',
    false => undef,
  }

  $manage_file_replace = $duplicity::bool_audit_only ? {
    true  => false,
    false => true,
  }

  $manage_file_source = $duplicity::source ? {
    ''      => undef,
    default => $duplicity::source,
  }

  $manage_file_content = $duplicity::template ? {
    ''      => undef,
    default => template($duplicity::template),
  }

  # ## Managed resources
  package { $duplicity::package:
    ensure => $duplicity::manage_package,
    noop   => $duplicity::bool_noops,
  }  

  # The whole duplicity configuration directory can be recursively overriden
  if $duplicity::source_dir {
    file { 'duplicity.dir':
      ensure  => directory,
      path    => $duplicity::config_dir,
      require => Package[$duplicity::package],
      source  => $duplicity::source_dir,
      recurse => true,
      purge   => $duplicity::bool_source_dir_purge,
      force   => $duplicity::bool_source_dir_purge,
      replace => $duplicity::manage_file_replace,
      audit   => $duplicity::manage_audit,
      noop    => $duplicity::bool_noops,
    }
  } else {
    file { 'duplicity.dir':
      ensure  => directory,
      path    => $duplicity::config_dir,
      require => Package[$duplicity::package],
      purge   => $duplicity::bool_source_dir_purge,
      force   => $duplicity::bool_source_dir_purge,
      replace => $duplicity::manage_file_replace,
      audit   => $duplicity::manage_audit,
      noop    => $duplicity::bool_noops,
    }
  }

  file { 'duplicity.log.dir':
    ensure  => directory,
    path    => $duplicity::log_dir,
    mode    => $config_file_mode,
    owner   => $config_file_owner,
    group   => $config_file_group,
    require => Package[$duplicity::package],
    audit   => $duplicity::manage_audit,
    noop    => $duplicity::bool_noops,
  }

  # ## Provide puppi data, if enabled ( puppi => true )
  if $duplicity::bool_puppi == true {
    $classvars = get_class_args()

    puppi::ze { 'duplicity':
      ensure    => $duplicity::manage_file,
      variables => $classvars,
      helper    => $duplicity::puppi_helper,
      noop      => $duplicity::bool_noops,
    }
  }

  # ## Include custom class if $my_class is set
  if $duplicity::my_class {
    include $duplicity::my_class
  }

  create_resources('duplicity::backup', $backups)

}
