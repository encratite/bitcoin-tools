require_relative 'Configuration'
require_relative 'BitcoinCalculator'

def truncate(value)
  sprintf('%.2f', value)
end

calculator = BitcoinCalculator.new(Configuration)

puts "Hardware used: #{Configuration::HardwareDescription}."
puts "Hardware expenses: #{truncate(Configuration::HardwareExpenses)} #{Configuration::CurrencySymbol}."
puts "Hashing speed: #{Configuration::MillionsOfHashesPerSecond} Mhash/s."
puts "Difficulty: #{calculator.difficulty}"
puts "BTC to USD exchange rate: #{calculator.btcToUSDExchangeRate} USD/BTC"
if Configuration::Euro
  puts "USD to Euro exchange rate: #{calculator.usdToEuroExchangeRange} EUR/USD"
end
puts "Effective wattage: #{truncate(calculator.effectiveWattage)} W"
puts "Energy consumed per day: #{truncate(calculator.energyConsumedDailyInKWh)} kWh"
puts "Bitcoin income per day: #{truncate(calculator.bitcoinsPerDay)} BTC/day."
puts "Income per day: #{truncate(calculator.dailyIncome)} #{Configuration::CurrencySymbol}."
puts "Expenses per day: #{truncate(calculator.dailyExpenses)} #{Configuration::CurrencySymbol}."
puts "Profit per day: #{truncate(calculator.dailyProfit)} #{Configuration::CurrencySymbol}."
puts "Power expense ratio: #{truncate(calculator.powerExpensesRatio * 100)}%"
puts "Days to break even: #{calculator.daysToBreakEven} day(s)."
