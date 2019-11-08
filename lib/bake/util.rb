require_relative 'model/metamodel_ext'
require_relative 'model/metamodel'
require 'set'
require_relative 'toolchain/colorizing_formatter'
require_relative '../common/exit_helper'
require_relative '../common/utils'

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
          o.match(/\A#{Regexp.escape(r)}\z/) || o.match(/\A#{r}\z/)
        rescue Exception => e
          Bake.formatter.printError(e.message, f)
          Bake::ExitHelper.exit(1)
        end
      }}
    end

    if f.add != ""
      Bake::Utils::flagSplit(f.add, false).each do |a|
        orgSplitted << a # allow duplicate flags # unless orgSplitted.any? { |o| o==a }
      end
    end

  end

  orgSplitted.join(" ")
end

def integrateToolchain(tcs, toolchain)
  return tcs unless toolchain

  tcs[:KEEP_FILE_ENDINGS] = @mainConfig.defaultToolchain.keepObjFileEndings
  tcs[:OUTPUT_DIR] = toolchain.outputDir if toolchain.outputDir != ""
  integrateLinker(tcs, toolchain.linker) if toolchain.respond_to?"linker"
  integrateArchiver(tcs, toolchain.archiver)
  toolchain.compiler.each do |c|
    integrateCompiler(tcs, c, c.ctype)
  end
  integrateDocu(tcs, toolchain.docu) if toolchain.docu
end

def integrateDocu(tcs, docu)
  tcs[:DOCU] = docu.name if docu.name != ""
end

def integrateLinker(tcs, linker)
  return tcs unless linker
  tcs[:LINKER][:COMMAND] = linker.command if linker.command != ""
  tcs[:LINKER][:LINK_ONLY_DIRECT_DEPS] = linker.onlyDirectDeps
  tcs[:LINKER][:PREFIX] = linker.prefix if linker.prefix != ""
  tcs[:LINKER][:FLAGS] = adjustFlags(tcs[:LINKER][:FLAGS], linker.flags)
  tcs[:LINKER][:LIB_PREFIX_FLAGS] = adjustFlags(tcs[:LINKER][:LIB_PREFIX_FLAGS], linker.libprefixflags)
  tcs[:LINKER][:LIB_POSTFIX_FLAGS] = adjustFlags(tcs[:LINKER][:LIB_POSTFIX_FLAGS], linker.libpostfixflags)
end

def integrateArchiver(tcs, archiver)
  return tcs unless archiver
  tcs[:ARCHIVER][:COMMAND] = archiver.command if archiver.command != ""
  tcs[:ARCHIVER][:PREFIX] = archiver.prefix if archiver.prefix != ""
  tcs[:ARCHIVER][:FLAGS] = adjustFlags(tcs[:ARCHIVER][:FLAGS], archiver.flags)
end

def integrateCompiler(tcs, compiler, type)
  return tcs unless compiler
  if compiler.respond_to?("command") && compiler.command != ""
    tcs[:COMPILER][type][:COMMAND] = compiler.command
  end
  if compiler.respond_to?("cuda") && compiler.command != ""
    tcs[:COMPILER][type][:CUDA] = compiler.cuda
  end
  if compiler.respond_to?("prefix") && compiler.prefix != ""
    tcs[:COMPILER][type][:PREFIX] = compiler.prefix
  end
  if compiler.respond_to?("fileEndings") && compiler.fileEndings && compiler.fileEndings.endings != ""
    tcs[:COMPILER][type][:SOURCE_FILE_ENDINGS] = compiler.fileEndings.endings.split(",").map{|e| e.strip}
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

def add_line_if_no_comment(array, str)
  s = str.split("#")[0].strip
  array << s unless s.empty?
end
