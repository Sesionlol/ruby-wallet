module RubyWallet
  class Wallet

    def initialize(config={})
      @config = config
    end

    def accounts
      @accounts ||= Accounts.new(self)
    end

    def recent_transactions(options={})
      count = options.delete(:limit) || 10
      client.listtransactions(nil, count).map do |hash|
        Transaction.new self, hash
      end
    end

    def encrypt(passphrase)
      client.encrypt(passphrase)
    end

    def unlock(passphrase, timeout = 20)
      client.unlock(passphrase, timeout)
    end

    def lock
      client.lock
    end

    private
    def client
      @client ||= Bitcoin::Client.new(@config[:username],
                                      @config[:password],
                                      @config.slice(:port))
    end
  end
end
