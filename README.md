Spikor Forge
============

A simple Puppet forge implementation which supports multiple environments meant to be used together with Spikor.
It requires no database backend and will just read the metadata from the modules from disk instead.

Installation
------------

It requires Sinatra (at least version 1.3+). Can be run as a regular Rack application under for example Passenger.
There is a sample apache vhost configuration in the archive.

By default modules should be stored under `/var/lib/spikor-forge/modules`. It expects the directory structure to be `environment/user/module/user-module-version.tar.gz`.

Usage
-----

Set the `module_repository` setting in Puppet to point to your spikor forge instance plus environment, for example `module_repository=http://forge.example.com/$environment`. To be able to use environments Puppet 3.3+ is required due to bugs in the module tool in earlier versions.

After that you should be able to install modules using `puppet module install`.

If a module is not found in the environment you asked for it will search for it in the production environment instead.
