require 'spikor_forge'
require 'puppet'
require 'puppet/module_tool/metadata'
require 'puppet/module_tool/modulefile'
require 'tempfile'
require 'json'

class SpikorForge::Module
  attr_reader :path, :uripath, :metadata

  def initialize(path, uri_root_path)
    @path = path
    @uripath = path[uri_root_path.chomp('/').length..-1].chomp('/')

    # Modulefiles are actually ruby code that should be evaluated.
    # So exctract it to a temporary file and evaluate.
    modulefile = Tempfile.new('foo')
    `tar -z -x -O --include '*/Modulefile' -f #{path} > #{modulefile.path}`
    @metadata = Puppet::ModuleTool::Metadata.new()
    Puppet::ModuleTool::ModulefileReader.evaluate(@metadata, modulefile.path)
    modulefile.close
    modulefile.unlink
  end

  def dependencies
    @metadata.dependencies.collect do |dep|
      # Due to Puppet issue #21749 we have to do some awkward accessing here
      [dep.instance_variable_get(:@full_module_name), dep.instance_variable_get(:@full_module_name) || '' ]
    end
  end

  def version
    @metadata.version
  end

  def username
    @metadata.username
  end

  def name
    @metadata.name
  end

  def full_module_name
    @metadata.full_module_name
  end

  def to_hash
    {
      'file'         => @uripath,
      'version'      => version,
      'dependencies' => dependencies,
    }
  end
end
