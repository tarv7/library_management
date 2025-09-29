# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "localhost:3000", "localhost:3001", "localhost:4200", "localhost:5173", "localhost:5174", "localhost:8080",
            "127.0.0.1:3000", "127.0.0.1:3001", "127.0.0.1:4200", "127.0.0.1:5173", "127.0.0.1:5174", "127.0.0.1:8080"

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true
  end

  allow do
    origins "library-management-flame-phi.vercel.app"

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true
  end
end
