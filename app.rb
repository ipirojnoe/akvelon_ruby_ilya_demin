#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/base'
require 'sinatra/reloader'
require 'filesize'
require 'redis'
require 'uri'

configure do
  REDISTOGO_URL = "redis://localhost:6379/"
  uri = URI.parse(REDISTOGO_URL)
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

before do
	@error = ''
end

namespace '/api' do
  before do
    content_type :json
  end

  get '/files' do
    if params['dir'].nil?
      current_directory = "#{ENV['dir']}/"
    else
      current_directory = "#{params['dir']}/"
    end

    directory_cache = REDIS.get(current_directory)

    if directory_cache.nil?
      last_directory = current_directory.split('/')[0..-2].join('/')

      directory = { directories: [], files: [], current_directory: current_directory, last_directory: last_directory }

      Dir["#{current_directory}*"].each do |directory_object|
        name = directory_object.split('/').last
        size = Filesize.from("#{File.size(directory_object)} B").pretty
        updated_at = File.ctime(directory_object)

        if File.directory?(directory_object)
          directory[:directories] << { name: name, size: '-', updated_at: updated_at.strftime("%d/%m/%Y %H:%M") }
        end

        if File.file?(directory_object)
          directory[:files] << { name: name, size: size, updated_at: updated_at.strftime("%d/%m/%Y %H:%M") }
        end
      end

      directory_json = directory.to_json
      REDIS.set(current_directory, directory_json)

      status 200
      directory_json
    else
      status 200
      directory_cache
    end
  end
end

get '/' do
	erb :directory
end
