require 'spec_helper'

describe Admin::ConversationsController do

  it 'recognizes and generates #index' do
    { get: 'admin/conversations/' }.should route_to(controller: 'admin/conversations', action: 'index')
  end

  it 'recognizes and generates #new' do
    { get: 'admin/conversations/new' }.should route_to(controller: 'admin/conversations', action: 'new')
  end

  it 'recoginzes and generates #edit' do
    { get: 'admin/conversations/1/edit' }.should route_to(controller: 'admin/conversations', action: 'edit', id: '1')
  end

  it 'recognizes and generates #show' do
    { get: 'admin/conversations/1' }.should route_to(controller: 'admin/conversations', action: 'show', id: '1')
  end

  it 'recognizes and generates #update' do
    { put: 'admin/conversations/1' }.should route_to(controller: 'admin/conversations', action: 'update', id: '1')
  end

  it 'recognizes and generates #create' do
    { post: 'admin/conversations/' }.should route_to(controller: 'admin/conversations', action: 'create')
  end

  it 'recognizes and generates #destroy' do
    { delete: 'admin/conversations/1' }.should route_to(controller: 'admin/conversations', action: 'destroy', id: '1')
  end

  describe '#toggle_staff_pick' do
    it 'recognizes and generates PUT route' do
      { put: 'admin/conversations/1/toggle_staff_pick' }.should route_to(controller: 'admin/conversations', action: 'toggle_staff_pick', id: '1')
    end

    it 'should not recognize or generate GET route' do
      { get: "/admin/conversations/1/toggle_staff_pick" }.should_not be_routable
    end
  end

  it 'recognizes and generates #update_order' do
    { post: 'admin/conversations/update_order' }.should route_to(controller: 'admin/conversations', action: 'update_order')
  end

end
