class QueryMatcher

  REGEXP = /^  \e\[1m\e\[3[56]m(?<model>\S+) Load \((?<time>[0-9.ms]+)\)\e\[0m  \e\[1m(?<query>.*)\e\[0m$/
  SQL_FORMATTER = AnbtSql::Formatter.new(AnbtSql::Rule.new)

  def key
    :queries
  end

  def match(line)
    if match = line.match(REGEXP)
      {
        model: match['model'],
        time: match['time'],
        query: match['query'],
      }
    end
  end

  def print(data)
    return unless data
    data.each do |query|
      puts
      puts "  #{query[:time].yellow} #{query[:model].light_cyan}"
      puts "    " + SQL_FORMATTER.format(query[:query])
    end
  end
end