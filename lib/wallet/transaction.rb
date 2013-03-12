module RubyWallet
  class Transaction

    attr_reader(:account,
                :address,
                :amount,
                :category,
                :confirmations,
                :id,
                :occurred_at,
                :received_at)

    def initialize(wallet, args)
      args = args.with_indifferent_access
      @wallet = wallet
      @account = wallet.accounts.new(args[:account])
      @id = args[:txid]
      @address = args[:address]
      @amount = args[:amount]
      @confirmations = args[:confirmations]
      @occurred_at = Time.at(args[:time])
      @received_at = Time.at(args[:timereceived])
      @category = args[:category]
    end

  end
end
