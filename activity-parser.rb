require "fit"
require 'yaml'
require 'pry'

Dir.foreach("ACTIVITY") do |in_file|
  next if in_file == '.' or in_file == '..'

  fit_file = Fit.load_file("ACTIVITY/" + in_file)

  records = fit_file.records.select{ |r| r.content.record_type != :definition }
                            .map{ |r| r.content }
                            .select{ |r| r[:raw_position_lat]}

  datetime = Time.at(records[0].raw_timestamp + 631065600)

  points = records.map{ |r| {"datetime"   => Time.at(r.raw_timestamp + 631065600),
                             "time"       => r.raw_timestamp - records[0].raw_timestamp,
                             "lat"        => r.raw_position_lat * 180.0 / 2**31,
                             "long"       => r.raw_position_long * 180.0 / 2**31,
                             "distance"   => r.raw_distance / 100,
                             "altitude"   => (r.raw_altitude / 5.0 - 500).round(1),
                             "speed"      => (r.raw_speed * 3.6 / 1000).round(1),
                             "heart_rate" => r[:raw_heart_rate] ? r.raw_heart_rate.to_i : 0,
                             "cadence"    => r[:raw_cadence] ? r.raw_cadence * 2 : 0}}

  front_matter = {"layout" => "map",
                  "title" => "Aktivität am " + datetime.strftime("%d.%m.%Y") + " um " + datetime.strftime("%k:%M"),
                  "date" => datetime,
                  "points" => points}

  File.open("_posts/" + datetime.strftime("%Y-%m-%d-%H-%M") + ".md", 'w') do  |out_file|
    out_file.puts(front_matter.to_yaml)
    out_file.puts("---")
    out_file.puts("Any comments on the run follow here.")
  end
end
