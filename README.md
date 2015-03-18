#hpilo

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with hpilo](#setup)
    * [What hpilo affects](#what-hpilo-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with hpilo](#beginning-with-[hpilo])
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

hpilo configures Hewlett-Packard's iLO card by creating ilosettings.xml and then using the
HP application hponcfg to load the settings file to the iLO.

Integrated Lights-Out, or iLO, is an embedded server management technology exclusive to 
Hewlett-Packard but similar in functionality to the Lights out management (LOM) technology 
of other vendors, for example Sun/Oracle's ILOM, Dell DRAC and the IBM Remote Supervisor Adapter.

Tested with Puppet 3.2+.

##Module Description

hpilo can setup iLO to use dhcp, user-selected static IP, or assign a static IP automatically 
based on the system's IP.

##Setup

###What hpilo affects

* creates/modifies /etc/ilosettings.xml and /tmp/ilosettings.log
* installs /sbin/hponcfg from HP Proliant support repo.

###Setup Requirements

You will need the repo from http://downloads.linux.hp.com/SDR/downloads/ProLiantSupportPack/
The hpilo module will install hponcfg from this repo.

###Beginning with hpilo

    class {'hpilo':  }

##Usage

You can easily configure many parameters of iLo. 

For DHCP:

    class { 'hpilo': 
      dhcp => true,
      ilouser => 'admin',
      ilouserpass => 'password'
    }

For static:

    class { 'hpilo':
      dns => '192.168.1.1',
      gw => '192.168.1.1',
      ip => '192.168.1.10',
      netmask => '255.255.255.0',
      shared => true,
      ilouser => 'admin',
      ilouserpass => 'password',
    }

For autoip (Take $::ipaddress fact and sub 3rd octet with hpilo::ilonet value,
fx if ipaddress of system is 192.168.2.10 ilo will get 192.168.3.10:

    class { 'hpilo':
      autoip => true,
      ilonet => '3',
      shared => true,
      ilouser => 'admin',
      ilouserpass => 'password',
    }     

To configure with yaml in hiera for Puppet 3:
    
    hpilo::autoip: false
    hpilo::dhcp: false
    hpilo::dns: '192.168.1.1'
    hpilo::gw: '192.168.1.1'
    hpilo::gwbit: '240'
    hpilo::ilonet: '3'
    hpilo::ilouser: 'admin'
    hpilo::ilouserpass: 'password'
    hpilo::ip: '192.168.1.2'
    hpilo::logfile: '/tmp/ilosettings.log'
    hpilo::netmask: '255.255.255.0'
    hpilo::settingsfile : '/etc/ilosettings.xml'
    hpilo::shared: true

##Reference
 * [iLO configuration guide](http://h20000.www2.hp.com/bc/docs/support/SupportManual/c02774508/c02774508.pdf)
 * [More about iLO](http://h20341.www2.hp.com/integrity/w1/en/software/integrity-lights-out.html?jumpid=ex_r11294_us/en/large/tsg/go_integrityilo)

##Limitations
If you modify network settings but not the user after the initial run, hponcfg 
will return an error exit code for trying to create a user that already exists,
but will still apply the new network settings.

##Similar Modules
If you like this module, I have built a similar module that is generic and manages the IMPI device and IPMI user and doesn't depend on hp tools.
[BMClib](https://github.com/logicminds/bmclib)

## Development
This module uses puppet-blacksmith to help with release management.

Ensure you run bundle install

` bundle install`

### View all rake tasks
`bundle exec rake -T`

### Test
`bundle exec rake spec`

### To Release

```shell
   bundle exec rake module:release    # Release the Puppet module, doing a clean, build, tag, push, bump_commit and git push
```
##Contributors
 * Original module by Corey Osman <corey@logicminds.biz>
 * Major refactor by Eric Sakowski <sakowski@gmail.com>
