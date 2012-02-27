Array.class_eval do
  def collect_key(key)
    collect { |item| item.kind_of?(Hash) ? item[key] : nil }
  end
end