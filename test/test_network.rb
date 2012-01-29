require 'helper'

describe 'Network' do
  describe 'assuming a bad network' do
    it 'should handle no server available' do
      assert_raises Dalli::RingError, :message => "No server available" do
        dc = Dalli::Client.new 'localhost:19123'
        dc.get 'foo'
      end
    end

    describe 'with a fake server' do
      it 'should handle connection reset' do
        memcached_mock(lambda {|sock| sock.close }) do
          assert_raises Dalli::RingError, :message => "No server available" do
            dc = Dalli::Client.new('localhost:19123')
            dc.get('abc')
          end
        end
      end

      it 'should handle malformed response' do
        memcached_mock(lambda {|sock| sock.write('123') }) do
          assert_raises Dalli::RingError, :message => "No server available" do
            dc = Dalli::Client.new('localhost:19123')
            dc.get('abc')
          end
        end
      end

      it 'should handle connect timeouts' do
        memcached_mock(lambda {|sock| sleep(0.6); sock.close }, :delayed_start) do
          assert_raises Dalli::RingError, :message => "No server available" do
            dc = Dalli::Client.new('localhost:19123')
            dc.get('abc')
          end
        end
      end

      it 'should handle read timeouts' do
        memcached_mock(lambda {|sock| sleep(0.6); sock.write('giraffe') }) do
          assert_raises Dalli::RingError, :message => "No server available" do
            dc = Dalli::Client.new('localhost:19123')
            dc.get('abc')
          end
        end
      end
    end
  end
end
