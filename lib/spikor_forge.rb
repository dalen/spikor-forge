#!/usr/bin/env ruby

require 'sinatra/base'
require 'json'

class SpikorForge < Sinatra::Base

  configure do
    set :module_dir, '/var/lib/spikor-forge/modules'
    set :fallback_environment, 'production'
    enable :logging
  end

  # API request for a module
  get '/:environment/api/v1/releases.json' do
    modules = {}
    unprocessed = [params[:module]]
    while mod = unprocessed.shift
      next if modules[mod] # This module has already been added

      user, modname = mod.split '/'
      release_list = environment_modules(params[:environment], user, modname)
      if !release_list.empty?
        modules[mod] = release_list
        unprocessed += modules_dependencies(release_list)
      end
    end

    if modules.empty?
      status 410
      return { 'error' => "Module #{user}/#{modname} not found"}.to_json
    else
      modules.each_key do |m|
        modules[m] = modules[m].collect { |release| release.to_hash }
      end
      return modules.to_json
    end
  end

  # Serve the module itself
  get '*/modules/:environment/:user/:module/:file' do
    send_file File.join(settings.module_dir, params[:environment], params[:user], params[:module], params[:file])
  end

  # Returns a merged list of module releases for a module and environment
  def environment_modules(environment, user, modname)
    if params[:environment] == settings.fallback_environment
      list_modules params[:environment], user, modname
    else
      merge_module_lists(
        list_modules(params[:environment], user, modname),
        list_modules(settings.fallback_environment, user, modname))
    end
  end

  # From a list of modules get a list of modules (names) they depend on
  def modules_dependencies(modules)
    modules.collect { |m| m.dependencies.collect { |d| d.first } }.flatten.uniq
  end

  # List modules in a environment directory matching user and module
  def list_modules(environment, user, mod)
    require 'spikor_forge/module'

    dir = File.join(settings.module_dir, environment, user, mod)

    begin
      Dir.entries(dir).select do |e|
        e.match(/^#{Regexp.escape user}-#{Regexp.escape mod}-.*.tar\.gz$/)
      end.sort.reverse.collect do |f|
        path = File.join(dir, f)
        begin
          Module.new(path, settings.module_dir)
        rescue RuntimeError => e
          logger.error e.message
          nil
        end
      end.compact
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
