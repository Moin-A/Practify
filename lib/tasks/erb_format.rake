namespace :erb do
  desc "Format all ERB files in the project"
  task :format do
    require "erb/formatter"

    erb_files = Dir.glob("app/views/**/*.erb")
    
    if erb_files.empty?
      puts "No ERB files found to format"
      exit
    end

    puts "Formatting #{erb_files.length} ERB file(s)..."
    
    erb_files.each do |file|
      original_content = File.read(file)
      formatted_content = ERB::Formatter.format(original_content)
      
      if original_content != formatted_content
        File.write(file, formatted_content)
        puts "✓ Formatted #{file}"
      else
        puts "  #{file} (already formatted)"
      end
    end

    puts "Done!"
  end

  desc "Check if ERB files are formatted (dry run)"
  task :check do
    require "erb/formatter"

    erb_files = Dir.glob("app/views/**/*.erb")
    
    if erb_files.empty?
      puts "No ERB files found to check"
      exit
    end

    puts "Checking #{erb_files.length} ERB file(s)..."
    
    unformatted = []
    erb_files.each do |file|
      original_content = File.read(file)
      formatted_content = ERB::Formatter.format(original_content)
      
      if original_content != formatted_content
        unformatted << file
      end
    end

    if unformatted.empty?
      puts "All ERB files are properly formatted!"
    else
      puts "The following files need formatting:"
      unformatted.each { |file| puts "  - #{file}" }
      puts "\nRun 'rake erb:format' to format them."
      exit 1
    end
  end
end

