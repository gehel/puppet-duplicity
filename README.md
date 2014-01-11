# Puppet module: duplicity

This is a Puppet module for duplicity
It provides only package installation and file configuration.

Based on Example42 layouts by Alessandro Franceschi / Lab42

Official git repository: http://github.com/gehel/puppet-duplicity

Released under the terms of Apache 2 License.

This module requires the presence of Example42 Puppi module in your modulepath.


## USAGE - Basic management

* Install duplicity with default settings

        class { 'duplicity': }

* Install a specific version of duplicity package

        class { 'duplicity':
          version => '1.0.1',
        }

* Remove duplicity resources

        class { 'duplicity':
          absent => true
        }

* Enable auditing without without making changes on existing duplicity configuration *files*

        class { 'duplicity':
          audit_only => true
        }

* Module dry-run: Do not make any change on *all* the resources provided by the module

        class { 'duplicity':
          noops => true
        }


## USAGE - Overrides and Customizations
* Use custom sources for main config file 

        class { 'duplicity':
          source => [ "puppet:///modules/example42/duplicity/duplicity.conf-${hostname}" , "puppet:///modules/example42/duplicity/duplicity.conf" ], 
        }


* Use custom source directory for the whole configuration dir

        class { 'duplicity':
          source_dir       => 'puppet:///modules/example42/duplicity/conf/',
          source_dir_purge => false, # Set to true to purge any existing file not present in $source_dir
        }

* Use custom template for main config file. Note that template and source arguments are alternative. 

        class { 'duplicity':
          template => 'example42/duplicity/duplicity.conf.erb',
        }

* Automatically include a custom subclass

        class { 'duplicity':
          my_class => 'example42::my_duplicity',
        }



## TESTING
[![Build Status](https://travis-ci.org/gehel/puppet-duplicity.png?branch=master)](https://travis-ci.org/gehel/puppet-duplicity)
