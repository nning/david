module David::ETSI::Optional
  path = File.expand_path('../optional', __FILE__)
  Dir["#{path}/*.rb"].each { |file| require file }
end
