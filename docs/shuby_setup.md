# Shuby Chat Assistant Setup Guide

Shuby is an AI-powered chat assistant for child development (0-36 months) integrated into this Rails application using RubyLLM and OpenAI.

## Prerequisites

1. **OpenAI Account** - You need an OpenAI API key
2. **OpenAI Vector Store** - Your documents should already be uploaded to an OpenAI Vector Store

## Configuration

### 1. Add OpenAI Credentials

Edit your Rails credentials:

```bash
bin/rails credentials:edit
```

Add the following configuration:

```yaml
openai:
  api_key: sk-your-openai-api-key-here
  vector_store_id: vs_your-vector-store-id-here
```

### 2. Get Your Vector Store ID

Your Vector Store ID from the PoC should look like: `vs_xxxxxxxxxxxxxxxx`

You can find this in your OpenAI Dashboard under:
- Storage → Vector Stores

### 3. Verify Configuration

After setting up credentials, verify in Rails console:

```ruby
bin/rails console

# Check credentials are set
Rails.application.credentials.dig(:openai, :api_key)
# => "sk-..."

Rails.application.credentials.dig(:openai, :vector_store_id)  
# => "vs_..."
```

## Features

### Chat Functionality
- **Real-time streaming** - Responses stream in real-time via Turbo Streams
- **Conversation history** - All chats are saved to the database
- **Multi-turn conversations** - Full context maintained across messages
- **Dark mode support** - UI adapts to user's theme preference

### RAG (Retrieval Augmented Generation)
- **Vector Store Search** - Uses OpenAI's hosted Vector Store
- **File Search Tool** - Custom RubyLLM tool searches your knowledge base
- **Citations** - Sources are displayed for each response

### Models Used
- **Chat Model**: `gpt-4o-mini` (configurable in `ShubyAssistantService`)
- **Embeddings**: Uses your existing OpenAI Vector Store

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Rails Application                         │
├─────────────────────────────────────────────────────────────────┤
│  Controller: ShubyChatsController                               │
│    └─ Handles HTTP requests and Turbo Streams                   │
├─────────────────────────────────────────────────────────────────┤
│  Service: ShubyAssistantService                                 │
│    └─ Manages RubyLLM chat with system prompt                   │
├─────────────────────────────────────────────────────────────────┤
│  Tool: FileSearchTool                                           │
│    └─ Searches OpenAI Vector Store via ruby-openai gem          │
├─────────────────────────────────────────────────────────────────┤
│  Models:                                                        │
│    ├─ ShubyChat (acts_as_chat)                                 │
│    ├─ ShubyMessage (acts_as_message)                           │
│    └─ ShubyToolCall (acts_as_tool_call)                        │
└─────────────────────────────────────────────────────────────────┘
```

## File Structure

```
app/
├── controllers/
│   └── shuby_chats_controller.rb
├── models/
│   ├── shuby_chat.rb
│   ├── shuby_message.rb
│   └── shuby_tool_call.rb
├── services/
│   └── shuby_assistant_service.rb
├── tools/
│   └── file_search_tool.rb
├── views/
│   └── shuby_chats/
│       ├── index.html.erb
│       ├── show.html.erb
│       ├── _message.html.erb
│       ├── _message_form.html.erb
│       ├── _assistant_message_placeholder.html.erb
│       ├── _assistant_message_streaming.html.erb
│       └── _error_message.html.erb
└── javascript/
    └── controllers/
        ├── shuby_chat_controller.js
        ├── shuby_form_controller.js
        └── markdown_controller.js

config/
├── initializers/
│   └── ruby_llm.rb
└── routes/
    └── shuby.rb

db/
└── migrate/
    └── 20250525142300_create_shuby_tables.rb
```

## Usage

### Accessing Shuby
1. Log in to the application
2. Click "Shuby" in the navigation bar
3. Start a new conversation or continue an existing one

### API Routes

| Method | Path | Description |
|--------|------|-------------|
| GET | `/shuby` | List all conversations |
| GET | `/shuby/:id` | View a conversation |
| POST | `/shuby` | Create new conversation |
| DELETE | `/shuby/:id` | Delete a conversation |
| POST | `/shuby/:id/message` | Send a message |

## Customization

### Changing the Model

Edit `app/services/shuby_assistant_service.rb`:

```ruby
DEFAULT_MODEL = "gpt-4o-mini"  # or any other OpenAI model
```

### Modifying the System Prompt

Edit the `SYSTEM_PROMPT` constant in `app/services/shuby_assistant_service.rb`.

### Adding More Tools

Create additional tools in `app/tools/` following the RubyLLM tool pattern:

```ruby
class MyCustomTool < RubyLLM::Tool
  description "Description of what this tool does"
  param :input, type: :string, desc: "Input parameter description"

  def execute(input:)
    # Your tool logic here
    { result: "..." }
  end
end
```

Then add it to the service:

```ruby
def llm_chat
  @llm_chat ||= @shuby_chat.to_llm
                           .with_instructions(SYSTEM_PROMPT)
                           .with_tools(FileSearchTool, MyCustomTool)
end
```

## Troubleshooting

### "Vector store not configured" Error
Ensure your credentials include the `vector_store_id`:
```bash
bin/rails credentials:edit
```

### API Rate Limits
If you hit rate limits, the error will be displayed to the user. Consider implementing retry logic or queue-based processing for production.

### Streaming Issues
Ensure Action Cable is properly configured. Check `config/cable.yml` and that your server supports WebSockets.

## Testing

Run the test suite:
```bash
bin/rails test
```

For manual testing:
```ruby
# In Rails console
user = User.first
chat = user.shuby_chats.create!(model: "gpt-4o-mini")
service = ShubyAssistantService.new(chat)
response = service.ask("Quali sono le tappe di sviluppo a 6 mesi?")
puts response.content
