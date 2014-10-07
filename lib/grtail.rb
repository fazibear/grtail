require 'bundler'

Bundler.require(:default)

require_relative 'request_matcher'
require_relative 'matchers/query_matcher'

class GrTail
  def initialize(input)
    @input = input
  end

  def parse
    matcher = RequestMatcher.new(matchers: [
      QueryMatcher.new
    ])
    @input.each do |line|
      matcher.match(line)
    end
  end
end
