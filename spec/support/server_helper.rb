require 'thread'
require 'webrick'
require_relative '../spec_helper'
require_relative 'cc_helper'
require_relative 'login_helper'
require_relative 'nats_helper'
require_relative 'varz_helper'
require_relative 'view_models_helper'

shared_context :server_context do
  include CCHelper
  include LoginHelper
  include NATSHelper
  include VARZHelper
  include ViewModelsHelper

  let(:ccdb_file) { '/tmp/admin_ui_ccdb.db' }
  let(:ccdb_uri) { "sqlite://#{ ccdb_file }" }
  let(:cloud_controller_uri) { 'http://api.localhost' }
  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:db_file) { '/tmp/admin_ui_store.db' }
  let(:db_uri) { "sqlite://#{ db_file }" }
  let(:host) { 'localhost' }
  let(:insert_second_quota_definition) { false }
  let(:log_file) { '/tmp/admin_ui.log' }
  let(:log_file_displayed) { '/tmp/admin_ui_displayed.log' }
  let(:log_file_displayed_contents) { 'These are test log file contents' }
  let(:log_file_displayed_contents_length) { log_file_displayed_contents.length }
  let(:log_file_displayed_modified) { Time.new(1976, 7, 4, 12, 34, 56, 0) }
  let(:log_file_displayed_modified_milliseconds) { AdminUI::Utils.time_in_milliseconds(log_file_displayed_modified) }
  let(:log_file_page_size) { 100 }
  let(:port) { 8071 }
  let(:uaadb_file) { '/tmp/admin_ui_uaadb.db' }
  let(:uaadb_uri) { "sqlite://#{ uaadb_file }" }
  let(:config) do
    {
      :ccdb_uri                            => ccdb_uri,
      :cloud_controller_discovery_interval => 3,
      :cloud_controller_uri                => cloud_controller_uri,
      :data_file                           => data_file,
      :db_uri                              => db_uri,
      :log_file                            => log_file,
      :log_file_page_size                  => log_file_page_size,
      :log_files                           => [log_file_displayed],
      :mbus                                => 'nats://nats:c1oudc0w@localhost:14222',
      :nats_discovery_interval             => 3,
      :port                                => port,
      :uaadb_uri                           => uaadb_uri,
      :uaa_client                          => { :id => 'id', :secret => 'secret' },
      :varz_discovery_interval             => 3
    }
  end

  def cleanup_files
    Process.wait(Process.spawn({}, "rm -fr #{ ccdb_file } #{ data_file } #{ db_file } #{ log_file } #{ log_file_displayed } #{ uaadb_file }"))
  end

  before do
    cleanup_files

    File.open(log_file_displayed, 'w') do |file|
      file << log_file_displayed_contents
    end
    File.utime(log_file_displayed_modified, log_file_displayed_modified, log_file_displayed)

    cc_stub(AdminUI::Config.load(config), insert_second_quota_definition)
    login_stub_admin
    nats_stub
    varz_stub

    ::WEBrick::Log.any_instance.stub(:log)

    mutex                  = Mutex.new
    condition              = ConditionVariable.new
    start_callback_invoked = false
    start_callback         = proc do
      mutex.synchronize do
        start_callback_invoked = true
        condition.broadcast
      end
    end

    Thread.new do
      AdminUI::Admin.new(config, true, start_callback).start
    end

    mutex.synchronize do
      condition.wait(mutex) until start_callback_invoked
    end
  end

  after do
    Rack::Handler::WEBrick.shutdown

    Thread.list.each do |thread|
      unless thread == Thread.main
        thread.kill
        thread.join
      end
    end

    cleanup_files
  end
end
