def bake_format(data, output, indent, start_line, end_line)
  indent_level = 0
  data.each_line.with_index do |l, index|
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

    if index.between?(start_line, end_line)
      l = (prefix + l.strip)
    end

    output.puts(l)
  end
  output.close
end
