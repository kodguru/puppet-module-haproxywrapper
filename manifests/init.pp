# Class: haproxywrapper
# ===========================
#
# Full description of class haproxywrapper here.
#
# Parameters
# ----------
#
# * `sample parameter`
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
class haproxywrapper (
  $custom_fragment       = undef,
  $default_options       = undef,
  $global_options        = undef,
  $merge_options         = undef,
  $package_ensure        = undef,
  $package_name          = undef,
  $restart_command       = undef,
  $service_ensure        = undef,
  $service_manage        = undef,
  $service_options       = undef,
  $config_dir            = undef,
  $config_file           = undef,
  $listen                = undef,
  $frontend              = undef,
  $backend               = undef,
  $balancermember        = undef,
  $balancermember_active = undef,
  $userlist              = undef,
  $peers                 = undef,
  $peer                  = undef,
  $mailers               = undef,
  $mailer                = undef,
  $instance              = undef,
  $instance_service      = undef,
  $mapfile               = undef
) { include ::haproxy::params

  if $custom_fragment != undef {
    validate_string($custom_fragment)
  }
  if $default_options != undef {
    validate_hash($default_options)
  }
  if $global_options != undef {
    validate_hash($global_options)
  }
  if $merge_options != undef {
    validate_bool($merge_options)
  }
  if $package_ensure != undef {
    validate_re($package_ensure, '^(present|installed|absent)$', 'haproxywrapper::package_ensure must be absent, present or installed')
  }
  if $package_name != undef {
    validate_string($package_name)
  }
  if $restart_command != undef {
    validate_string($restart_command)
  }
  if $service_ensure != undef {
    validate_re($service_ensure, '^(running|stopped)$', 'haproxywrapper::service_ensure must be running or stopped')
  }
  if $service_options != undef {
    validate_string($service_options)
  }
  if $config_dir != undef {
    if is_absolute_path($config_dir) == false {
      fail("${config_dir} is not an absolute path.")
    }
  }
  if $config_file != undef {
    validate_string($config_file)
  }
  class { '::haproxy':
    custom_fragment  => $custom_fragment,
    defaults_options => pick($default_options, $::haproxy::params::defaults_options),
    global_options   => pick($global_options, $::haproxy::params::global_options),
    merge_options    => pick($merge_options, $::haproxy::params::merge_options),
    package_ensure   => pick($package_ensure, 'present'),
    package_name     => pick($package_name, $::haproxy::params::package_name),
    restart_command  => $restart_command,
    service_ensure   => pick($service_ensure, 'running'),
    service_manage   => pick($service_manage, true),
    config_dir       => pick($config_dir, $::haproxy::params::config_dir),
    config_file      => pick($config_file, $::haproxy::params::config_file),
  }

  if $listen != undef {
    create_resources('haproxy::listen', $listen)
  }
  if $frontend != undef {
    create_resources('haproxy::frontend', $frontend)
  }
  if $backend != undef {
    create_resources('haproxy::backend', $backend)
  }

  if $balancermember_active != undef {
    validate_array($balancermember_active)
  }

  if $balancermember != undef {
    validate_hash($balancermember)
    if $balancermember_active == undef {
      $balancermember_real = $balancermember
    }
    else {
      $balancermember_inactive = any2array(delete($balancermember, $balancermember_active))
      $balancermember_real = delete($balancermember, $balancermember_inactive)
    }
    create_resources('haproxy::balancermember', $balancermember_real)
  }

  if $userlist != undef {
    create_resources('haproxy::userlist', $userlist)
  }
  if $peers != undef {
    create_resources('haproxy::peers', $peers)
  }
  if $peer != undef {
    create_resources('haproxy::peer', $peer)
  }
  if $mailers != undef {
    create_resources('haproxy::mailers', $mailers)
  }
  if $mailer != undef {
    create_resources('haproxy::mailer', $mailer)
  }
  if $instance != undef {
    create_resources('haproxy::instance', $instance)
  }
  if $instance_service != undef {
    create_resources('haproxy::instance_service', $instance_service)
  }
  if $mapfile != undef {
    create_resources('haproxy::mapfile', $mapfile)
  }
}
