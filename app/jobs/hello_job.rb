class HelloJob < ApplicationJob
  queue_as :default

  def perform
    puts "🚀 SOLID QUEUE WORKED! Current time: #{Time.now}"
  end
end
