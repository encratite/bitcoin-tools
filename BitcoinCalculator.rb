require 'nil/http'

class BitcoinCalculator
  def initialize(configuration)
    @configuration = configuration
    loadDynamicData
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

  def profitPerDay
    hoursPerDay = 24
    minutesPerHour = 60
    secondsPerMinute = 60
    secondsPerDay = hoursPerDay * minutesPerHour * secondsPerMinute
    btcPerDay = 50 * secondsPerDay / (1.0 / (2 ** 224 - 1)) / @difficulty * @configuration::MillionsOfHashesPerSecond * 1000 ** 2 / (2 ** 256)
    income = btcPerDay * @btcToUSDExchangeRate * (1 - @configuration::PoolFeeRatio)
    if useEuro
      mtgoxSEPALoss = 0.02
      income *= @usdToEuroExchangeRange * (1 - mtgoxSEPALoss)
    end
    expenses = @configuration::Wattage / 1000.0 / @configuration::PsuEfficiency * @configuration::ExpensesPerKWh * hoursPerDay
    profit = income - expenses
    puts "#{expenses.to_f / income}"
    return truncateValue(profit)
  end

  def truncateValue(input)
    precision = 2
    factor = 10 ** precision
    return (input * factor).truncate.to_f / factor
  end

  def profitPerMonth
    return truncateValue(profitPerDay * 30.5)
  end
end
