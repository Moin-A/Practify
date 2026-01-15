class NavComponent < ApplicationComponent
    def svg_inner_content(name)
        path = Rails.root.join("public", "#{name.downcase}.svg")
        return "" unless File.exist?(path)
    
        # Read the file and strip the outer <svg> tags
        raw_svg = File.read(path)
        raw_svg.gsub(/<svg[^>]*>|<\/svg>/i, "").html_safe
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
