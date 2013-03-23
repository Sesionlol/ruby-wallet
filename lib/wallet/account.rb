module RubyWallet
  class Account
    attr_reader :wallet, :name
    delegate :client, to: :wallet

    def initialize(wallet, name)
      @wallet = wallet
      @name = name
      self.addresses.new
    end

    def addresses
      @addresses ||= Addresses.new(self)
    end

    def balance(min_conf=RubyWallet.config.min_conf)
      client.getbalance(self.name, min_conf)
    end

    def send_amount(amount, options={})
      if options[:to]
        options[:to] = options[:to].address if options[:to].is_a?(Address)
      else
        fail ArgumentError, 'address must be specified'
      end

      client.sendfrom(self.name,
                      options[:to],
                      amount,
                      RubyWallet.config.min_conf)
    rescue RestClient::InternalServerError => e
      parse_error e.response
    end

    def send_many(options={})
      client.sendmany(self.name,
                      options,
                      RubyWallet.config.min_conf)
    rescue RestClient::InternalServerError => e
      parse_error e.response
    end

    def move_to(amount, options={})
      to_account = RubyWallet.wallet.accounts.where_account_name(options[:to])
      if to_account
        to = to_account.name
      else
        fail ArgumentError, 'could not find account'
      end
      client.move(self.name, to, amount, RubyWallet.config.min_conf)
    end

    def total_received
      client.getreceivedbyaccount(self.name, RubyWallet.config.min_conf)
    end

    def ==(other_account)
      self.name == other_account.name
    end

    def recent_transactions(options={})
      count = options.delete(:limit) || 10
      client.listtransactions(self.name, count).map do |hash|
        Transaction.new self.wallet, hash
      end
    end

    def transactions(options={})
      client.listtransactions(self.name, 9999).map do |hash|
        Transaction.new self.wallet, hash
      end
    end

    private

    def parse_error(response)
      json_response = JSON.parse(response)
      hash = json_response.with_indifferent_access
      error = if hash[:error]
                case hash[:error][:code]
                when -6
                  InsufficientFunds.new("cannot send an amount more than what this account (#{self.name}) has")
                end
              end
      fail error if error
    end

  end
end
