require 'spec_helper'
require_relative '../app'

describe 'ApplicationController' do
	include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  context 'User' do
    describe 'opens main page' do
      before do 
        get '/'
      end

      it 'should be a html response' do
        expect(last_response.content_type).to eq('text/html')
      end
    end

    describe 'fetches files on load' do 
      before do 
        get '/api/files'
      end

      it 'should be successful' do
        expect(last_response).to be_ok
      end

      it 'should be a json response' do
        expect(last_response.content_type).to eq('application/json')
      end
    end

    describe 'fetches files after open a directory' do 
      before do 
        get '/api/files?dir=/home/'
      end

      it 'should be successful' do
        expect(last_response).to be_ok
      end

      it 'should be a json response' do
        expect(last_response.content_type).to eq('application/json')
      end
    end
  end

  context 'Redis' do
    describe 'sets a value' do
      it 'should set a value' do
        dir_path = '/home/user/'
        hash = {param1: 'value1'}
        json = hash.to_json
        REDIS.set(dir_path, json)

        expect(JSON.parse(REDIS.get(dir_path))['param1']).to eq(hash[:param1])
      end
    end
  end
	
end
