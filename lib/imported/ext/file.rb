require 'imported/utils/utils'

class File

  SLASH = '/'

  def self.is_absolute?(filename)
    if Bake::Utils.old_ruby?
      filename[0] == 47 or filename[1] == 58 # 47 = /, 58 = :
    else
      filename[0] == SLASH or filename[1] == ':'
    end
  end

  # seems both are rel or both are abs in all cases
  def self.rel_from_to_project(from,to,endWithSlash = true)
    return nil if from.nil? or to.nil?
    
	toSplitted = to.split('/')
	fromSplitted = from.split('/')
	
	max = [toSplitted.length, fromSplitted.length].min
	
	return nil if max < 1
	
	i = 0

	# path letter in windows may be case different
  toIsWindowsAbs = false
	if toSplitted[0].length > 1 and fromSplitted[0].length > 1
      if Bake::Utils.old_ruby?
        toIsWindowsAbs = toSplitted[0][1] == 58
        i = 1 if toIsWindowsAbs and fromSplitted[0][1] == 58 and toSplitted[0][0].downcase == fromSplitted[0][0].downcase 
      else
        toIsWindowsAbs = toSplitted[0][1] == ':'
        i = 1  if toIsWindowsAbs and fromSplitted[0][1] == ':' and toSplitted[0][0].downcase == fromSplitted[0][0].downcase
      end	
	end
	
  if (toIsWindowsAbs and i==0)
    res = to
    res += "/" if endWithSlash 
    return res	  
  end
	
  while i < max
      break if toSplitted[i] != fromSplitted[i] 
	  i += 1
	end
	j = i
	
	res = []
	while i < fromSplitted.length
	  res << ".."
	  i += 1
	end
	
	while j < toSplitted.length
	  res << toSplitted[j]
	  j += 1
	end
	
	if res.length == 0
	  return ""
	end
	
	res = res.join('/')
	res += "/" if endWithSlash 
	res
  end

  
  def self.add_prefix(prefix, file)
    if not prefix or is_absolute?(file)
      file
    else
      prefix + file
    end
  end

end
