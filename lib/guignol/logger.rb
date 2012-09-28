require 'logger'

module Guignol::Logger
  def logger
    @logger ||= ::Logger.new(logger_file).tap do |logger|
      logger.progname = 'guignol'
    end
  end


  private


  def logger_file
    return File.open(path,'a') if path = ENV['GUIGNOL_LOG'] 
    $stdout.tty? ? $stdout : File.open('/dev/null','w')  
  end

  Guignol.extend(self)
end