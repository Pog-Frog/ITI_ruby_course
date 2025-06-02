require 'date'

module Logger
  def log(log_type, message)
    timestamp = DateTime.now.strftime("%Y-%m-%d %H:%M:%S")
    File.open("app.logs", "a+") do |f|
      f.puts("#{timestamp} -- #{log_type.upcase} -- #{message}")
    end
  end
  
  def method_missing(method_name, *args, &block)
    if method_name.to_s.start_with?('log_')
      log_type = method_name.to_s.split('_', 2)[1]
      message = block_given? ? yield : args.first
      log(log_type, message)
    end
  end
  
  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.start_with?('log_') || super
  end
  
  def log_debug(message); log('debug', message); end
  def log_info(message); log('info', message); end
  def log_warning(message); log('warning', message); end
  def log_error(message); log('error', message); end
end

class User
  attr_accessor :name, :balance

  def initialize(name, balance)
    @name = name
    @balance = balance || 0  
  end
  
  def can_withdraw?(amount)
    @balance >= amount
  end
  
  def withdraw(amount)
    return false unless can_withdraw?(amount)
    @balance -= amount
    true
  end
  
  def deposit(amount)
    @balance += amount
    true
  end
  
  def to_s
    "#{@name} (Balance: $#{@balance})"
  end
end

class Transaction
  attr_accessor :user, :value
  
  def initialize(user, value)
    @user = user
    @value = value
  end
  
  def deposit?
    @value > 0
  end
  
  def withdrawal?
    @value < 0
  end
  
  def apply
    deposit? ? @user.deposit(@value) : @user.withdraw(-@value)
  end
  
  def description
    type = deposit? ? "deposit" : "withdrawal"
    amount = deposit? ? @value : -@value
    "#{type} of $#{amount} for #{@user.name}"
  end
  
  def to_s
    "Transaction: #{description}"
  end
end

class Bank
  def process_transactions(trans_arr, &block)
    raise "Method #{__method__} is abstract, please override"
  end
end

class CBABank < Bank
  include Logger
  attr_accessor :users
  
  def initialize(users)
    @users = users
  end

  def find_user_by_name(name)
    @users.find { |u| u.name == name }
  end

  def process_transactions(trans_arr, &block)
    transaction_summary = trans_arr.map do |t|
      "User #{t.user.name} transaction with value #{t.value}"
    end.join(", ")

    log_info("Processing Transactions #{transaction_summary}...")

    trans_arr.each do |t|
      bank_user = find_user_by_name(t.user.name)

      if bank_user.nil?
        message = "#{t.user.name} not exist in the bank!!"
        log_error("User #{t.user.name} transaction with value #{t.value} failed with message #{message}")
        yield(:failure, t, message) if block_given?
        next
      end

      if bank_user.balance + t.value < 0
        message = "Not enough balance"
        log_error("User #{t.user.name} transaction with value #{t.value} failed with message #{message}")
        yield(:failure, t, message) if block_given?
        next
      end

      bank_user.balance += t.value
      log_info("User #{t.user.name} transaction with value #{t.value} succeeded")
      
      if bank_user.balance == 0
        log_warning("#{t.user.name} has 0 balance")
      end
      
      yield(:success, t, nil) if block_given?
    end
  end
end


users = [
  User.new("Ali", 200),
  User.new("Peter", 500),
  User.new("Manda", 100)
]

out_side_bank_users = [
  User.new("Menna", 400)
]

transactions = [
  Transaction.new(users[0], -20),
  Transaction.new(users[0], -30),
  Transaction.new(users[0], -50),
  Transaction.new(users[0], -100),
  Transaction.new(users[0], -100),
  Transaction.new(out_side_bank_users[0], -100)
]

bank = CBABank.new(users)

bank.process_transactions(transactions) do |status, transaction, message|
  if status == :success
    puts "Call endpoint for success of User #{transaction.user.name} transaction with value #{transaction.value}"
  else
    puts "Call endpoint for failure of User #{transaction.user.name} transaction with value #{transaction.value} with reason #{message}"
  end
end

puts "\nBank users:"
bank.users.each { |user| puts user }