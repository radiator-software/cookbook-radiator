name 'radiator'
maintainer 'Radiator Software Oy'
maintainer_email 'devsupport@radiatorsoftware.com'
license 'Apache-2.0'
description 'Installs/Configures radiator'
long_description 'Installs/Configures radiator'
version '2.0.0'

issues_url 'https://github.com/radiator-software/cookbook-radiator/issues'
source_url 'https://github.com/radiator-software/cookbook-radiator'

depends 'perl', '~> 7.0'
depends 'poise', '~> 2.8'
depends 'poise-service', '~> 1.5'
depends 'poise-archive', '~> 1.5'
depends 'build-essential', '~> 8.1'

supports 'ubuntu', '>= 16.04'
supports 'centos', '>= 7.2'

chef_version '>= 13.4'
