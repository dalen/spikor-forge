#!/usr/bin/env ruby

require 'sinatra/base'
require 'json'

class SpikorForge < Sinatra::Base

  configure do
    set :module_dir, File.join(settings.root, '..' , 'public')
    set :fallback_environment, 'production'
  end

  # API request for a module
  get '/:environment/api/v1/releases.json' do
    user, modname = params[:module].split '/'
    if params[:environment] == settings.fallback_environment
      modules = list_modules params[:environment], user, modname
    else
      modules = merge_module_lists(
        list_modules(params[:environment], user, modname),
        list_modules(settings.fallback_environment, user, modname))
    end
    if modules.empty?
      status 410
      return { 'error' => "Module #{user}/#{modname} not found"}.to_json
    else
      releases = modules.collect { |m| m.to_hash }
      return { params[:module] => releases }.to_json
    end
  end

  # Serve the module itself
  get '*/modules/:environment/:user/:module/:file' do
    send_file File.join(settings.module_dir, 'modules', params[:environment], params[:user], params[:module], params[:file])
  end

  # List modules in a environment directory matching user and module
  def list_modules(environment, user, mod)
    require 'spikor_forge/module'

    dir = File.join(settings.module_dir, 'modules', environment, user, mod)

    begin
      Dir.entries(dir).select do |e|
        e.match(/^#{Regexp.escape user}-#{Regexp.escape mod}-.*.tar\.gz$/)
      end.sort.reverse.collect do |f|
        path = File.join(dir, f)
        Module.new(path, settings.module_dir)
      end
    rescue Errno::ENOENT
      return []
    end
  end

  # Merge two lists of modules
  def merge_module_lists(primary, fallback)
    modules = primary
    fallback.each do |mod|
      modules << mod unless modules.index { |m| m.version == mod.version }
    end
    modules
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
