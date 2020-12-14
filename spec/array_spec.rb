#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake
  describe 'Array' do
    it 'execute command passed as array' do
      Bake.startBake('steps/main', ['test3'])
      expect($mystring.include?('COMMAND1')).to be == true
    end
  end
end
