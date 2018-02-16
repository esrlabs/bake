#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "Ensure" do

  it 'end reached' do
    $endReached = true
    print "<END REACHED>"
  end

end

end