require 'bake/model/metamodel_ext'
require 'bake/model/metamodel'
require 'set'
require 'bake/toolchain/colorizing_formatter'
require 'common/exit_helper'
require 'common/utils'


def remove_empty_strings_and_join(a, j=' ')
  return a.reject{|e|e.to_s.empty?}.join(j)
end

def adjustFlags(orgStr, flags)
  orgSplitted = Bake::Utils::flagSplit(orgStr, false)

  flags.each do |f|
    if f.overwrite != ""
      orgSplitted = Bake::Utils::flagSplit(f.overwrite, false)
    end
    
    if f.remove != ""
      rmSplitted = Bake::Utils::flagSplit(f.remove, false)
      orgSplitted.delete_if {|o| rmSplitted.any? { |r|
        begin
          o.match("\\A"+r+"\\Z")
        rescue Exception => e
          Bake.formatter.printError(e.message, f)
          Bake::ExitHelper.exit(1)
        end
      }}
    end
    
    if f.add != ""
      Bake::Utils::flagSplit(f.add, false).each do |a|
        orgSplitted << a unless orgSplitted.any? { |o| o==a }
      end
    end
    
  end
  
  orgSplitted.join(" ")
end

def integrateToolchain(tcs, toolchain)
  return tcs unless toolchain
  
  tcs[:OUTPUT_DIR] = toolchain.outputDir if toolchain.outputDir != ""
  integrateLinker(tcs, toolchain.linker) if toolchain.respond_to?"linker"
  integrateArchiver(tcs, toolchain.archiver)
  toolchain.compiler.each do |c| 
    integrateCompiler(tcs, c, c.ctype)
  end
  integrateLintPolicy(tcs, toolchain.lintPolicy)
  integrateDocu(tcs, toolchain.docu) if toolchain.docu
end  

def integrateLintPolicy(tcs, policies)
  policies.each do |d|
    tcs[:LINT_POLICY] << d.name
  end
end

def integrateDocu(tcs, docu)
  tcs[:DOCU] = docu.name if docu.name != ""
end

def integrateLinker(tcs, linker)
  return tcs unless linker
  tcs[:LINKER][:COMMAND] = linker.command if linker.command != ""
  tcs[:LINKER][:FLAGS] = adjustFlags(tcs[:LINKER][:FLAGS], linker.flags) 
  tcs[:LINKER][:LIB_PREFIX_FLAGS] = adjustFlags(tcs[:LINKER][:LIB_PREFIX_FLAGS], linker.libprefixflags) 
  tcs[:LINKER][:LIB_POSTFIX_FLAGS] = adjustFlags(tcs[:LINKER][:LIB_POSTFIX_FLAGS], linker.libpostfixflags) 
end

def integrateArchiver(tcs, archiver)
  return tcs unless archiver
  tcs[:ARCHIVER][:COMMAND] = archiver.command if archiver.command != ""
  tcs[:ARCHIVER][:FLAGS] = adjustFlags(tcs[:ARCHIVER][:FLAGS], archiver.flags) 
end

def integrateCompiler(tcs, compiler, type)
  return tcs unless compiler
  if compiler.respond_to?"command"
    tcs[:COMPILER][type][:COMMAND] = compiler.command if compiler.command != ""
  end
  tcs[:COMPILER][type][:FLAGS] = adjustFlags(tcs[:COMPILER][type][:FLAGS], compiler.flags)
  compiler.define.each do |d|
    tcs[:COMPILER][type][:DEFINES] << d.str unless tcs[:COMPILER][type][:DEFINES].include? d.str
  end
end

def integrateCompilerFile(tcs, compiler)
  [:CPP, :C, :ASM].each do |t|
    integrateCompiler(tcs, compiler, t)
  end
  return tcs
end


def sanitize_filename(filename)
  filename.strip do |name|
   # NOTE: File.basename doesn't work right with Windows paths on Unix
   # get only the filename, not the whole path
   name.gsub! /^.*(\\|\/)/, ''

   # Finally, replace all non alphanumeric, underscore 
   # or periods with underscore
   # name.gsub! /[^\w\.\-]/, '_'
   # Basically strip out the non-ascii alphabets too 
   # and replace with x. 
   # You don't want all _ :)
   name.gsub!(/[^0-9A-Za-z.\-]/, 'x')
  end
end

def searchRootsFile(dir)
  rootsFile = dir+"/roots.bake"
  return rootsFile if File.exist?(rootsFile)
  
  parent = File.dirname(dir)
  return searchRootsFile(parent) if parent != dir

  return nil
end

def calc_def_roots(dir)
  def_roots = []
  rootsFile = searchRootsFile(dir)
  if (rootsFile)
    File.open(rootsFile).each do |line|
      line = line.split("#")[0].strip.gsub(/[\\]/,'/')
      if line != ""
        if File.is_absolute?(line)
          def_roots << line
        else
          def_roots << File.dirname(rootsFile) + "/" + line
        end
      end
    end
  else
    def_roots << File.dirname(dir)
  end
  def_roots
end

def add_line_if_no_comment(array, str)
  s = str.split("#")[0].strip
  array << s unless s.empty?
end
