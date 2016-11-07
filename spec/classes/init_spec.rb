require 'spec_helper'
describe 'haproxywrapper' do
  mandatory_params = {}
  let(:facts) { mandatory_global_facts }
  let(:params) { mandatory_params }

  describe 'with defaults for all parameters' do
    it { should compile.with_all_deps }
    it { should contain_class('haproxywrapper') }
    it { should contain_class('haproxy::params') }
    it do
      should contain_class('haproxy').with({
        'custom_fragment'  => nil, # /!\ no default provided
        'defaults_options' => { 'log' => 'global', 'stats' => 'enable', 'option' => [ 'redispatch' ], 'retries' => '3', 'timeout' => [ 'http-request 10s', 'queue 1m', 'connect 10s', 'client 1m', 'server 1m', 'check 10s' ], 'maxconn' => '8000' },
        'global_options'   => { 'log' => '127.0.0.1 local0', 'chroot' => '/var/lib/haproxy', 'pidfile' => '/var/run/haproxy.pid', 'maxconn' => '4000', 'user' => 'haproxy', 'group' => 'haproxy', 'daemon' => '', 'stats' => 'socket /var/lib/haproxy/stats' },
        'merge_options'    => false,
        'package_ensure'   => 'present',
        'package_name'     => 'haproxy',
        'restart_command'  => nil, # /!\ no default provided
        'service_ensure'   => 'running',
        'service_manage'   => true,
        'config_dir'       => '/etc/haproxy',
        'config_file'      => '/etc/haproxy/haproxy.cfg',
      })
    end

    it { should have_haproxy__listen_resource_count(0) }
    it { should have_haproxy__frontend_resource_count(0) }
    it { should have_haproxy__backend_resource_count(0) }
    it { should have_haproxy__balancermember_resource_count(0) }
    it { should have_haproxy__userlist_resource_count(0) }
    it { should have_haproxy__peers_resource_count(0) }
    it { should have_haproxy__peer_resource_count(0) }
    it { should have_haproxy__mailers_resource_count(0) }
    it { should have_haproxy__mailer_resource_count(0) }
    it { should have_haproxy__instance_resource_count(1) } # one from haproxy, but none from haproxywrapper
    it { should have_haproxy__instance_service_resource_count(0) }
    it { should have_haproxy__mapfile_resource_count(0) }
  end

  describe 'with balancermember set to valid hash (containing two keys)' do
    balancermembers = mandatory_params.merge({
        :balancermember => {
          'puppet1' => {
            'listening_service' => 'puppetmasters',
            'ports'             => '8140',
            'server_names'      => 'puppet1',
            'ipaddresses'       => '127.0.1.1',
            'options'           => 'check port 8990'
          },
          'puppet2' => {
            'listening_service' => 'puppetmasters',
            'ports'             => '8140',
            'server_names'      => 'puppet2',
            'ipaddresses'       => '127.0.1.2',
            'options'           => 'check port 8990'
          },
        }
    })

    let(:params) { balancermembers }
    it { should have_haproxy__balancermember_resource_count(2) }
    it do
      should contain_haproxy__balancermember('puppet1').with({
        'listening_service' => 'puppetmasters',
        'ports'             => '8140',
        'server_names'      => 'puppet1',
        'ipaddresses'       => '127.0.1.1',
        'options'           => 'check port 8990'
      })
    end
    it do
      should contain_haproxy__balancermember('puppet2').with({
        'listening_service' => 'puppetmasters',
        'ports'             => '8140',
        'server_names'      => 'puppet2',
        'ipaddresses'       => '127.0.1.2',
        'options'           => 'check port 8990'
      })
    end

    context 'when balancermember is set to valid %w(puppet1)' do
      let(:params) { balancermembers.merge({ :balancermember_active => %w(puppet1) }) }
      it { should contain_haproxy__balancermember('puppet1') }
      it { should have_haproxy__balancermember_resource_count(1) }
    end
  end

  describe 'variable type and content validations' do
    validations = {
      'absolute_path' => {
        :name    => %w(config_dir), # /!\ config_file should also be tested with validate_absolute_path()
        :valid   => %w(/absolute/filepath /absolute/directory/),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'is not an absolute path',
      },
      'array' => {
        :name    => %w(balancermember_active),
        :valid   => [%w(array)],
        :invalid => ['string', { 'ha' => 'sh' }, 3, 2.42, true, false],
        :message => 'is not an Array',
      },
      'boolean' => {
        :name    => %w(merge_options),
        :valid   => [true, false],
        :invalid => ['true', 'false', %w(array), { 'ha' => 'sh' }, 3, 2.42, nil],
        :message => '(is not a boolean|Unknown type of boolean given)',
      },
      'hash' => {
        :name    => %w(default_options global_options),
        :valid   => [], # valid hashes are to complex to block test them here.
        :invalid => ['string', 3, 2.42, %w(array), true, false, nil],
        :message => 'is not a Hash',
      },
      'regex_package_ensure' => {
        :name    => %w(package_ensure),
        :valid   => ['present', 'installed', 'absent'],
        :invalid => ['invalid', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => '(must be absent, present or installed|input needs to be a String)',
      },
      'regex_service_ensure' => {
        :name    => %w(service_ensure),
        :valid   => ['running', 'stopped'],
        :invalid => ['invalid', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => '(must be running or stopped|input needs to be a String)',
      },
      'string' => {
        :name    => %w(custom_fragment package_name restart_command service_options),
        :valid   => %w(string),
        :invalid => [%w(array), { 'ha' => 'sh' }, true, false], # removed integer and float for Puppet 3 compatibility
        :message => 'is not a string',
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => valid, }].reduce(:merge) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => invalid, }].reduce(:merge) }
            it 'should fail' do
              expect { should contain_class(subject) }.to raise_error(Puppet::Error, /#{var[:message]}/)
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
