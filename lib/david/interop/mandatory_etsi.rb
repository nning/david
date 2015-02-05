module David::Interop::MandatoryETSI
  path = File.expand_path('../mandatory_etsi', __FILE__)
  Dir["#{path}/*.rb"].each { |file| require file }
end
