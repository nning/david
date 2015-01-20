module David
  MAJOR = 0
  MINOR = 3
  PATCH = 1
  SUFFIX = :pre

  VERSION = [MAJOR, MINOR, PATCH, SUFFIX].compact.join('.')
end
