#!/usr/bin/env rspec
require 'spec_helper'

#TODO Test non-HP manufacturer does nothing

describe 'hpilo' do
  let(:facts) do 
    {
      :manufacturer => 'HP',
      :osfamily => 'RedHat',
      :ipaddress => '3.3.3.3',
    }
  end

  let(:default_params) do 
    {
      :gw    => '1.1.1.1',
      :ip      => '2.2.2.2',
      :settingsfile => '/ilosettings.xml',
    }
  end

  describe 'test hpilo when dhcp == false' do
    let(:params) do 
      {
        :dhcp         => false,
        :logfile      => '/tmp/ilosettings.log',
        :settingsfile => '/ilosettings.xml',
      }.merge default_params
    end

    it { is_expected.to contain_class('hpilo') }
    it { is_expected.to contain_package('hponcfg').with_ensure('present') }
    it { is_expected.to contain_exec("/sbin/hponcfg -f /ilosettings.xml -l /tmp/ilosettings.log") }
    it { is_expected.to contain_file("/ilosettings.xml").
      with_content(/<GATEWAY_IP_ADDRESS VALUE = \"1.1.1.1\"\/>/).
      with_content(/<IP_ADDRESS VALUE = \"2.2.2.2\"\/>/) }
   
  end

  describe 'test hpilo when dhcp == true' do
    let(:params) do 
      {
        :dhcp => true
      }.merge default_params
    end
    #it { p subject.resources }
    it { is_expected.to contain_class('hpilo') }
    it { is_expected.to contain_package('hponcfg').with_ensure('present') }
    it { is_expected.to contain_exec("/sbin/hponcfg -f /ilosettings.xml -l /tmp/ilosettings.log") }
    it { is_expected.to contain_file("/ilosettings.xml").with_content(/<DHCP_ENABLE value=\"Yes\"\/>/)  }
  end

  describe 'test hpilo when autoip == true' do 
    let(:params) do 
      {
        :autoip => true,
        :ilonet => '28',
      }.merge default_params
    end
    ##it { p subject.resources }
    it { is_expected.to contain_file('/ilosettings.xml').with_content(/IP_ADDRESS VALUE = \"3.3.28.3\"\/>/) }
  end

  describe 'test hpilo when shared == true' do
    let(:params) do 
      {
        :shared => true,
      }.merge default_params
    end
    ##it { p subject.resources }
    it { is_expected.to contain_file('/ilosettings.xml').with_content(/<SHARED_NETWORK_PORT VALUE=\"Y\"\/>/) }
  end

  describe 'test hpilo when shared == false' do
    let(:params) do 
      {
        :shared => false
      }.merge default_params
    end
    ##it { p subject.resources }
    it { is_expected.to contain_file('/ilosettings.xml').with_content(/<SHARED_NETWORK_PORT VALUE=\"N\"\/>/) }
  end
end
