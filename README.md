# Library Management API

A RESTful API for library management built with Ruby on Rails. This system allows the management of books, users, and reservations, with different access levels for members and librarians.

## 🌐 Frontend

- **Production App**: https://library-management-flame-phi.vercel.app
- **Frontend Repository**: https://github.com/tarv7/library_management_front

## 📋 Features

- **JWT Authentication**: Secure login system with JWT tokens
- **User Management**: Registration and management of members and librarians
- **Book Catalog**: Complete CRUD for books with search functionality
- **Reservation System**: Book reservation and return management
- **Dashboards**: Specific panels for members and librarians
- **API Documentation**: Swagger interface to explore the API
- **Role-based Access Control**: Permission control based on user roles

## 🚀 Technologies

- **Ruby** 3.4.2
- **Rails** 8.0.2+
- **PostgreSQL** as database
- **JWT** for authentication
- **RSpec** for testing
- **Swagger/OpenAPI** for documentation

## 🛠️ Development Environment Setup

### Prerequisites

- Ruby 3.4.2 (we recommend using rbenv or rvm)
- PostgreSQL
- Git

### 1. Clone the repository

```bash
git clone https://github.com/tarv7/library_management.git
cd library_management
```

### 2. Setup the project

Make sure PostgreSQL is running and configure credentials in `config/database.yml` if necessary (default: user `postgres`, password `postgres`).

```bash
# Install dependencies, create databases and run migrations
./bin/setup

# Seed the database with initial data
rails db:seed
```

### 3. Start the server

```bash
./bin/dev
```

The API will be available at `http://localhost:3000`

## 🔑 Demo Credentials

You can test the application using these pre-defined user accounts:

### Librarians
- **Email**: `thales.lib@gmail.com` | **Password**: `password`
- **Email**: `sarah.johnson@library.com` | **Password**: `password`

### Members
- **Email**: `thales.mem@gmail.com` | **Password**: `password`
- **Email**: `john.smith@email.com` | **Password**: `password`
- **Email**: `emily.davis@email.com` | **Password**: `password`
- **Email**: `michael.brown@email.com` | **Password**: `password`
- **Email**: `jessica.wilson@email.com` | **Password**: `password`

## 📚 API Documentation

### Swagger UI

- **Production**: https://library-management-back-e6f3cf925e79.herokuapp.com/api-docs
- **Local Development**: http://localhost:3000/api-docs

### Main Endpoints

#### Authentication
- `POST /api/v1/auth` - Login and JWT token retrieval

#### Users
- `POST /api/v1/users` - Register new users
- `GET /api/v1/users/members` - List members (librarians only)
- `GET /api/v1/users/members/dashboard` - Member dashboard
- `GET /api/v1/users/librarians/dashboard` - Librarian dashboard

#### Books
- `GET /api/v1/books` - List all books (with search)
- `GET /api/v1/books/:id` - Book details
- `POST /api/v1/books` - Create book (librarians only)
- `PUT /api/v1/books/:id` - Update book (librarians only)
- `DELETE /api/v1/books/:id` - Delete book (librarians only)

#### Reservations
- `GET /api/v1/reservations` - List user reservations
- `POST /api/v1/books/:book_id/reservations` - Create reservation
- `PUT /api/v1/books/:book_id/reservations/:id` - Update reservation

## 🧪 Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific tests
bundle exec rspec spec/models/
bundle exec rspec spec/controllers/

# Run with code coverage
bundle exec rspec --format documentation
```

## 🔧 Development Tools

### Linting and Code Quality

```bash
# RuboCop (linting)
bundle exec rubocop

# Brakeman (security analysis)
bundle exec brakeman
```

### Generating Swagger Documentation

```bash
# Generate documentation from specs
bundle exec rake rswag:specs:swaggerize
```

## 📝 Project Structure

```
app/
├── controllers/          # API Controllers
│   └── api/v1/          # API Version 1
├── models/              # ActiveRecord Models
├── services/            # Services (JWT, etc.)
└── views/               # JSON Views (JBuilder)

config/                  # Rails Configurations
spec/                   # RSpec Tests
swagger/                # OpenAPI Documentation
```

## 🤝 Contributing

1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is under the MIT license. See the `LICENSE` file for more details.
