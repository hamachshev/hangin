# config/initializers/start_solid_queue_in_dev.rb

# #chat gpt generated
#
#   # Start the background job processor in a new thread
#   Thread.new do
#     system("cd #{Rails.root} && bin/jobs") if Rails.env.development?
#   end
