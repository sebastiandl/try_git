# line here

require 'rails_helper'

RSpec.describe CollectionController, type: :controller do
  before(:each) do
    @international_region_setting = create(:international_region_setting)
    @uk_region_setting = create(:uk_region_setting)
  end

  context 'GET show' do
    let(:taxon) { create(:taxon, permalink: 'collection') }
    let(:child_taxon) { create(:taxon, name: 'child_name') }
    let(:collection) { create(:collection, published: true) }
    before(:each) do
      taxon.children << child_taxon
      taxon.save
      request.headers['CloudFront-Viewer-Country'] = @uk_region_setting.countries.first.iso
    end

    it 'shows content when collection belongs to Region' do
      create(:region_settings_resource, region_setting: @uk_region_setting, resource: collection)
      get :show, id: "#{collection.id}-#{collection.title1.parameterize}"

      expect(@uk_region_setting.collections).to include(collection)
      expect(response.status).to be(200)
    end

    it 'redirects to home when collection does not belong to Region' do
      get :show, id: collection.id

      expect(@uk_region_setting.collections).not_to include(collection)
      expect(response).to redirect_to('/')
      expect(flash[:alert]).to eq(I18n.t(:not_available_in_your_country))
    end
  end
end
