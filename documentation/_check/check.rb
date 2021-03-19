STDOUT.sync = true

module Check
  class Documentation

    @@levels =
    {
      "="  => 1,
      "-"  => 2,
      "+"  => 3,
      "~"  => 4,
      "^"  => 5,
      "\"" => 6,
      "*" => 7
    }
    @@levels_inverted = @@levels.invert
    @@all_levels = Regexp.escape(@@levels.keys.join)

    def initialize()
      puts "Documentation style check"
      @totalFindings = 0
      @findingsForCurrentFile = 0
    end

    def addFinding(msg)
      @totalFindings += 1
      @findingsForCurrentFile += 1
      puts "  Finding: #{msg}"
    end

    def loadFile(rst_filename)
      @rst_filename = rst_filename
      @lines = File.readlines(@rst_filename)
      @findingsForCurrentFile = 0

      # find all headings
      @headings = []
      for i in (1..@lines.length-1)
        if @lines[i].rstrip.length >= @lines[i-1].rstrip.length
          @@levels.each do |hchar, hlevel|
            if /\A#{Regexp.escape(hchar)}+\z/ === @lines[i].rstrip
              @headings << {:line => i,:level => hlevel}
            end
          end
        end
      end
    end

    def checkHeadings()
      # calculate current mapping
      mapping = {}
      nextUnmapped = 1
      @headings.each do |heading|
        if !mapping.has_key?(heading[:level])
          mapping[heading[:level]] = nextUnmapped
          nextUnmapped += 1
        end
      end

      # checks
      for i in (0..@headings.length-1)
        hlev = @headings[i][:level]
        lnum = @headings[i][:line]

        # level check
        if hlev != mapping[hlev]
          addFinding("#{@rst_filename}, line #{lnum+1}: " +
             "heading must be #{@@levels_inverted[mapping[hlev]]} " +
             "instead of #{@@levels_inverted[hlev]}")
          @lines[lnum].gsub!(/[#{@@all_levels}]/, @@levels_inverted[mapping[hlev]])
        end

        # underline check
        lenText = @lines[lnum-1].rstrip.length
        lenUnderline = @lines[lnum].rstrip.length
        if lenUnderline > lenText # the other case is covered by Sphinx
          addFinding("#{@rst_filename}, line #{lnum+1}: title underline too long")
          @lines[lnum] = @lines[lnum][lenUnderline-lenText..-1]
        end
      end
    end

    MAX_CHARS = 40
    def checkModuleName()
      res = @rst_filename.scan(/.*\/([^\/]+)\/doc\/index.rst/) # mainpage is not under doc
      if res.length == 1
        moduleName = res[0][0][0,MAX_CHARS]
        if @headings.length > 0
          h = @headings[0]
          lnum = h[:line]
          title = @lines[lnum-1]
          if !title.start_with?(moduleName)
            if (/\A#{moduleName}/i).match(title)
              addFinding("#{@rst_filename}, line #{lnum}: module name has wrong case")
              @lines[lnum-1] = moduleName + title[moduleName.length..-1]
            else
              addFinding("#{@rst_filename}, line #{lnum}: module name not found")
              @lines[lnum-1] = moduleName + " - " + title
              @lines[lnum] = @lines[lnum][0]*(moduleName.length+3) + @lines[lnum]
            end
          end
          if @lines[lnum-1].length > (MAX_CHARS + 1) # +1 = \n
            addFinding("#{@rst_filename}, line #{lnum}: title too long")
            @lines[lnum-1] = @lines[lnum-1][0,MAX_CHARS] + "\n"
            @lines[lnum] = @lines[lnum][0,MAX_CHARS] + "\n"
          end
        else
          addFinding("#{@rst_filename}: no heading found")
          @lines = [modulName+"\n",(@@levels[0]*moduleName.length)+"\n"] + @lines
        end
      end
    end

    def checkTrailings()
      @lines.each_with_index do |l,i|
        lStripped = l.rstrip
        lStripped += "\n" if l.end_with?("\n")
        if l != lStripped
          addFinding("#{@rst_filename}, line #{i + 1}: trailing whitespaces found")
          @lines[i] = lStripped
        end
      end
    end

    def writeChangedData()
      if @findingsForCurrentFile > 0
        File.open(@rst_filename, "w") do |f|
          @lines.each { |l| f.write(l) }
        end
      end
    end

    def summary(fixInplace)
      if fixInplace && @totalFindings > 0
        puts "Findings fixed"
      end
      if !fixInplace && @totalFindings > 0
        puts "Hint: call 'make fix' to fix all findings automatically"
        exit -1
      end
    end

  end
end
