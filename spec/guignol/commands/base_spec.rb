require 'spec_helper'
require 'guignol/commands/base'

describe Guignol::Commands::Base do

  describe 'parsing arguments' do
    
    it 'should set all arguments before the first --named-argument as servers' do
       base = Guignol::Commands::Base.new(["server1","server2","--testarg"])
       base.servers.sort.should == ["server1","server2"]
     end

     it 'should set all arguments at the first --named-argment and after as args' do
       base = Guignol::Commands::Base.new(["server1","server2","--testarg","xyz"])
       base.args.sort.should == ["--testarg","xyz"]
     end
    
  end
  
  describe 'retrieving arguments' do
    
    it 'should return the value after the argumnet name' do
      base = Guignol::Commands::Base.new(["server1","server2","--test","1234","--testarg", "1234xyz"])
      base.arg_val("--testarg").should == "1234xyz"
    end 
    
    it 'should return nil if there is no value after the argument name' do
      base = Guignol::Commands::Base.new(["server1","server2","--testarg"])
      base.arg_val("--testarg").should be_nil
    end
    
    it 'should return nil if there is an argument name after this argument name' do
      base = Guignol::Commands::Base.new(["server1","server2","--testarg1","--testarg2"])
      base.arg_val("--testarg1").should be_nil
    end
    
    it 'should return true if the args contains the named arg' do
      base = Guignol::Commands::Base.new(["server1","server2","--testarg1","--testarg2"])
      base.arg?("--testarg1").should be_true
    end
    
    it 'should return false if the args contains the named arg' do
      base = Guignol::Commands::Base.new(["server1","server2","--testarg1","--testarg2"])
      base.arg?("--testarg3").should_not be_true
    end
    
  end
  
  describe 'required arguments' do
    
    class TestCommand < Guignol::Commands::Base
      ensure_args "--testme"
    end
    
    class Test2Command
    end
     
    it 'should raise an error if the required argument is not provided' do
      expect{
        TestCommand.new("server1")
      }.to raise_error(Guignol::Commands::Base::Error, "required argument --testme not found")
    end
    
    it 'should not raise an error if the required argument is provided' do
      expect{
        tc = TestCommand.new("server1", "--testme")
        tc.test
      }.to_not raise_error(Guignol::Commands::Base::Error, "required argument --testme not found")
    end
    
    it 'should not raise an error if no required aruments are provided' do
      expect{
        tc = TestCommand2.new("server1", "--testme")
        tc.test
      }.to_not raise_error(Guignol::Commands::Base::Error, "required argument --testme not found")
    end
    
  end
   
end
