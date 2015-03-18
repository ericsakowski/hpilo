# Class: hpilo
#
# This module manages hpilo
#
# Parameters:
#  dhcp
#  shared
#  dns
#  netmask 
#  ilouser
#  ilouserpass
#  gw
#  ip
#  autoip
#  ilonet
#  gwbit
#  logfile
#  settingsfile
#  
#  
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class hpilo(
  $shared = true,             # Whether or not to enable the shared network port
  $dhcp = false,              # You will need to define these parameters for the static templates to work correctly
  $dns = '192.168.1.1',       # this is your dns server
  $netmask = '255.255.255.0', # this is your netmask
  $ilouser = 'admin',         # this is the default admin username you wish to create
  $ilouserpass = 'password',  # this is the default password for the default admin user

  ##if autoip is set to true, gw and ip will be disregarded
  $gw = '192.168.1.254',  # You will need to set this if autoip is false
  $ip = '192.168.1.2',    # You will need to set this if autoip is false

  ## This will examine the IP of the system and substitute the value of param ilonet for the third octet, fx on a system where
  ## facter ipaddress is 192.168.1.10 and a param ilonet = '27', ip of the ilo will be 192.168.27.10
  $autoip = false,            # set to true if you want to use the auto ip setting which will set ip and gateway automatically
                              # based on the current ip address of the system.  
  #Set only if autoip is true
  $ilonet = '27',     # if you want to put your ilo card on a separate network  example: 192.168.xxx.22; disregarded if autoip is false
  $gwbit = '240',     # this is the gateway bit if using a 24 bit netmask: example: 192.168.25.xxx, disregarded if autoip is false

  $logfile='/tmp/ilosettings.log',
  $settingsfile='/etc/ilosettings.xml',
  ){

  if ($autoip) {
    notify { 'autoip is true.  gateway and ip values will be automatically set.': }
  }
  
  # Don't run these if not an HP machine
  if ( $::manufacturer ) and ( $::manufacturer == 'HP') {
    # Not all ilos have the same feature set and thus ilo configs are not backwards compatible
    case $::productname {
      /G5/: { $ilogen = 2 }
      /G6/: { $ilogen = 2 }
      /G4/: { $ilogen = 1 }
      /G3/: { $ilogen = 0 }
      /G7/: { $ilogen = 3 }
      /Gen8/: { $ilogen = 4 }
      /Gen9/: { $ilogen = 4 }
      default: { $ilogen = 1 }
                
    }
    exec{"/sbin/hponcfg -f ${settingsfile} -l ${logfile}":
      onlyif      => 'test -e /sbin/hponcfg',
      path        =>'/bin:/usr/sbin:/usr/bin',
      refreshonly => true,
      subscribe   => File[$settingsfile],
      timeout     => 0,
    }
    
    package { 'hponcfg':
      ensure => 'present',
    }
    # since the template accomodates dhcp and static there is no need to change the template file
    $ilotemplate = 'hpilo/iloconfig.erb'
    file { $settingsfile:
      content => template($ilotemplate),
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0644'
    }
  }
}
