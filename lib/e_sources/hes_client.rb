module ESources
  # it will be responsible for all communication on the client side
  class HesClient
    attr_reader :hand_shake_url, :login_url, :create_user_url, :update_user_url, :delete_user_url,
                :list_user_url, :list_user_url, :list_dwya_results_url, :list_results_url

    def initialize(environment)
      raise Exceptions::InvalidEnvironment unless enviornments.include?(environment)
      api_url = environment_urls[environment.to_sym][:api_root_url]
      extension_root_url = environment_urls[environment.to_sym][:ext_root_url]
      @hand_shake_url = api_url + 'login'
      @login_url = extension_root_url
      @list_user_url = @create_user_url = api_url + 'sfGuardUserAPI.json'
      @delete_user_url = @update_user_url = api_url + 'sfGuardUserAPI/'
      @list_dwya_results_url = api_url + 'asPortDWYAREsultAPI.json'
      @list_results_url = api_url + 'asPortResultAPI.json'
      @delete_result_url = api_url + 'asPortResultAPI/'
    end

    def get_login_url(account_id, config_id, user_id, nonce,
                      prod_id = nil,
                      account_encrypted_hes_student_id = nil)
      url = "#{login_url}?accountId=#{account_id}"
      url += "&userId=#{user_id}&nonce=#{nonce}"
      url += "&prodId=#{prod_id}"     unless prod_id.blank?
      url += "&configId=#{config_id}" unless config_id.blank?
      unless account_encrypted_hes_student_id.blank?
        url += "&ssoStudentId=#{account_encrypted_hes_student_id}"
      end
      url
    end

    def power_on_self_test(string_to_encode, account_key)
      begin
        puts %q(*********   Power on Self Test ***********)
        puts "text to encode: #{string_to_encode}"
        puts "length: #{string_to_encode.length}"
        encrypted_string = Cryptographer.encrypt(string_to_encode,
                                               account_key,
                                               true)
        clear_text = Cryptographer.decrypt(encrypted_string, account_key, true)
        puts "un-encode: #{clear_text}, length: #{clear_text.length}"
        if string_to_encode != clear_text
          raise Exceptions::EncryptionError.new('mac not matched')
        end
        puts 'sucess: decryption is suscessfull'
      rescue StandardError => e
        puts "exception message => #{e.inspect}"
      end
    end

    def hand_shake(account_id, password, key_string)
      puts %q(handshake test)
      encrypted_encode_string = Cryptographer.encrypt(password, key_string, true)
      parameters = "accountId=#{account_id}&accountSsoPassword=#{encrypted_encode_string}"
      response_array = Client.post(hand_shake_url, parameters)
      unless response_array.has_key?('nonce')
        raise Exceptions::InvalidResponse.new(response_array)
      end
      nonce = response_array['nonce']
      Cryptographer.encrypt(nonce, key_string, true)
    end

    def create_user(account_id, nonce, non_empty_input_values)
      raise Exceptions::InvalidInputValues if non_empty_input_values.blank?
      content = non_empty_input_values.to_json
      parameters = "accountId=#{account_id}&"
      parameters += "nonce=#{nonce}&"
      parameters += "content=#{content}"
      Client.post create_user_url, parameters
    end

    def list_user(account_id, user_id, nonce)
      parameters = "id=#{user_id}&accountId=#{account_id}&nonce=#{nonce}"
      response = Client.get list_user_url + "?#{parameters}"
      response
    end

    def list_results(account_id, user_id, nonce, filters = {})
      parameters = "user_id=#{user_id}&accountId=#{account_id}&nonce=#{nonce}"
      filters.each do |key, value|
        parameters += "&#{key}=#{value}"
      end
      Client.get list_results_url+ "?#{parameters}"
    end

    def delete_result(account_id, result_id, nonce)
      delete_url = "#{delete_result_url}#{result_id}.json"
      parameters = "accountId=#{account_id}&nonce=#{nonce}"
      Client.delete delete_url, parameters
    end

    def delete_user(account_id, user_id, nonce)
      delete_url = "#{delete_user_url}#{user_id}.json"
      parameters = "accountId=#{account_id}&nonce=#{nonce}"
      Client.delete delete_url, parameters
    end

    def update_user(user_id, account_id, nonce, non_empty_input_values)
      update_url = "#{update_user_url}#{user_id}.json"
      content = non_empty_input_values.to_json
      parameters = "accountId=#{account_id}&nonce=#{nonce}&content=#{content}"
      Client.put update_url, parameters
    end

    private

    def enviornments
      %w[prod staging]
    end

    def environment_urls
      {
        prod: {
          api_root_url: 'https://api.humanesources.com/',
          ext_root_url: 'https://api.humanesources.com/ext.php/'
        },
        staging: {
          api_root_url: 'https://api.staging.humanesources.com/',
          ext_root_url: 'https://api.staging.humanesources.com/ext.php/'
        }
      }
    end
  end
end
