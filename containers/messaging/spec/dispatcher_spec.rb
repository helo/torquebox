require 'torquebox/messaging/dispatcher'

describe TorqueBox::Messaging::Dispatcher do

  # Fake MessageProcessor
  class Nothing; end

  # Easier than getting TorqueBox::Messaging::Topic on the load-path ;)
  class Topic
    def initialize(name)
      @name = name
    end
    def to_s
      @name
    end
  end

  it "should have correct message processor metadata" do

    dispatcher = TorqueBox::Messaging::Dispatcher.new do
      map 'Nothing', '/queues/not', :filter => "x=1"
      map Nothing, Topic.new('/topics/not'), 'filter' => 'whatever'
    end

    dispatcher.processors.should have(2).things

    p1 = dispatcher.processors.shift
    p1.ruby_class_name.should == 'Nothing'
    p1.ruby_require_path.should == 'nothing'
    p1.destination_name.should == '/queues/not'
    p1.message_selector.should == 'x=1'

    p2 = dispatcher.processors.shift
    p2.ruby_class_name.should == 'Nothing'
    p2.ruby_require_path.should be_nil
    p2.destination_name.should == '/topics/not'
    p2.message_selector.should == 'whatever'

  end

  context "naming" do
    it "should configure naming host and url" do
      dispatcher = TorqueBox::Messaging::Dispatcher.new(:naming_host => 'ahost', :naming_port => 1234) do
        map Nothing, Topic.new('/topics/not'), 'filter' => 'whatever'
      end

      dispatcher.send(:container)

      java.lang::System.getProperty('java.naming.provider.url').should eql('jnp://ahost:1234/')
    end

    it "should configure only naming host" do
      dispatcher = TorqueBox::Messaging::Dispatcher.new(:naming_host => 'somehost') do
        map Nothing, Topic.new('/topics/not'), 'filter' => 'whatever'
      end

      dispatcher.send(:container)

      java.lang::System.getProperty('java.naming.provider.url').should eql('jnp://somehost:1099/')
    end
  end
end
