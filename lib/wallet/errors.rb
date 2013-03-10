module Wallet
  class StandardError < ::StandardError; end
  class InsufficientFunds < StandardError; end
end
