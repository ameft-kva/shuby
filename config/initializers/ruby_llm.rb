# frozen_string_literal: true

# RubyLLM configuration for Shuby chat assistant
RubyLLM.configure do |config|
  # OpenAI API key from environment variable
  config.openai_api_key = "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"

  # Default model for chat
  config.default_model = "gpt-5-mini"

  # Request timeout in seconds
  config.request_timeout = 120

  # Enable logging in development
  config.log_level = Rails.env.development? ? :debug : :info
end

# Autoload tools from app/tools directory
Rails.autoloaders.main.push_dir(Rails.root.join("app/tools"))
