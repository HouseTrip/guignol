
module Hash::MapToHash
  # Update all values in a hash.
  # Passes +key,value+ pairs to its block, replaces the pair 
  # with the block's return value.
  def map_to_hash(options = {}, &block)
    Hash.new.tap do |result|
      self.each_pair do |key,value|
        value = _deep_convert(value, block) if options[:deep]
        new_key, new_value = block.call(key, value)
        result[new_key] = new_value
      end
    end
  end

  private

  def _deep_convert(value, block)
    case value
    when Hash
      value.map_to_hash({ :deep => true }, &block)
    when Array
      value.map { |item| _deep_convert(item, block) }
    else
      value
    end
  end

  Hash.send(:include, self)
end

