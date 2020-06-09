#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'
require 'json'

module Bake

  refData = [
    {
      "module" => "spec/testdata/depOverview/main",
      "dependencies" => [
        "spec/testdata/depOverview/proj1",
        "spec/testdata/depOverview/proj2",
        "spec/testdata/depOverview/proj3",
        "spec/testdata/depOverview/proj4/include"
      ]
    },
    {
      "module" => "spec/testdata/depOverview/proj1",
      "dependencies" => [
        "spec/testdata/depOverview/proj2",
        "spec/testdata/depOverview/proj3"
      ]
    },
    {
      "module" => "spec/testdata/depOverview/proj2",
      "dependencies" => [
        "spec/testdata/depOverview/proj1/include2",
        "spec/testdata/depOverview/proj3"
      ]
    },
    {
      "module" => "spec/testdata/depOverview/proj3",
      "dependencies" => [
        "spec/testdata/depOverview/proj1/include",
        "spec/testdata/depOverview/proj1/include2"
      ]
    }
  ]
  
describe "Dependency Overview" do

  it 'suppress comments' do
    str = `ruby bin/bakery -m spec/testdata/depOverview/main test -Z dep-overview=test.json`
    file = File.read('test.json')
    jsonData = JSON.parse(file)

    expect(jsonData.length).to be == refData.length
    refData.each do |refElement|
      refModule = refElement["module"]
      refDeps = refElement["dependencies"]

      jsonMlist = jsonData.select{|d| d["module"].end_with?(refModule)}
      expect(jsonMlist.length).to be == 1

      jsonDeps = jsonMlist[0]["dependencies"]
      expect(jsonDeps.length).to be == refDeps.length
      refDeps.each do |refD|
        jsonDList = jsonDeps.select{|jsonD| jsonD.end_with?(refD)}
        expect(jsonDList.length).to be == 1
      end
      
    end
  end

end

end
