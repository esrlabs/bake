module Bake

  class ProjectFilter

    def initialize(options)
      @@filterList = nil
      @@valid = nil
      @@options = options
    end

    def self.projects
      calcFilter_internal() if @@filterList.nil?
      return @@filterList
    end

    def self.is_valid?
      calcFilter_internal() if @@valid.nil?
      return @@valid
    end

    def self.localFile(str)
      return true if (not is_valid?) || (not @@options.qacfilefilter)
      projects.any? { |fil| str.include?(fil+"/") &&
        !str.include?(fil+"/test/") &&
        !str.include?(fil+"/mock/") &&
        !str.include?(fil+"/.qacdata/") &&
        !str.include?("/mergedIncludes") }
    end

    def self.writeFilter(filter)
      filter_filename = "#{@@options.qacdata}/filter.txt"
      File.open(filter_filename, "w+") do |f|
        filter.uniq!
        filter.delete_if { |f| (f.end_with? "/gtest") or (f.end_with? "/gmock") }
        f.puts(filter)
      end
    end

    def self.calcFilter_internal
      @@filterList = []
      filter_filename = "#{@@options.qacdata}/filter.txt"
      @@valid = File.exist?(filter_filename)
      if @@valid
        File.open(filter_filename, "r") do |f|
          f.each_line { |line| @@filterList << line.strip }
        end
      end
    end

  end

end
