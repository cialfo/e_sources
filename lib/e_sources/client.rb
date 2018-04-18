module ESources
  # it will be used to do remove communication
  class Client

    def self.get(endpoint, params={})
      begin
        response = RestClient.get endpoint, params
      rescue RestClient::ExceptionWithResponse => e
        response = e.response
      end
      parse(response)
    end

    def delete(endpoint, params={})
      begin
        response = RestClient.delete endpoint, params
      rescue RestClient::ExceptionWithResponse => e
        response = e.response
      end
      parse(response)
    end

    def self.post(endpoint, params={})
      begin
        response = RestClient.post endpoint, params
      rescue RestClient::ExceptionWithResponse => e
        response = e
      end
      parse(response)
    end

    def self.put(endpoint, params={})
      begin
        response = RestClient.put endpoint, params
      rescue RestClient::ExceptionWithResponse => e
        response = e.response
      end
      parse(response)
    end

    private


    def self.parse(response)
      JSON.parse(response)
    end

    def url(endpoint)
      "#{host}/#{endpoint}.json"
    end
  end
end
