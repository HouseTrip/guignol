require 'logger'

module Guignol::Logger
  def logger
    @logger ||= ::Logger.new(logger_file).tap do |logger|
      logger.progname = 'guignol'
      logger.formatter = Formatter.new
    end
  end


  private

  class Formatter < ::Logger::Formatter
    Format = "[%s] %s: %s\n"

    def call(severity, time, progname, msg)
      Format % [time.strftime('%F %T'), severity, msg2str(msg)]
    end
  end


  def logger_file
    return File.open(ENV['GUIGNOL_LOG'] ,'a') if ENV['GUIGNOL_LOG'] 
    $stdout.tty? ? $stdout : File.open('/dev/null','w')  
  end

  Guignol.extend(self)
end