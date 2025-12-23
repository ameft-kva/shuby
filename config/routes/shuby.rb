# frozen_string_literal: true

# Routes for Shuby chat assistant
resources :shuby_chats, path: "shuby", as: :shuby_chats do
  member do
    post :message
  end
end

