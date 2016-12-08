def bake_format(data, output, indent)
  indent_level = 0
  data.each_line do |l|
    l.strip!
    opening = l.count('{')
    closing = l.count('}')
    old_indent_level = indent_level
    indent_level = indent_level + opening - closing

    prefix =
      if indent_level > old_indent_level
        indent * old_indent_level
      else
        indent * indent_level
      end
    output.puts((prefix + l).rstrip)
  end
  output.close
end
