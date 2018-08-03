# Radiator Cookbook

[![Build Status](https://travis-ci.org/radiator-software/cookbook-radiator.svg?branch=master)](https://travis-ci.org/radiator-software/cookbook-radiator)
[![Coverage Status](https://coveralls.io/repos/github/radiator-software/cookbook-radiator/badge.svg?branch=master)](https://coveralls.io/github/radiator-software/cookbook-radiator?branch=master)

This cookbook strives to be a simple way of handling the installation of [Radiator](https://radiatorsoftware.com/products/radiator/) and it's dependencies on different platforms. Radiator is an AAA server for RADIUS, TACACS+ and Diameter from Radiator Software. Radiator is a commercial product and has a separate commercial license. You can find more information in the [License and Authors](#license-and-authors) section below.

As Radiator is not available publicly you will need to have a wrapper cookbook or some other way of delivering the installation file to the server you are using this cookbook on.

The configuration of Radiator is pretty flexible and there are several use cases. It is not in the scope of this cookbook to support each and every available parameter of the Radiator configuration. Thus, the configuration provided by the example attributes and template are very simple.

These example attributes serve as a starting point. Much like the goodies in the Radiator installation itself, more examples will be added later. See the example attributes section below for more information.

You can override the template with your own in a wrapper cookbook to achieve a configuration suitable for your business logic.

Development of this cookbook started when the version of Radiator was 4.16. You can probably use this to install older Radiators, but it is not supported.

Installation assumes internet connectivity for the dependency installation. If you have any limitations in your environment, you can install the needed packages yourself in a wrapper cookbook for example.

## Requirements

### Platforms

This cookbook is tested on the following platforms using the [Test Kitchen](http://kitchen.ci) `.kitchen.yml` in the repository.

- RHEL/CentOS 7 64-bit
- Ubuntu 16.04 64-bit

Unlisted platforms in the same family, of similar or equivalent versions may work with or without modification to this cookbook. For a list of supported platforms for Radiator, see the [Radiator documentation](https://radiatorsoftware.com/products/radiator/documentation/).

### Chef

- Chef 13.4+

### Cookbooks

- poise
   * Used by all the resources in this cookbooks
- poise-service
   * Used for setting up system services for Radiator instances
- poise-archive
   * Used for the archive installation of Radiator
- perl
   * Used for the cpan_module resource
- build-essential
   * Used for installing build related tools, since some CPAN modules require those

## Attributes

The attributes used by this cookbook are under the `radiator` name space. Default values are set in `attributes/default.rb`. An example configuration is available in `attributes/example.rb`.

This cookbook is meant to be used with the provided resources, but you can control some aspects via attributes.

Radiator installation attributes:

* `node['radiator']['user']`: The user to install, configure and run Radiator for. This is a string. Defaults to `radiator`.
* `node['radiator']['group']`: The group to install, configure and run Radiator for.  This is a string.Defaults to `radiator`.
* `node['radiator']['user_home']`: The home directory for the service user.  This is a string.Defaults to `/home/radiator`.
* `node['radiator']['user_shell']`: The shell for the service user. This is a string. Defaults to `/bin/false`.

Additional pack installation attributes:

Currently supported are Radiator SIM Pack, Radiator Carrier Pack, Radiator Telco Pack and Radiator GBA/BSF Pack.

* `node['radiator']['supported_packs']`: The packs supported by this cookbook. You should not have the need to change this.  This is an array. Defaults to `['sim', 'telco', 'carrier', 'gba-bsf']`.
* `node['radiator']['install_packs']`: Similar to the above. A list of packs to be installed with the `radiator_installation` resource. You can also control the list with the property of the resource itself. This list exists as an attribute mostly for the use of the `dependencies` recipe. This is an array. Defaults to `[]`.

Evaluation attributes:

* `node['radiator']['evaluation']['install_version']`: The version of Radiator to be installed with the `evaluation` recipe. This is a string. Defaults to `4.21`.
* `node['radiator']['evaluation']['download_username']`: The username to be used when downloading the evaluation version with the `evaluation` recipe. This is a string. You will have to contact support for your username.
* `node['radiator']['evaluation']['download_password']`: The password to be used when downloading the evaluation version with the `evaluation` recipe. This is a string. You will have to contact support for your password.
* `node['radiator']['evaluation']['show_license']`: Whether to print the Radiator license when installing with the `evaluation` recipe. This is a true or false value. Defaults to `true`.
* `node['radiator']['evaluation']['accept_license']`: Whether to accept the Radiator license when installing with the `evaluation` recipe. This is a true or false value. Defaults to `false`. You will need to change this to true, to get the installation to work.

Example configuration attributes:

These attributes are set in the `attributes/example.rb` and are used in the `radiator:etc/radiator/example.cfg.erb` template to create a simple configuration.

See the template file itself for more details on how these are used.

```ruby
default['radiator']['configuration']['Trace'] = 2
default['radiator']['configuration']['AuthPort'] = 1812
default['radiator']['configuration']['AcctPort'] = 1813
default['radiator']['configuration']['LogDir'] = '/var/log/radiator'
default['radiator']['configuration']['Log']['FILE']['Identifier'] = 'radiator-log'
default['radiator']['configuration']['Log']['FILE']['Trace'] = 2
default['radiator']['configuration']['Log']['FILE']['Filename'] = '%L/radiator.log'
default['radiator']['configuration']['Client'] = {
  'DEFAULT' => {
    'Secret' => 'chef',
    'Identifier' => 'chef'
  }
}
```

## Recipes

### default

This is a dummy recipe.

### dependencies

The dependencies recipe handles the installation of any dependency modules, either from the distribution repositories or CPAN. If you select this recipe in your run_list, either directly or by using the `evaluation` recipe, you accept the fact that modules are installed from CPAN _and_ software for building packages, like gcc and make, will be installed.

### evaluation

This recipe will use the evaluation attribute described above to download the spesified version of Radiator for evaluation purposes. You will need to accept the license by setting the `node['radiator']['evaluation']['accept_license']` attribute to `true` before this will work.

More details can be found in the evaluation section below.

## Resources

### radiator_installation

The `radiator_installation` resource is divided into a few providers, namely `archive` and `package`. The providers naturally do things a bit differently, but the goal is to install Radiator, and the packs, from either an archive format (usually .tgz) or a package (deb or rpm).

#### Actions

* `create`: This handles installation and is the default.
* `remove`: This handles uninstallation.

#### Properties

* `version`: Spesifies the version of Radiator to be installed. Can be a string or nil. Defaults to the name of the resource.
* `user`: The service user to be created and which the install uses. Can be a string or a false value. Defaults to `node['radiator']['user']`.
* `group`: The service group to be created and which the install uses. Can only be a string. If `user` is false, this won't be used. Defaults to `node['radiator']['group']`.
* `user_home`: The home directory for the service user to be created. Can only be a string. If `user` is false, this won't be used. Defaults to `node['radiator']['user_home']`.
* `user_shell`: The shell for the service user. Can only be a string. If `user` is false, this won't be used. Defaults to `node['radiator']['user_shell']`.
* `install_options`: The installation options to be passed on as properties to the resources handling the installation. This can be used to control the options of the `yum_package` and `apt_package` resources for example. A more detailed example below. Defaults to: `{}`.
* `packs`: The extra packs to be installed. The options are similar to the parent `radiator_installation` resource, which means that you can pass `install_options` to individual pack installs for example. A more detailed example below. This is a `Poise` library `option_collector`, so you can pass a hash or a block-like syntax. Defaults to `{}`.

#### Examples

Install Radiator from an archive:

```ruby
radiator_installation 'example-archive-install' do
  provider 'archive'

  version '4.21'

  install_options do
    path 'https://example.com/downloads/Radiator-4.21.tgz'
  end
end
```

```ruby
radiator_installation '4.21' do
  provider 'archive'

  install_options do
    path 'https://example.com/downloads/Radiator-4.21.tgz'
  end
end
```

```ruby
node.default['my_wrapper_cookbook']['radiator']['version'] = '4.21'
node.default['my_wrapper_cookbook']['radiator']['path'] = 'https://example.com/downloads/Radiator-4.21.tgz'

radiator_installation 'example-archive-install-from-attributes' do
  provider 'archive'

  install_options node['my_wrapper_cookbook']['radiator']
end
```

Install Radiator from a package:

```ruby
radiator_installation 'example-package-install' do
  provider 'package'

  version '4.21'
end
```

```ruby
radiator_installation '4.21' do
  provider 'package'

  install_options do
    source 'https://example.com/downloads/Radiator-4.21.rpm'
  end
end
```

```ruby
radiator_installation 'example-install-of-any-version-with-packs-from-repository' do
  provider 'package'

  version nil

  packs %w(sim carrier)
end
```

```ruby
radiator_installation 'example-upgrade-of-radiator' do
  provider 'package'

  version nil

  install_options do
    action :upgrade
  end
end
```


```ruby
node.default['my_wrapper_cookbook']['radiator']['sim']['install_options']['version'] = '2.3'
node.default['my_wrapper_cookbook']['radiator']['sim']['install_options']['source'] = 'https://example.com/downloads/Radiator-EAP-SIM-2.3.rpm'

radiator_installation 'example-package-install-with-packs' do
  provider 'package'

  version '4.2.0'

  packs(
    sim: node['my_wrapper_cookbook']['radiator']['sim']
  )
end
```

Some more examples can be found in the test directories spec/unit/libraries and test/fixtures/cookbooks/test/recipes.

### radiator_configuration

The `radiator_configuration` resource is renders the configuration file of Radiator from a template. It also supports a `config_verify` option to make sure the `radiusd -c` config check passes before putting the new configuration file in to use. The resource provides a `config_path` method you can use to grab the full path of the configuration file for use in other resources.

#### Actions

* `create`: This handles the creation of the configuration file and is the default.
* `remove`: This handles the removal of the configuration file.

#### Properties

* `user`: The user that owns the configuration file. Can only be a string. Defaults to `node['radiator']['user']`.
* `group`: The group that owns the configuration file. Can only be a string. Defaults to `node['radiator']['group']`.
* `config_file`: The name of the configuration file. Can only be a string. Defaults to the name of the resource suffixed with `.cfg`.
* `config_directory`: The directory in which the configuration file is rendered. Can only be a string. Defaults to: `/etc/radiator`.
* `config_template`: The template to be used as the source for rendering the configuration file. Can only be a string. A source cookbook can be supplied by providing the cookbook and file with the syntax: `<cookbook>:<template`. If the cookbook is not provided, the file is expected to be found in the calling cookbook. Defaults to: `etc/radiator/example.cfg.erb`.
* `config_variables`: Variables to be pushed to the rendered template. Can only be a hash. Defaults to: `{}`.
* `config_helpers`: Helper methods or modules to be pushed to the rendered template. Can only be an array. Defaults to: `[]`. The methods in `Radiator::Helpers::Configuration` module are always included.
* `config_mode`: The permissions of the configuration file. Can only be a string. Defaults to: `0644`.
* `config_verify`: Whether to run `radiusd` config check during the render. Can be a true or false value. Defaults to: `true`.
* `config_sensitive`: Whether to pass the `sensitive` property to the rendered template. Can be a true or false value. Use this if you have passwords in the configuration that you want to hide from Chef logging. Defaults to: `false`.

#### Examples

Create a radius.cfg configuration file:

```ruby
radiator_configuration 'radius' do
  config_template 'my_wrapper_cookbook:my_templates/raw-radiator-config.cfg.erb'
end
```

```ruby
node.default['my_wrapper_cookbook']['radiator']['configuration']['Trace'] = 4

radiator_configuration 'example-configuration' do
  config_file 'radius.cfg'

  config_template 'my_wrapper_cookbook:my_templates/radius.cfg.erb'

  config_variables(
    config: node['my_wrapper_cookbook']['radiator']['configuration'],
    example: true,
  )
end
```

Some more examples can be found in the test directories spec/unit/libraries and test/fixtures/cookbooks/test/recipes.

### radiator_service

The `radiator_service` resource creates service startup files and can be used to start, stop and reload the service. It supports starting multiple instances of the same service with `systemd` [instantiated units](https://www.freedesktop.org/software/systemd/man/systemd.unit.html) with the `instances` property. The resources is based on the `Poise` [ServiceMixin](https://github.com/poise/poise-service#servicemixin), so things that apply there, apply here too.

#### Actions

* `enable`: Create, enable and start the service. This is the default.
* `disable`: Stop, disable, and destroy the service.
* `start`: Start the service.
* `stop`: Stop the service.
* `restart`:  Stop and then start the service.
* `reload`: Reload the service with the `SIGHUP` signal.

#### Properties

* `user`: The user that is used to run the service. Can only be a string. Defaults to `node['radiator']['user']`.
* `group`: The group that is used to run the service. Can only be a string. Defaults to `node['radiator']['group']`.
* `directory`: The directory in which the service is started. Can only be a string. Defaults to `/var/run/radiator`.
* `config_path`: Path to the configuration file. Can only be a string. Defaults to: `/etc/radiator/<name of the service>.cfg`.
* `perl_bin`: Perl binary to be used for starting `radiusd`. Can only be a string. Defaults to: `/usr/bin/env perl`.
* `radiusd_bin`: Location of the `radiusd` executable. Can only be a string. Defaults to finding the correct path depending on the used `radiator_installation` resource.
* `instances`: Instances of the service to start with systemd. Can be an integer or array. Integer is the number of instances, array is used for the names of the instances. The name of the instance is passed on to the running Radiator with the `instance` global var. Defaults to: `0`.
* `args`: Any extra arguments to pass to `radiusd`. Can only be an array. Defaults to: `[]`.
* `modules`: Any extra modules to load with Perl. Can only be an array. These are prepended with `-M`. Defaults to: `[]`.
* `dictionaries`: Radiator dictionary files to pass to `radiusd`. Can only be an array. Defaults to: `['/etc/radiator/dictionary']`.
* `vars`: Any extra global vars to pass to `radiusd`. Can only be a hash. Defaults to: `{}`.
* `environment`: Any extra environment variables to provide for the service. Can only be a hash. Defaults to: `{}`.
* `restart_mode`: Restart mode in case of a systemd service. Can only be a string. Defaults to: `always`.
* `overrides`: Any systemd unit file overrides to create. Can be a string or a hash. The syntax is the same as Chef's `systemd_unit` [resource](https://docs.chef.io/resource_systemd_unit.html). Defaults to: `''`.

#### Examples

Run Radiator with a radius.cfg configuration file:

```ruby
radiator_service 'radius'
```

```ruby
radiator_service 'radiator' do
  config_path '/etc/radiator/radius.cfg'
end
```

```ruby
radiator_service 'radiator' do
  instances 4

  config_path '/etc/radiator/radius.cfg'
end
```

```ruby
radiator_service 'radiator' do
  instances ['one', 'two', 'three', 'four']

  config_path '/etc/radiator/radius.cfg'
end
```

Override some options for systemd and provide extra stuff for Radiator:

```ruby
radiator_service 'radiator' do
  config_path '/etc/radiator/my-exotic-configuration.cfg'
  directory '/home/radiator'

  modules ['Something::Special']
  args ['-trace 4']
  vars(
    my_variable: 'hello'
  )

  environment SOME_VARIABLE: 'hello world'

  restart_mode 'on-failure'
  overrides(
    Unit: {
      Documentation: 'https://www.open.com.au/radiator/ref.pdf',
    }
  )
end
```

Some more examples can be found in the test directories spec/unit/libraries and test/fixtures/cookbooks/test/recipes.


## Evaluation

If you have access to Radiator evaluation, you can use this cookbook to download the evaluation version and run it using [Vagrant](https://www.vagrantup.com). For more information about Radiator evaluation and licensing, see https://radiatorsoftware.com/evaluation/

The included `Vagrantfile` installs and configures a Linux box and uses this cookbook to setup Radiator. Two distributions are supported currently, Ubuntu 16.04 and CentOS 7.4. The boxes used are provided by the [Bento](https://github.com/chef/bento) project.

The Radiator evaluation archive is automatically downloaded with your credentials. It is also set to automatically accept the [license](https://radiatorsoftware.com/license/). By starting the Vagrant box, you agree to the Radiator Standard End User License Agreement.

Instructions:

* Install [Vagrant](https://www.vagrantup.com/docs/installation/).
    * The default provider is [Virtualbox](https://www.virtualbox.org/).
* Install [ChefDK](https://docs.chef.io/install_dk.html).
    * This is required for the Berkshelf integration plugin and working with Chef cookbooks and recipes.
* Install [Vagrant Berkshelf](https://github.com/berkshelf/vagrant-berkshelf) plugin.
    * Command: `vagrant plugin install vagrant-berkshelf`
    * This is required for handling cookbook dependencies in the Vagrant machine.
* Add your credentials for downloading the evaluation version in an environment variable:
    * Command: `export RADIATOR_EVAL_USERNAME=username`
    * Command: `export RADIATOR_EVAL_PASSWORD=password`
* Start the evaluation Vagrant box.
    * Command: `vagrant up radiator-ubuntu` or `vagrant up radiator-centos`.
    * By default the Ubuntu box is used.
* Wait for the Vagrant box to start. UDP ports 1812 and 1813 for authentication and accounting are forwarded and you can start testing.
    * You can login with the command: `vagrant ssh`.
    * If you have `radpwtst` at hand, you can test a RADIUS packet with the command: `radpwtst -auth_port 1812 -s localhost -noacct -secret evaluation`.

It is also possible to instantiate the evaluation box with `Test Kitchen`. More details below.

## Testing

The cookbook has unit tests in the form of Chefspec specs. You can find them in the `spec` directory. InSpec profiles are provided along with `.kitchen.yml`configuration for Test Kitchen. The profiles are in the `test/smoke` directory.

In addition the style is checked with [Cookstyle](https://github.com/chef/cookstyle/) and [Foodcritic](http://www.foodcritic.io/).

You can run the tests like so:

Style checks:
* `chef exec cookstyle`
* `chef exec foodcritic --rule-file .foodcritic .`

Unit testing:
* `chef exec rspec`

Smoke testing:
* This will converge all different platforms and Chef versions
    * `kitchen test`

Converging an evaluation machine:
* Ubuntu 16.04 with Chef 13.8.5
    * `kitchen converge evaluation-ubuntu-1604-1385`
* CentOS 7.4 with latest Chef'
    * `kitchen converge evaluation-centos-74-latest`

## License and Authors

Radiator is a commercial product and not included with this Chef cookbook.

Radiator and it's packs are licensed under Radiator Standard End User License Agreement. The Radiator Standard End User License Agreement is available at https://radiatorsoftware.com/license/

This Chef cookbook and it's files are licensed under the Apache License 2.0:

- Author: Miika Kankare [devsupport@radiatorsoftware.com](mailto:devsupport@radiatorsoftware.com)
- Copyright 2016-2018 Radiator Software Oy

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```