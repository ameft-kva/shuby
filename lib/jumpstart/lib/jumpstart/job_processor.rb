module Jumpstart
  class JobProcessor
    AVAILABLE_PROVIDERS = {
      "I'll configure my own" => nil,
      "Async" => :async,
      "SolidQueue" => :solid_queue,
      "Sidekiq" => :sidekiq
    }.freeze

    AVAILABLE_PROVIDERS.each do |_, name|
      define_singleton_method :"#{name}?" do
        Jumpstart.config.job_processor == name
      end
    end

    def self.command(processor)
      case processor.to_s
      when "solid_queue"
        "bin/jobs"
      when "sidekiq"
        "bundle exec sidekiq"
      end
    end
  end
end
