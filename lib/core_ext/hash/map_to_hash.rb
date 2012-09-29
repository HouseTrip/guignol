
module Hash::MapToHash
  # Update all values in a hash.
  # Passes +key,value+ pairs to its block, replaces the old value 
  # with the block's return value.
  def map_to_hash(options = {}, &block)
    self.dup.update(self) do |key,value|
      value = _deep_convert(value, block) if options[:deep]
      block.call(key, value)
    end
  end

  private

  def _deep_convert(value, block)
    case value
    when Hash
      value.map_to_hash({ :deep => true }, block)
    when Array
      value.map { |item| _deep_convert(item, block) }
    else
      value
    end
  end

  Hash.send(:include, self)
end

