module David
  MAJOR = 0
  MINOR = 4
  PATCH = 1
  SUFFIX = :pre

  VERSION = [MAJOR, MINOR, PATCH, SUFFIX].compact.join('.')
end
