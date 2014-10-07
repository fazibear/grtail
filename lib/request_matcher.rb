class RequestMatcher

  REGEXPS = {
    start_request: /^Started (?<method>[A-Z]+) "(?<path>[^"]+)" for (?<ip>[0-9.]+) at (?<time>.*)$/,
    end_request:   /^Completed (?<status>[0-9]+) OK in (?<time>[0-9.ms]+) \((?<info>.+)\)$/,
    request_data:  /^Processing by (?<controller>\S+)#(?<method>\S+) as (?<format>\S+)$/,
  }

  def initialize(options = {})
    @data = {}
    @matchers = options[:matchers]
  end

  def match(line)
    REGEXPS.each do |key, regexp|
      if match = line.match(regexp)
        send(key, match)
        break
      else
        #puts line.inspect
      end
    end
    @matchers.each do |matcher|
      if match = matcher.match(line)
        return unless @data[:start]
        @data[matcher.key] ||= []
        @data[matcher.key] << match
        break
      end
    end
  end

  def start_request(match)
    @data[:start] = true
    @data[:request_method] = match['method']
    @data[:request_path] = match['path']
    @data[:remote_ip] = match['ip']
    @data[:start_time] = match['time']
  end

  def request_data(match)
    return unless @data[:start]
    @data[:controller] = match['controller']
    @data[:controller_method] = match['method']
    @data[:response_format] = match['format']
  end

  def end_request(match)
    return unless @data[:start]
    @data[:response_status] = match['status']
    @data[:response_time] = match['time']
    @data[:response_info] = match['info']

    print_data
    @data = {}
  end

  def print_data
    puts "#{@data[:response_time].yellow} #{@data[:request_method]} #{@data[:request_path]} -> #{@data[:controller].light_green}##{@data[:controller_method].light_cyan}"

    @matchers.each do |matcher|
      matcher.print(@data[matcher.key])
    end
  end

end