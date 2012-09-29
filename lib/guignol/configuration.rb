# Copyright (c) 2012, HouseTrip SA.
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met: 
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer. 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution. 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# The views and conclusions contained in the software and documentation are those
# of the authors and should not be interpreted as representing official policies, 
# either expressed or implied, of the authors.

require 'active_support'
require 'active_support/core_ext/enumerable'
require 'guignol'

module Guignol::Configuration

  def configuration
    @configuration ||= load_config_file
  end

  private

  def config_file_path
    @config_file_path ||= [
      Pathname.new(ENV['GUIGNOL_YML'] || '/var/nonexistent'),
      Pathname.new('guignol.yml'),
      Pathname.new('config/guignol.yml'),
      Pathname.new(ENV['HOME']).join('.guignol.yml')
    ].find(&:exist?)
  end

  # Load the config hash for the file, converting old (v0.2.0) Yaml config files.
  def load_config_file
    return {} if config_file_path.nil?
    data = YAML.load(config_file_path.read)
    return data unless data.kind_of?(Array)

    # Convert the toplevel array to a hash. Same for arrays of volumes.
    Guignol.logger.warn "Configuration file '#{config_file_path}' uses the old array format. Trying to load it."
    raise "Instance config lacks :name" unless data.collect_key(:name).all?
    result = data.index_by { |item| item.delete(:name) }
    result.each_pair do |name, config|
      next unless config[:volumes]
      raise "Volume config lacks :name" unless config[:volumes].collect_key(:name).all?
      config[:volumes] = config[:volumes].index_by { |item| item.delete(:name) }
    end

    return result
  end

  Guignol.extend(self)
end
