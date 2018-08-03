# Copyright 2016-2018 Radiator Software Oy
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# Cookbook Name:: radiator
# Recipe:: dependencies
#

# NOTE:
#
# The below if..else and case..when statements are a bit convoluted, but the goal
# is to install dependency modules from either a repository with 'package' or from CPAN with 'cpan_module'.
#
# Dependencies are installed for both core Radiator and it's different packs.
#
# Sadly, not all Perl modules are available in the distribution repositories, in the future Radiator Software
# might provide you with a repository for the needed dependencies. For the time being, the only sane way is to utilise CPAN.
#
# Due to the dependency on CPAN and build tools for some modules, this recipe isn't included in the run_list by default.
#
# By doing so, you have decided to install gcc, make and the like.
#

apt_update 'apt-get update' do
  action :update
end

# Needed for building some modules from CPAN
include_recipe 'build-essential::default'

if node['radiator']['install_packs'].is_a?(Array)
  packs = node['radiator']['install_packs']
elsif node['radiator']['install_packs'].is_a?(Hash)
  packs = node['radiator']['install_packs'].keys.map(&:to_s)
end

case node['platform_family']
when 'debian'
  package %w(perl cpanminus libdigest-md5-file-perl libdigest-sha-perl libdigest-md4-perl)

  if packs.include?('sim')
    package %w(libconvert-asn1-perl libcrypt-rijndael-perl libdigest-sha-perl libdigest-hmac-perl libdata-messagepack-perl)

    cpan_module 'Digest::SHA1'
  end

  if packs.include?('gba-bsf')
    package %w(libxml-libxml-perl libdigest-sha-perl libcache-fastmmap-perl libcrypt-rijndael-perl libdigest-sha-perl libdigest-hmac-perl libdata-messagepack-perl)
  end
when 'rhel'
  package %w(perl perl-App-cpanminus perl-Digest-MD5 perl-Digest-SHA perl-Time-HiRes)

  cpan_module 'Digest::MD4'

  package %w(perl-Convert-ASN1 perl-Digest-SHA1) if packs.include?('sim')

  if packs.include?('gba-bsf')
    package %w(perl-XML-LibXML perl-Digest-SHA)

    cpan_module 'Cache::FastMmap'
  end
end
