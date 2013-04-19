module RubyWallet
  class Accounts < Array

    attr_reader :wallet
    delegate :client, to: :wallet

    def with_balance
      self.detect { |account| account[:balance] > 0 }
    end

    def initialize(wallet)
      @wallet = wallet
      client.listaccounts.each do |account|
        self.push(Account.new(@wallet, account[0]))
      end
    end

    def new(name)
      if self.includes_account_name?(name)
        account = self.detect {|a| a[:name] == name}
      else
        account = RubyWallet::Account.new(wallet, name)
        self << account
      end
      account
    end

    def includes_account_name?(account_name)
      self.detect {|a| a[:name] == account_name}.present?
    end

    def where_account_name(account_name)
      self.detect {|a| a[:name] == account_name}
    end

    private

    def existing_accounts
      client.listaccounts.keys
    end

  end
end
