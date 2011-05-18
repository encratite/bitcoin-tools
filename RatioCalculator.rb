require 'nil/file'

class RatioCalculator
  def initialize(mtgoxHistoryPath, difficultyHistoryPath)
    loadMtgoxData(mtgoxHistoryPath)
    loadDifficultyData(difficultyHistoryPath)
  end

  def loadMtgoxData(mtgoxHistoryPath)
    mtgoxHistoryString = Nil.readFile(mtgoxHistoryPath)
    if mtgoxHistoryString == nil
      raise 'Unable to load the MtGox history'
    end

    mtgoxHistoryString.gsub!(':', '=>')
    mtgoxHistory = eval(mtgoxHistoryString)
    mtgoxOpen = mtgoxHistory['plot'].map { |x| x[0] }
    start = mtgoxHistory['start']
    period = mtgoxHistory['period']
  end

  def loadDifficultyData(difficultyHistoryPath)
    difficultyHistoryString = Nil.readFile(difficultyHistoryPath)
    if difficultyHistoryString == nil
      raise 'Unable to read difficulty history'
    end
    marker = 'START DATA'
    offset = difficultyHistoryString.index(marker)
    if offset == nil
      raise 'Unable to locate the start of the data section in the difficulty history'
    end
    offset += marker.size
    lines = difficultyHistoryString[offset..-1].trim.split("\n")
    return lines.map do |line|
      values = eval("[#{line}]")
      timestamp = values[1]
      difficulty = values[4]
    end
  end
end
