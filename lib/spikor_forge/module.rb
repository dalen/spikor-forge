require 'spikor_forge'
require 'json'

class SpikorForge::Module
  attr_reader :path, :uripath, :metadata

  def initialize(path, uri_root_path)
    @path = path
    @uripath = path[uri_root_path.chomp('/').length..-1].chomp('/')

    @metadata = JSON.parse `tar -z -x -O --wildcards -f #{path} '*/metadata.json'`
  end

  def dependencies
    @metadata['dependencies'].collect do |dep|
      [dep['name'], dep['version_requirement'] || '' ]
    end
  end

  def version
    @metadata['version']
  end

  def name
    @metadata['name']
  end

  def to_hash
    {
      'file'         => @uripath,
      'version'      => version,
      'dependencies' => dependencies,
    }
  end
end
