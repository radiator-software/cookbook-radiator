control 'radiator-rpm-01' do
  title 'Radiator installed from rpm'
  desc 'Ensure Radiator installation from rpm has succeeded'

  describe.one do
    # Either: new rpm
    describe file('/usr/local/share/perl5/Radius') do
      it { should be_directory }
      it { should be_owned_by 'root' }
    end

    # Or: old rpm
    describe file('/usr/lib/perl5/Radius') do
      it { should be_directory }
      it { should be_owned_by 'root' }
    end
  end

  describe file('/usr/bin/radiusd') do
    it { should be_owned_by 'root' }
  end

  describe.one do
    # Either: new rpm
    describe package('radiator') do
      it { should be_installed }
    end

    # Or: old rpm
    describe package('Radiator') do
      it { should be_installed }
    end
  end
end
