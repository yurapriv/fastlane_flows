module Fastlane
  module Actions
    module SharedValues
      UPLOAD_TO_DIAWI_GENERATED_LINK = :UPLOAD_TO_DIAWI_GENERATED_LINK
    end

    class UploadToDiawiAction < Action
      def self.run(params)

        UI.message "PATH TO IPA = #{params[:path_to_ipa]}"
        UI.message "DIAWI TOKEN = #{params[:diawi_token]}"

        link = download_link_for_file(params[:path_to_ipa], params[:diawi_token])


        UI.message "GENERATED DIAWI LINK = #{link}"

        Actions.lane_context[SharedValues::UPLOAD_TO_DIAWI_GENERATED_LINK] = link
      end

      def self.download_link_for_file(path = '', token = '')

        @token = token
        @path = path

        result = {}
        result[:link] = 'NO LINK'
        result[:message] = 'NO MESSAGE'
        result[:success] = 0

        if @token.length == 0
          result[:message] = 'ERROR: Diawi API token not provided'
          return result
        elsif @path.length == 0
          result[:message] = 'ERROR: Path to file not provided'
          return result
        end

        upload_response = upload_ipa_from_path(@path)
        if upload_response == nil
          result[:message] = 'ERROR ON UPLOAD'
          return result
        end

        if (job_id = upload_response['job'])
          link = get_download_link(job_id)
          if link =~ URI.regexp
            result[:success] = 1
            result[:link] = link
          end
        end

        result
      end

      def self.get_download_link(job)

        download_link = 'NO LINK'

        1.upto(10) do |status_request_count|
          puts "status request = #{status_request_count}"

          status_response = request_status_for_job_id(job)

          if (status = status_response['status'])

            case status
              when 2000
                download_link = status_response['link']
                break
              when 2001
                puts "WAIT: #{status_response['message']}"

              when 4000
                download_link = "ERROR: #{status_response['message']}"
                break
              else
                download_link = "Unknown status: #{status}"
                break
            end

          end

          sleep 1

        end

        download_link
      end

      def self.upload_ipa_from_path(path)
        upload_response = `curl https://upload.diawi.com/ -F token='#{@token}' -F file=@#{path} -F find_by_udid=0 -F wall_of_apps=0`
        puts "upload_response = #{upload_response}"
        if is_json?(upload_response)
          return JSON.parse(upload_response)
        end
        nil
      end

      def self.request_status_for_job_id(job_id)
        status_response = `curl 'https://upload.diawi.com/status?token=#{@token}&job=#{job_id}'`
        puts "status_response = #{status_response}"
        if is_json?(status_response)
          return JSON.parse(status_response)
        end
        nil
      end

      def self.is_json?(string)
        begin
          JSON.parse(string)
        rescue JSON::ParserError => e
          return false
        end
        true
      end


      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "This action can upload .ipa file to www.diawi.com and return upload link"
      end

      def self.details
        ""
      end

      def self.available_options
        [
            FastlaneCore::ConfigItem.new(key: :diawi_token,
                                         env_name: "FL_UPLOAD_TO_DIAWI_DIAWI_TOKEN",
                                         description: "Diawi token",
                                         is_string: true, # true: verifies the input is a string, false: every kind of value
                                         default_value: ''), # the default value if the user didn't provide one

            FastlaneCore::ConfigItem.new(key: :path_to_ipa,
                                         env_name: "FL_UPLOAD_TO_DIAWI_PATH_TO_IPA",
                                         description: "Path to ipa that needs to be uploaded",
                                         is_string: true, # true: verifies the input is a string, false: every kind of value
                                         default_value: '') # the default value if the user didn't provide one
        ]
      end

      def self.output

      end

      def self.return_value

      end

      def self.authors
        ["https://github.com/yurapriv"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
