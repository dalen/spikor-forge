#! /usr/bin/env ruby

require 'spec_helper'
require 'spikor_forge/module'
require 'json'
require 'time'

describe SpikorForge::Module do
  it 'should extract the metadata if it is not already extracted' do
    file='module.tar.gz'
    metadata=file + '.metadata'
    expect(File).to receive(:exist?).with(metadata).and_return(false)
    SpikorForge::Module.any_instance.should_receive(:`).and_return('')
    SpikorForge::Module.any_instance.should_receive(:read_metadata).and_return({})

    SpikorForge::Module.new file, '/foo'
  end

  it 'should not extract the metadata if it is already extracted' do
    file='module.tar.gz'
    metadata=file + '.metadata'
    expect(File).to receive(:exist?).with(metadata).and_return(true)
    expect(File).to receive(:stat).with(file).and_return(double(:mtime => Time.now-1))
    expect(File).to receive(:stat).with(metadata).and_return(double(:mtime => Time.now))
    SpikorForge::Module.any_instance.should_not_receive(:`)
    SpikorForge::Module.any_instance.should_receive(:read_metadata).and_return({})

    SpikorForge::Module.new file, '/foo'
  end
end
