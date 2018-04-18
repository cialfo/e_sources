require 'pbkdf2'
require 'base64'
require 'mcrypt'
module ESources
  # it will be used for basic authentication
  class Cryptographer

    IV = SecureRandom.hex.freeze

    def self.encrypt(message, key, base_64 = false)
      message = PHP.serialize(message)
      iv = IV
      cipher = Mcrypt.new(:rijndael_256, :cbc, key, iv, :zeros)
      message = cipher.encrypt(message)
      message = iv + message
      mac = pbkdf2(message, key)
      message += mac
      if base_64
        message = CGI.escape(Base64.encode64(message).gsub(/\n/,''))
                     .gsub('+', '%20')
      end
      message
    end

    def self.decrypt(message, key, base_64 = false)
      message = Base64.decode64(CGI.unescape(message)) if base_64
      cipher = Mcrypt.new(:rijndael_256, :cbc, key, IV, :zeros)
      iv = message[0..31] # extracct iv
      mac_length = message.length - 32
      em = message[mac_length..message.length]
      message = message[32..mac_length - 1]
      mac = pbkdf2(iv.to_s + message.to_s, key)
      puts 'mac did not match' if em != mac
      message = cipher.decrypt(message)
      PHP.unserialize(message)
    end

    def self.pbkdf2(salt,
                    password,
                    count = 1000,
                    key_length = 32,
                    algorithm = OpenSSL::Digest::SHA256)
      count = count.to_i.abs
      # validation
      return if count.to_i.zero?
      hash_length = algorithm.new.length
      block_count = (key_length / hash_length).ceil

      digest = OpenSSL::Digest.new('sha256')
      output = ''
      (1..block_count).each do |block|
        last = salt.to_s + [block].pack('N').to_s
        last = xorsum = OpenSSL::HMAC.digest(digest, password, last)
        (1..(count - 1)).each do
          xorsum ^= (last = OpenSSL::HMAC.digest(digest, password, last))
        end
        output += xorsum
      end
      output[0..(key_length - 1)]
    end
  end
end
