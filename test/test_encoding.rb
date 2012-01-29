# encoding: utf-8
require 'helper'
require 'memcached_mock'

describe 'Encoding' do
  describe 'using a live server' do
    it 'should support i18n content' do
      memcached(19999) do |dc|
        key = 'foo'
        bad_key = utf8 = 'ƒ©åÍÎ'

        assert dc.set(key, utf8)
        assert_equal utf8, dc.get(key)

        # keys must be ASCII
        assert_raises ArgumentError, /illegal character/ do
          dc.set(bad_key, utf8)
        end
      end
    end

    it 'should support content expiry' do
      memcached(19999) do |dc|
        key = 'foo'
        assert dc.set(key, 'bar', 1)
        assert_equal 'bar', dc.get(key)
        sleep 2
        assert_equal nil, dc.get(key)
      end
    end

    it 'should not allow non-ASCII keys' do
      memcached(19999) do |dc|
        key = 'fooƒ'
        assert_raises ArgumentError do
          dc.set(key, 'bar')
        end
      end
    end
  end
end
