
namespace :iwa do

  desc '2022-11-30, iwa run'
  task run: :environment do
    Iwa::Runner.run
  end

end
