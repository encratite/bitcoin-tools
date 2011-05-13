require_relative 'Configuration'
require_relative 'BitcoinCalculator'

calculator = BitcoinCalculator.new(Configuration)
daysToBreakEven = (Configuration::HardwareExpenses / calculator.profitPerDay).ceil
hardwareString = "Hardware used: #{Configuration::HardwareDescription}."
expensesString = "Hardware expenses: #{Configuration::HardwareExpenses} #{Configuration::CurrencySymbol}."
speedString = "Hashing speed: #{Configuration::MillionsOfHashesPerSecond} Mhash/s."
perDayString = "Profit per day: #{calculator.profitPerDay} #{Configuration::CurrencySymbol}."
perMonthString = "Profit per month: #{calculator.profitPerMonth} #{Configuration::CurrencySymbol}."
breakEvenString = "Days to break even: #{daysToBreakEven} day(s)."
strings = [hardwareString, expensesString, speedString, perDayString, perMonthString, breakEvenString]
puts strings.join(' ')
