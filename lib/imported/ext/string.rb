class String
  def remove_from_start(text)
    if index(text) == 0
      self[text.size..-1]
    else
      self
    end
  end
end
