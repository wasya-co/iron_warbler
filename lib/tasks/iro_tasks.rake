
namespace :db do

  desc 'create calendar'
  task :create_calendar => :environment do

    year = 2023
    d = "#{year}-01-01".to_date
    out = ""
    368.times do
      if d.strftime('%Y').to_i == year+1
        break
      end
      out = "#{out} ('#{d.strftime '%Y-%m-%d'}'),"
      d = d + 1.day
    end
    out = out[0...out.length-1]
    out = "
    INSERT INTO
      dates (date)
    VALUES
      #{out} ;"
    File.write("/opt/tmp/#{year}_calendar.sql", out)
    `mv /opt/tmp/#{year}_calendar.sql doc/`

  end
end
