require 'spec_helper'

describe Admin::IssuesController do

  it 'recognizes and generates #index' do
    { get: 'admin/issues/' }.should route_to(controller: 'admin/issues', action: 'index')
  end

  it 'recognizes and generates #edit' do
    { get: 'admin/issues/1/edit' }.should route_to(controller: 'admin/issues', action: 'edit', id: '1')
  end

  it 'recognizes and generates #new' do
    { get: 'admin/issues/new' }.should route_to(controller: 'admin/issues', action: 'new')
  end

  it 'recognizes and generates #show' do
    { get: 'admin/issues/1' }.should route_to(controller: 'admin/issues', action: 'show', id: '1')
  end

  it 'recognizes and generates #update' do
    { put: 'admin/issues/1' }.should route_to(controller: 'admin/issues', action: 'update', id: '1')
  end

  it 'recognizes and generates #create' do
    { post: 'admin/issues/' }.should route_to(controller: 'admin/issues', action: 'create')
  end

  it 'recognizes and generates #destroy' do
    { delete: 'admin/issues/1' }.should route_to(controller: 'admin/issues', action: 'destroy', id: '1')
  end

  it 'recognizes and generates #update_order' do
    { post: 'admin/issues/update_order' }.should route_to(controller: 'admin/issues', action: 'update_order')
  end

end
