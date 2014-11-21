require 'logger'
require_relative '../spec_helper'

describe AdminUI::CC, :type => :integration do
  include CCHelper

  let(:ccdb_file)  { '/tmp/admin_ui_ccdb.db' }
  let(:ccdb_uri)   { "sqlite://#{ ccdb_file }" }
  let(:db_file)    { '/tmp/admin_ui_store.db' }
  let(:db_uri)     { "sqlite://#{ db_file }" }
  let(:log_file)   { '/tmp/admin_ui.log' }
  let(:logger)     { Logger.new(log_file) }
  let(:uaadb_file) { '/tmp/admin_ui_uaadb.db' }
  let(:uaadb_uri)  { "sqlite://#{ uaadb_file }" }
  let(:config) do
    AdminUI::Config.load(:ccdb_uri                            => ccdb_uri,
                         :cloud_controller_uri                => 'http://api.cloudfoundry',
                         :db_uri                              => db_uri,
                         :uaadb_uri                           => uaadb_uri,
                         :uaa_client                          => { :id => 'id', :secret => 'secret' })
  end
  let(:client) { AdminUI::CCRestClient.new(config, logger) }

  def cleanup_files
    Process.wait(Process.spawn({}, "rm -fr #{ ccdb_file } #{ db_file } #{ log_file } #{ uaadb_file }"))
  end

  before do
    cleanup_files

    AdminUI::Config.any_instance.stub(:validate)
    cc_stub(config)
  end

  let(:cc) { AdminUI::CC.new(config, logger, client, true) }

  after do
    Thread.list.each do |thread|
      unless thread == Thread.main
        thread.kill
        thread.join
      end
    end

    cleanup_files
  end

  context 'Stubbed' do
    it 'clears the application cache' do
      expect(cc.applications['items'].length).to eq(1)
      cc_clear_apps_cache_stub(config)
      cc.invalidate_applications
      expect(cc.applications['items'].length).to eq(0)
    end

    it 'clears the organizations cache' do
      expect(cc.organizations['items'].length).to eq(1)
      cc_clear_organizations_cache_stub(config)
      cc.invalidate_organizations
      expect(cc.organizations['items'].length).to eq(0)
    end

    it 'clears the organizations auditors cache' do
      expect(cc.organizations_auditors['items'].length).to eq(1)
      cc_clear_organizations_cache_stub(config)
      cc.invalidate_organizations_auditors
      expect(cc.organizations_auditors['items'].length).to eq(0)
    end

    it 'clears the organizations billing_managers cache' do
      expect(cc.organizations_billing_managers['items'].length).to eq(1)
      cc_clear_organizations_cache_stub(config)
      cc.invalidate_organizations_billing_managers
      expect(cc.organizations_billing_managers['items'].length).to eq(0)
    end

    it 'clears the organizations managers cache' do
      expect(cc.organizations_managers['items'].length).to eq(1)
      cc_clear_organizations_cache_stub(config)
      cc.invalidate_organizations_managers
      expect(cc.organizations_managers['items'].length).to eq(0)
    end

    it 'clears the organizations users cache' do
      expect(cc.organizations_users['items'].length).to eq(1)
      cc_clear_organizations_cache_stub(config)
      cc.invalidate_organizations_users
      expect(cc.organizations_users['items'].length).to eq(0)
    end

    it 'clears the route cache' do
      expect(cc.routes['items'].length).to eq(1)
      cc_clear_routes_cache_stub(config)
      cc.invalidate_routes
      expect(cc.routes['items'].length).to eq(0)
    end

    it 'clears the service plan cache' do
      expect(cc.service_plans['items'].length).to eq(1)
      cc_clear_service_plans_cache_stub(config)
      cc.invalidate_service_plans
      expect(cc.service_plans['items'].length).to eq(0)
    end

    it 'clears the spaces auditors cache' do
      expect(cc.spaces_auditors['items'].length).to eq(1)
      cc_clear_organizations_cache_stub(config)
      cc.invalidate_spaces_auditors
      expect(cc.spaces_auditors['items'].length).to eq(0)
    end

    it 'clears the spaces developers cache' do
      expect(cc.spaces_developers['items'].length).to eq(1)
      cc_clear_organizations_cache_stub(config)
      cc.invalidate_spaces_developers
      expect(cc.spaces_developers['items'].length).to eq(0)
    end

    it 'clears the spaces managers cache' do
      expect(cc.spaces_managers['items'].length).to eq(1)
      cc_clear_organizations_cache_stub(config)
      cc.invalidate_spaces_managers
      expect(cc.spaces_managers['items'].length).to eq(0)
    end

    shared_examples 'common cc retrieval' do
      it 'verify cc retrieval' do
        expect(results['connected']).to eq(true)
        items = results['items']
        expect(items.length).to eq(1)
        expect(items[0]).to include(expected)
      end
    end

    context 'returns connected applications' do
      let(:results)  { cc.applications }
      let(:expected) { cc_app }

      it_behaves_like('common cc retrieval')
    end

    it 'returns applications_count' do
      expect(cc.applications_count).to be(1)
    end

    it 'returns applications_running_instances' do
      expect(cc.applications_running_instances).to be(1)
    end

    it 'returns applications_total_instances' do
      expect(cc.applications_total_instances).to be(1)
    end

    context 'returns connected apps_routes' do
      let(:results)  { cc.apps_routes }
      let(:expected) { cc_app_route }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected domains' do
      let(:results)  { cc.domains }
      let(:expected) { cc_domain }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected group_membership' do
      let(:results)  { cc.group_membership }
      let(:expected) { uaa_group_membership }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected groups' do
      let(:results)  { cc.groups }
      let(:expected) { uaa_group }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected organizations' do
      let(:results)  { cc.organizations }
      let(:expected) { cc_organization }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected organizations_auditors' do
      let(:results)  { cc.organizations_auditors }
      let(:expected) { cc_organization_auditor }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected organizations_billing_managers' do
      let(:results)  { cc.organizations_billing_managers }
      let(:expected) { cc_organization_billing_manager }

      it_behaves_like('common cc retrieval')
    end

    it 'returns organizations_count' do
      expect(cc.organizations_count).to be(1)
    end

    context 'returns connected organizations_managers' do
      let(:results)  { cc.organizations_managers }
      let(:expected) { cc_organization_manager }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected organizations_users' do
      let(:results)  { cc.organizations_users }
      let(:expected) { cc_organization_user }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected quota_definitions' do
      let(:results)  { cc.quota_definitions }
      let(:expected) { cc_quota_definition }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected routes' do
      let(:results)  { cc.routes }
      let(:expected) { cc_route }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected service_bindings' do
      let(:results)  { cc.service_bindings }
      let(:expected) { cc_service_binding }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected service_brokers' do
      let(:results)  { cc.service_brokers }
      let(:expected) { cc_service_broker }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected service_instances' do
      let(:results)  { cc.service_instances }
      let(:expected) { cc_service_instance }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected service_plans' do
      let(:results)  { cc.service_plans }
      let(:expected) { cc_service_plan }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected service_plan_visibilities' do
      let(:results)  { cc.service_plan_visibilities }
      let(:expected) { cc_service_plan_visibility }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected services' do
      let(:results)  { cc.services }
      let(:expected) { cc_service }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected spaces' do
      let(:results)  { cc.spaces }
      let(:expected) { cc_space }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected spaces_auditors' do
      let(:results)  { cc.spaces_auditors }
      let(:expected) { cc_space_auditor }

      it_behaves_like('common cc retrieval')
    end

    it 'returns spaces_count' do
      expect(cc.spaces_count).to be(1)
    end

    context 'returns connected spaces_developers' do
      let(:results)  { cc.spaces_developers }
      let(:expected) { cc_space_developer }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected spaces_managers' do
      let(:results)  { cc.spaces_managers }
      let(:expected) { cc_space_manager }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected users_cc' do
      let(:results)  { cc.users_cc }
      let(:expected) { cc_user }

      it_behaves_like('common cc retrieval')
    end

    it 'returns users_count' do
      expect(cc.users_count).to be(1)
    end

    context 'returns connected users_uaa' do
      let(:results)  { cc.users_uaa }
      let(:expected) { uaa_user }

      it_behaves_like('common cc retrieval')
    end
  end
end
