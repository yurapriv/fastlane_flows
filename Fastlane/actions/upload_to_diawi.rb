module Fastlane
  module Actions
    module SharedValues
      UPLOAD_TO_DIAWI_GENERATED_LINK = :UPLOAD_TO_DIAWI_GENERATED_LINK
    end

    class UploadToDiawiAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:

        UI.message "PATH TO IPA = #{params[:path_to_ipa]}"
        UI.message "DIAWI TOKEN = #{params[:diawi_token]}"

        link = download_link_for_file(params[:path_to_ipa], params[:diawi_token])

        UI.message "GENERATED DIAWI LINK = #{link}"

        Actions.lane_context[SharedValues::UPLOAD_TO_DIAWI_GENERATED_LINK] = link
      end

      def self.download_link_for_file(path = '', d_token = '')
        @d_token = d_token
        if d_token.length == 0
          return 'ERROR: Diawi API token not provided'
        elsif path.length == 0
          return 'ERROR: Path to file not provided'
        end

        upload_response = upload_ipa_from_path(path)
        parsed_upload_response = JSON.parse(upload_response)

        result = 'NO RESULT'

        if (job_id = parsed_upload_response['job'])

          1.upto(5) do |n|
            puts "status request = #{n}"

            status_response = request_status_for_job_id(job_id)
            parsed_status_response = JSON.parse(status_response)

            if (status = parsed_status_response['status'])
              case status
              when 2000
                result = parsed_status_response['link']
                break
              when 2001
                puts 'WAIT: ' + parsed_status_response['message']
              when 4000
                result = 'ERROR: ' + parsed_status_response['message']
                break
              else
                result = "Unknown status: #{status}"
              end
            end

                sleep 1 # second
              end

            end

            result
          end

          def self.upload_ipa_from_path(path)
            puts "path = #{path}"
            result = `curl https://upload.diawi.com/ -F token='#{@d_token}' -F file=@#{path} -F find_by_udid=0 -F wall_of_apps=0`
            puts "result = #{result}"

            result
          end

          def self.request_status_for_job_id(job_id)
            puts "job_id = #{job_id}"
            status = `curl 'https://upload.diawi.com/status?token=#{@d_token}&job=#{job_id}'`
            puts "status = #{status}"

            status
          end


      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "A short description with <= 80 characters of what this action does"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "You can use this action to do cool things..."
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
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
        # Define the shared values you are going to provide
        # Example
        [
          ['UPLOAD_TO_DIAWI_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If you method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
["Your GitHub/Twitter Name"]
end

def self.is_supported?(platform)
        # you can do things like
        # 
        #  true
        # 
        #  platform == :ios
        # 
        #  [:ios, :mac].include?(platform)
        # 

        platform == :ios
      end
    end
  end
end
