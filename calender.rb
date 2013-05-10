require "date"

class Object
  def try(method, *args)
    __send__(method, *args) if respond_to?(method)
  end
end

class Calender
  # You can initilize this class with <#Date> or <#Time>
  # eg)
  #    Calender.new(Time.now)
  #    Calender.new(Date.new(2013, 1))
  def initialize(date=Date.now)
    @date = date === Date ? date : date.to_date
    
    @start_day = Date.new(@date.year, @date.month,  1)
    @end_day   = Date.new(@date.year, @date.month, -1)
  end

  def title
    @date.strftime("%B %Y")
  end

  def week_titles
    %w(Su Mo Tu We Th Fr Sa)
  end

  def each_week
    day = @start_day
    days_in_week = Array.new(7, nil)
    
    while(day <= @end_day)
      days_in_week[day.cwday - 1] = day
      
      if day.sunday?
        yield(days_in_week.dup)
        days_in_week.fill(nil)
      end
      
      day += 1
    end

    if days_in_week.any? { |day| !day.nil? }
      yield(days_in_week)
    end
  end
end

class StdoutRenderer
  def initialize(calender)
    @calender = calender
  end

  def render
    week_title = @calender.week_titles.join(" ")
    title      = @calender.title
    max_length = [week_title.size, title.size].max
    
    puts title.center(max_length)
    puts week_title.center(max_length)

    @calender.each_week do |week|
      puts "%2s %2s %2s %2s %2s %2s %2s" % week.map { |date| date.try(:day).to_s }
    end
  end
end

class HtmlRenderer
  def initialize(calender)
    @calender = calender
  end

  HTML = <<-EOF
<html>
  <head>
    <style type="text/css">
      table {
        font-size: 12px;
      }

      td {
        text-align: right;
      }
    </style>
  </head>
  <body>
    <h5><%= @calender.title %></h5>
    <table>
      <thead>
        <tr>
          <% @calender.week_titles.each do |week_title| -%>
          <th><%= week_title %></th>
          <% end -%>
        </tr>
      </thead>
      <tbody>
        <% @calender.each_week do |week| -%>
          <tr>
          <% week.each do |day| -%>
            <td><%= day.try(:day) %></td>
          <% end -%>
          <tr/>
        <% end -%>
      </tbody>
    </table>
  </body>
</html>
  EOF

  def render
    require "erb"
    ERB.new(HTML, nil, "-").result(binding)
  end
end

if __FILE__ == $PROGRAM_NAME
  StdoutRenderer.new(Calender.new(Date.new(2013, 4))).render
  open("#{File.expand_path("../", __FILE__)}/sample.html", "w") { |io| io.write(HtmlRenderer.new(Calender.new(Time.now)).render) }  
end

