module David::ETSI::Mandatory
  path = File.expand_path('../mandatory', __FILE__)
  Dir["#{path}/*.rb"].each { |file| require file }
end
