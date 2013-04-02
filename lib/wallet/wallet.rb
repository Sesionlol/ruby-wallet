module RubyWallet
  class Wallet

    def initialize(config={})
      @config = config
    end

    def balance(account = nil)
      client.balance(account)
    end

    def total_received(account = "*")
      client.getreceivedbyaccount(account, RubyWallet.config.min_conf)
    end

    def accounts
      @accounts ||= Accounts.new(self)
    end

    def transactions(account = "*", from = 0, to)
      client.listtransactions(account, to, from).map do |hash|
        Transaction.new self, hash
      end
    end

    def encrypt(passphrase)
      client.encrypt(passphrase)
    end

    def unlock(passphrase, timeout = 20, &block)
      client.unlock(passphrase, timeout)
      if block
        block.call
        client.lock
      end
    end

    def lock
      client.lock
    end

    def validate_address(bitcoinaddress)
      client.validateaddress(bitcoinaddress)
    end

    private
    def client
      @client ||= Bitcoin(@config[:username],
                          @config[:password],
                          :port => (@config[:port] || "8332"),
                          :host => (@config[:host] || "localhost"),
                          :ssl => (@config[:ssl] || false))
    end
  end
end
