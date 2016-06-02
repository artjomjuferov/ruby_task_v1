require_relative 'checkout'

co = Checkout.new
ARGV.each {|item| co.scan item}
p co.total