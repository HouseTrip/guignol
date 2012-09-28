module Guignol
  def env
    @env ||= Env.new
  end

  private

  class Env
    def initialize
      @env = ENV['GUIGNOL_ENV'] || 'development'
    end

    def test?
      @env == 'test'
    end
  end

  Guignol.extend(self)
end