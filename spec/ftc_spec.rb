#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "File TCS" do

  it 'after glob' do
    Bake.startBake("ftc/main", ["test_1", "-v2"])
    expect(($mystring.include?"a1.d -DB -o")).to be == true
    expect(($mystring.include?"a2.d -DA -o")).to be == true
    expect(($mystring.include?"a3.d -DA -o")).to be == true
    expect(($mystring.include?"a4.d -DA -o")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'before glob' do
    Bake.startBake("ftc/main", ["test_2", "-v2"])
    expect(($mystring.include?"a1.d -DA -o")).to be == true
    expect(($mystring.include?"a2.d -DB -o")).to be == true
    expect(($mystring.include?"a3.d -DB -o")).to be == true
    expect(($mystring.include?"a4.d -DB -o")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'different glob' do
    Bake.startBake("ftc/main", ["test_3", "-v2"])
    expect(($mystring.include?"a1.d -o")).to be == true
    expect(($mystring.include?"a2.d -DA -o")).to be == true
    expect(($mystring.include?"a3.d -DC -o")).to be == true
    expect(($mystring.include?"a4.d -o")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'before and after glob' do
    Bake.startBake("ftc/main", ["test_4", "-v2"])
    expect(($mystring.include?"a2.d -DC -o")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

end

end
