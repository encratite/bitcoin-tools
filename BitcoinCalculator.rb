require 'nil/http'

class BitcoinCalculator
  attr_reader :difficulty, :btcToUSDExchangeRate, :usdToEuroExchangeRange
  attr_reader :effectiveMillionsOfHashesPerSecond, :bitcoinsPerDay, :dailyIncome, :effectiveWattage, :energyConsumedDailyInKwh, :dailyExpenses, :dailyProfit, :powerExpensesRatio, :daysToBreakEven

  def initialize(configuration)
    @configuration = configuration
    loadDynamicData
    performCalculations
  end

  def useEuro
    return @configuration::Euro
  end

  def loadDynamicData
    @difficulty, @btcToUSDExchangeRate = extractHTTPNumber('http://bitcoincharts.com/markets/', /<td class="label">Difficulty<\/td><td>(\d+)<\/td>.*?<a href=".*?">mtgoxUSD<\/a>.*?<span class="sub">USD \(Liberty Reserve\)<\/span>.*?<\/td>.*?<td>((?:\d|\.)+)/m)
    if useEuro
      @usdToEuroExchangeRange = extractHTTPNumber('http://finance.yahoo.com/q?s=USDEUR=X', /<span id="yfs_l10_usdeur=x">((?:\d|\.)+)<\/span>/).first
    end
  end

  def extractHTTPNumber(url, pattern)
    puts "Downloading #{url}"
    data = Nil::httpDownload(url)
    if data == nil
      raise "Unable to retrieve #{url}"
    end
    match = pattern.match(data)
    if match == nil
      puts data.inspect
      raise "Unable to discover pattern in #{url}"
    end
    output = match[1..-1].map { |x| convertNumber(x) }
    return output
  end

  def convertNumber(input)
    if input.index('.') == nil
      return input.to_i
    else
      return input.to_f
    end
  end

  def performCalculations
    hoursPerDay = 24
    minutesPerHour = 60
    secondsPerMinute = 60
    secondsPerDay = hoursPerDay * minutesPerHour * secondsPerMinute
    @effectiveMillionsOfHashesPerSecond = @configuration::MillionsOfHashesPerSecond * (1 - @configuration::StaleRate)
    @bitcoinsPerDay = 50 * secondsPerDay / (1.0 / (2 ** 224 - 1)) / @difficulty * @effectiveMillionsOfHashesPerSecond * 1000 ** 2 / (2 ** 256)
    @dailyIncome = @bitcoinsPerDay * @btcToUSDExchangeRate * (1 - @configuration::PoolFeeRatio)
    if useEuro
      mtgoxSEPAFees = 0.02
      @dailyIncome *= @usdToEuroExchangeRange * (1 - mtgoxSEPAFees)
    end
    @effectiveWattage = @configuration::Wattage / @configuration::PsuEfficiency
    @energyConsumedDailyInKwh = @effectiveWattage / 1000.0 * hoursPerDay
    @dailyExpenses = @energyConsumedDailyInKwh * @configuration::ExpensesPerKWh
    @dailyProfit = @dailyIncome - @dailyExpenses
    @powerExpensesRatio = @dailyExpenses.to_f / @dailyIncome
    @daysToBreakEven = (@configuration::HardwareExpenses / @dailyProfit).ceil
  end

  def truncateValue(input)
    precision = 2
    factor = 10 ** precision
    return (input * factor).truncate.to_f / factor
  end
end
