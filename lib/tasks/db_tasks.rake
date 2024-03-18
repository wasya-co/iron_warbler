
namespace :db do

  ## Date, Volume, Open, High, Low, Close
  desc 'import_stock symbol=GME path=./data/GME-test.csv'
  task import_stock: :environment do
    Iro::Datapoint.import_stock( symbol: ENV['symbol'], path: ENV['path'] )
  end

  desc 'create calendar mdb'
  task create_calendar: :environment do

    year = 2023
    d = "#{year}-01-01".to_date
    out = ""
    368.times do
      if d.strftime('%Y').to_i == year+1
        break
      end

      Iro::Date.create({ date: d.strftime('%Y-%m-%d') })
      print '.'

      d = d + 1.day
    end

  end

  desc 'create calendar sql'
  task create_calendar_sql: :environment do

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

  desc 'test datapoints'
  task create_test_datapoints: :environment do
    datapoint = Iro::Datapoint.create({
      date: '2023-12-28',
      created_at: '2023-12-28 01:00:00',
      kind: 'some-type',
      value: 115,
    })
    datapoint = Iro::Datapoint.create({
      date: '2023-12-28',
      created_at: '2023-12-28 02:00:00',
      kind: 'some-type',
      value: 116,
    })
    datapoint = Iro::Datapoint.create({
      date: '2023-12-30',
      created_at: '2023-12-30 01:00:00',
      kind: 'some-type',
      value: 117,
    })
    datapoint = Iro::Datapoint.create({
      date: '2023-12-30',
      created_at: '2023-12-30 02:00:00',
      kind: 'some-type',
      value: 118,
    })
  end

  desc 'test'
  task test: :environment do
    Iro::Datapoint.test
  end

end
