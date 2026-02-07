class NavComponent < ApplicationComponent
    attr_reader :current_user
    def initialize(current_user: nil)
        @current_user = current_user
    end

    def user_profile
        @current_user.user_profile
    end


    def svg_inner_content(name)
        path = Rails.root.join("public", "#{name.downcase}.svg")
        return "" unless File.exist?(path)

        # Read the file and strip the outer <svg> tags
        raw_svg = File.read(path)
        raw_svg.gsub(/<svg[^>]*>|<\/svg>/i, "").html_safe
    end

    def target_path(path, user_profile)
        if path.to_sym === :root_path
            public_send("root_path")
        elsif path.to_sym === :calendar_path
            calendar = user_profile&.calendar
            return nil unless calendar
            public_send("calendar_path", calendar)
        elsif path.to_sym === :edit_user_profile_path
            public_send("edit_user_profile_path", user_profile)
        elsif path.to_sym === :calendar_schedule_path
            calendar = user_profile&.calendar
            return nil unless calendar
            public_send("calendar_schedule_path", calendar)
        end
    end

    def svg_attributes
        {
          class: "w-5 h-5 size-6",
          xmlns: "http://www.w3.org/2000/svg",
          fill: "none",
          viewBox: "0 0 24 24",
          stroke_width: "1.5",
          stroke: "currentColor"
        }
    end
end
