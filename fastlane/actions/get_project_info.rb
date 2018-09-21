module Fastlane
  module Actions
    module SharedValues
      PROJECT_NAME = :PROJECT_NAME
      XCODEPROJ = :XCODEPROJ
      INFO_PLIST = :INFO_PLIST
    end

    class GetProjectInfoAction < Action
      def self.run(params)
        xcodeproj = params[:xcodeproj]
        if xcodeproj == nil
          if projects = Dir["*.xcodeproj"]
            xcodeproj = projects.first
          end
        end
        if xcodeproj != nil
          Actions::lane_context[SharedValues::XCODEPROJ] = xcodeproj
          project_name = File.basename(xcodeproj, ".xcodeproj")
          Actions::lane_context[SharedValues::PROJECT_NAME] = project_name
          info_plist = self.get_info_plist(xcodeproj, project_name)
          Actions::lane_context[SharedValues::INFO_PLIST] = info_plist
          return {
            xcodeproj: xcodeproj,
            name: project_name,
            info_plist: info_plist
          }
        else
          UI.user_error! "Xcodeproj not found"
        end
      end

      def self.get_info_plist(xcodeproj, project_name)
        directory = File.dirname(xcodeproj)
        plist_name = "Info.plist"
        plist_paths = [project_name, "Sources", ""]
        i = 0
        while i < plist_paths.length do
          plist_path = File.join(plist_paths[i], plist_name)
          if File.exists?(File.join(directory, plist_path))
            return plist_path
          end
          i += 1
        end
        return nil
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Retrieves project information"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                       env_name: "XCODEPROJ",
                                       description: "The xcodeoproj path",
                                       optional: true)
        ]
      end

      def self.output
        [
          ['PROJECT_NAME', 'The project name'],
          ['XCODEPROJ', 'The xcodeproj path'],
          ['INFO_PLIST', 'The plist path']
        ]
      end

      def self.return_value
        "Dictionary containing information about the project such as the name, the plist path and the xcodeproj path"
      end

      def self.authors
        ["bbriatte", "vbalasubramaniam"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
