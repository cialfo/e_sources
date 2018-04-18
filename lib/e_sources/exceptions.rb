module ESources
  module Exceptions
    class InvalidEnvironment < StandardError; end
    class EncryptionError < StandardError; end
    class InvalidResponse < StandardError; end
    class InvalidInputValues < StandardError; end
  end
end