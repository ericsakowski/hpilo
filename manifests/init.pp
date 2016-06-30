# hpilo - Used for managing HPILO
# (http://www8.hp.com/uk/en/products/servers/ilo/)
#
# @example
#   include hpilo
#
# @example
#   class { 'hpilo':
#      dhcp        => true,
#      ilouser     => 'admin',
#      ilouserpass => 'password'
#    }
#
# @author Eric Sakowski
#
# @param shared [Boolean] Whether or not to enable the shared network port
#
# @param dhcp [String] You will need to define these parameters for the static templates to work correctly
#
# @param dns [String] this is your dns server
#
# @param netmask [String] this is your netmask
#
# @param ilouser [String] this is the default admin username you wish to create
#
# @param ilouserpass [String] this is the default password for the default admin user
#
# @param gw [String]
#
# @param ip [String]
#
# @param custom_template [String] Allows you to set a custom file template
#
# @param autoip [Boolean] This will examine the IP of the system and substitute the value of param
#   ilonet for the third octet, fx on a system where facter ipaddress is 192.168.1.10 and
#   a param ilonet = '27', ip of the ilo will be 192.168.27.10
#   if autoip is set to true, gw and ip will be disregarded
#
# @param ilonet [String] If you want to put your ilo card on a separate network
#   example: 192.168.xxx.22; disregarded if autoip is false
#
# @param gwbit [String]
#   this is the gateway bit if using a 24 bit netmask: example: 192.168.25.xxx, disregarded if autoip is false
#
# @param logfile [String] Location to log results from hponcfg command
#
# @param settingsfile [String] Location to store HPILO config file
#
class hpilo (
  $autoip = false,
  $custom_template = undef,
  $dhcp = false,
  $dns = '192.168.1.1',
  $gw = '192.168.1.254',
  $gwbit = '240',
  $ilonet = '27',
  $ilouser = 'admin',
  $ilouserpass = 'password',
  $ip = '192.168.1.2',
  $logfile = '/tmp/ilosettings.log',
  $manage_package = true,
  $netmask = '255.255.255.0',
  $settingsfile = '/etc/ilosettings.xml',
  $shared = true,
)
{

  if ($autoip) {
    notify { 'autoip is true.  gateway and ip values will be automatically set.': }
  }

  # Don't run these if not an HP machine
  if ( $::manufacturer ) and ( $::manufacturer == 'HP') {
    # Not all ilos have the same feature set and thus ilo configs are not backwards compatible
    case $::productname {
      /G3/: { $ilogen = 0 }
      /G4/: { $ilogen = 1 }
      /G5/: { $ilogen = 2 }
      /G6/: { $ilogen = 2 }
      /G7/: { $ilogen = 3 }
      /Gen8/: { $ilogen = 4 }
      /Gen9/: { $ilogen = 4 }
      default: { $ilogen = 1 }
    }

    if $manage_package {
      package { 'hponcfg':
        ensure => 'present',
        before => Exec["hponcfg -f ${settingsfile} -l ${logfile}"],
      }
    }

    exec{"hponcfg -f ${settingsfile} -l ${logfile}":
      onlyif      => 'which hponcfg',
      path        =>'/bin:/usr/sbin:/usr/bin:/sbin/',
      refreshonly => true,
      subscribe   => File[$settingsfile],
      timeout     => 0,
    }

    file { $settingsfile:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }

    # since the template accomodates dhcp and static there is no need to change the template file
    if $custom_template {
      File[$settingsfile] { content => $custom_template }
    } else {
      File[$settingsfile] { content => template('hpilo/iloconfig.erb') }
    }
  }
}
