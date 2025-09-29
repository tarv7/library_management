# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Library Management API',
        version: 'v1',
        description: 'API for managing library books, users and reservations'
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        },
        {
          url: 'https://library-management-back-e6f3cf925e79.herokuapp.com',
          description: 'Production server'
        }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: 'http',
            scheme: 'bearer',
            bearerFormat: 'JWT'
          }
        },
        schemas: {
          User: {
            type: 'object',
            properties: {
              id: {
                type: 'integer',
                example: 1
              },
              email_address: {
                type: 'string',
                format: 'email',
                example: 'user@example.com'
              },
              name: {
                type: 'string',
                example: 'John Doe'
              },
              role: {
                type: 'string',
                enum: ['member', 'librarian'],
                example: 'member'
              }
            },
            required: ['email_address', 'name', 'role']
          },
          UserInput: {
            type: 'object',
            properties: {
              email_address: {
                type: 'string',
                format: 'email',
                example: 'user@example.com'
              },
              password: {
                type: 'string',
                minLength: 6,
                example: 'password123'
              },
              password_confirmation: {
                type: 'string',
                minLength: 6,
                example: 'password123'
              },
              name: {
                type: 'string',
                example: 'John Doe'
              },
              role: {
                type: 'string',
                enum: ['member', 'librarian'],
                example: 'member'
              }
            },
            required: ['email_address', 'password', 'password_confirmation', 'name', 'role']
          },
          LoginInput: {
            type: 'object',
            properties: {
              email_address: {
                type: 'string',
                format: 'email',
                example: 'user@example.com'
              },
              password: {
                type: 'string',
                example: 'password123'
              }
            },
            required: ['email_address', 'password']
          },
          AuthToken: {
            type: 'object',
            properties: {
              token: {
                type: 'string',
                example: 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE3MzI3NTQ4ODF9.abc123'
              }
            }
          },
          AuthError: {
            type: 'object',
            properties: {
              error: {
                type: 'string',
                example: 'Invalid email or password'
              }
            }
          },
          Book: {
            type: 'object',
            properties: {
              id: {
                type: 'integer',
                example: 1
              },
              title: {
                type: 'string',
                example: 'The Great Gatsby'
              },
              author: {
                type: 'string',
                example: 'F. Scott Fitzgerald'
              },
              genre: {
                type: 'string',
                enum: ['fiction', 'non_fiction', 'mystery', 'science_fiction', 'fantasy', 'romance', 'thriller', 'biography', 'history', 'poetry', 'drama'],
                example: 'fiction'
              },
              isbn: {
                type: 'string',
                example: '978-0-7432-7356-5'
              },
              total_copies: {
                type: 'integer',
                example: 5
              },
              created_at: {
                type: 'string',
                format: 'date-time'
              },
              updated_at: {
                type: 'string',
                format: 'date-time'
              },
              url: {
                type: 'string',
                format: 'uri',
                example: 'http://localhost:3000/api/v1/books/1.json'
              }
            }
          },
          BookInput: {
            type: 'object',
            properties: {
              title: {
                type: 'string',
                minLength: 2,
                maxLength: 255,
                example: 'The Great Gatsby'
              },
              author: {
                type: 'string',
                minLength: 2,
                maxLength: 255,
                example: 'F. Scott Fitzgerald'
              },
              genre: {
                type: 'string',
                enum: ['fiction', 'non_fiction', 'mystery', 'science_fiction', 'fantasy', 'romance', 'thriller', 'biography', 'history', 'poetry', 'drama'],
                example: 'fiction'
              },
              isbn: {
                type: 'string',
                example: '978-0-7432-7356-5'
              },
              total_copies: {
                type: 'integer',
                minimum: 0,
                example: 5
              }
            },
            required: ['title', 'author', 'genre', 'isbn', 'total_copies']
          },
          BooksArray: {
            type: 'array',
            items: {
              '$ref' => '#/components/schemas/Book'
            }
          },
          Reservation: {
            type: 'object',
            properties: {
              id: {
                type: 'integer',
                example: 1
              },
              book_id: {
                type: 'integer',
                example: 1
              },
              user_id: {
                type: 'integer',
                example: 1
              },
              borrowed_on: {
                type: 'string',
                format: 'date',
                example: '2025-09-28'
              },
              due_on: {
                type: 'string',
                format: 'date',
                example: '2025-10-12'
              },
              returned_at: {
                type: 'string',
                format: 'date-time',
                nullable: true,
                example: '2025-10-10T10:30:00Z'
              },
              created_at: {
                type: 'string',
                format: 'date-time'
              },
              updated_at: {
                type: 'string',
                format: 'date-time'
              }
            }
          },
          ReservationError: {
            type: 'object',
            properties: {
              book: {
                type: 'array',
                items: {
                  type: 'string'
                },
                example: ['is already borrowed', 'has no available copies']
              }
            }
          },
          MemberDashboard: {
            type: 'object',
            properties: {
              member: {
                type: 'object',
                properties: {
                  id: {
                    type: 'integer',
                    example: 1
                  },
                  name: {
                    type: 'string',
                    example: 'John Doe'
                  },
                  email_address: {
                    type: 'string',
                    format: 'email',
                    example: 'john@example.com'
                  }
                }
              },
              borrowed_books: {
                type: 'array',
                items: {
                  type: 'object',
                  properties: {
                    reservation_id: {
                      type: 'integer',
                      example: 1
                    },
                    borrowed_on: {
                      type: 'string',
                      format: 'date',
                      example: '2025-09-28'
                    },
                    due_on: {
                      type: 'string',
                      format: 'date',
                      example: '2025-10-12'
                    },
                    book: {
                      type: 'object',
                      properties: {
                        id: {
                          type: 'integer',
                          example: 1
                        },
                        title: {
                          type: 'string',
                          example: 'The Great Gatsby'
                        },
                        author: {
                          type: 'string',
                          example: 'F. Scott Fitzgerald'
                        },
                        isbn: {
                          type: 'string',
                          example: '978-0-7432-7356-5'
                        },
                        genre: {
                          type: 'string',
                          example: 'fiction'
                        }
                      }
                    }
                  }
                }
              },
              overdue_books: {
                type: 'array',
                items: {
                  type: 'object',
                  properties: {
                    reservation_id: {
                      type: 'integer',
                      example: 2
                    },
                    borrowed_on: {
                      type: 'string',
                      format: 'date',
                      example: '2025-09-01'
                    },
                    due_on: {
                      type: 'string',
                      format: 'date',
                      example: '2025-09-15'
                    },
                    days_overdue: {
                      type: 'integer',
                      example: 13
                    },
                    book: {
                      type: 'object',
                      properties: {
                        id: {
                          type: 'integer',
                          example: 2
                        },
                        title: {
                          type: 'string',
                          example: '1984'
                        },
                        author: {
                          type: 'string',
                          example: 'George Orwell'
                        },
                        isbn: {
                          type: 'string',
                          example: '978-0-452-28423-4'
                        },
                        genre: {
                          type: 'string',
                          example: 'science_fiction'
                        }
                      }
                    }
                  }
                }
              },
              summary: {
                type: 'object',
                properties: {
                  total_borrowed_books: {
                    type: 'integer',
                    example: 3
                  },
                  total_overdue_books: {
                    type: 'integer',
                    example: 1
                  }
                }
              }
            }
          },
          LibrarianDashboard: {
            type: 'object',
            properties: {
              librarian: {
                type: 'object',
                properties: {
                  id: {
                    type: 'integer',
                    example: 1
                  },
                  name: {
                    type: 'string',
                    example: 'Jane Smith'
                  },
                  email_address: {
                    type: 'string',
                    format: 'email',
                    example: 'librarian@example.com'
                  }
                }
              },
              statistics: {
                type: 'object',
                properties: {
                  total_books: {
                    type: 'integer',
                    example: 150
                  },
                  total_borrowed_books: {
                    type: 'integer',
                    example: 45
                  },
                  books_due_today_count: {
                    type: 'integer',
                    example: 3
                  },
                  members_with_overdue_books_count: {
                    type: 'integer',
                    example: 5
                  }
                }
              },
              books_due_today: {
                type: 'array',
                items: {
                  type: 'object',
                  properties: {
                    reservation_id: {
                      type: 'integer',
                      example: 1
                    },
                    borrowed_on: {
                      type: 'string',
                      format: 'date',
                      example: '2025-09-14'
                    },
                    due_on: {
                      type: 'string',
                      format: 'date',
                      example: '2025-09-28'
                    },
                    member: {
                      type: 'object',
                      properties: {
                        id: {
                          type: 'integer',
                          example: 2
                        },
                        name: {
                          type: 'string',
                          example: 'John Doe'
                        },
                        email_address: {
                          type: 'string',
                          format: 'email',
                          example: 'john@example.com'
                        }
                      }
                    },
                    book: {
                      type: 'object',
                      properties: {
                        id: {
                          type: 'integer',
                          example: 1
                        },
                        title: {
                          type: 'string',
                          example: 'The Great Gatsby'
                        },
                        author: {
                          type: 'string',
                          example: 'F. Scott Fitzgerald'
                        },
                        isbn: {
                          type: 'string',
                          example: '978-0-7432-7356-5'
                        },
                        genre: {
                          type: 'string',
                          example: 'fiction'
                        }
                      }
                    }
                  }
                }
              },
              members_with_overdue_books: {
                type: 'array',
                items: {
                  type: 'object',
                  properties: {
                    member_id: {
                      type: 'integer',
                      example: 3
                    },
                    member_name: {
                      type: 'string',
                      example: 'Alice Johnson'
                    },
                    member_email: {
                      type: 'string',
                      format: 'email',
                      example: 'alice@example.com'
                    },
                    overdue_books: {
                      type: 'array',
                      items: {
                        type: 'object',
                        properties: {
                          reservation_id: {
                            type: 'integer',
                            example: 5
                          },
                          borrowed_on: {
                            type: 'string',
                            format: 'date',
                            example: '2025-09-01'
                          },
                          due_on: {
                            type: 'string',
                            format: 'date',
                            example: '2025-09-15'
                          },
                          days_overdue: {
                            type: 'integer',
                            example: 13
                          },
                          book: {
                            type: 'object',
                            properties: {
                              id: {
                                type: 'integer',
                                example: 2
                              },
                              title: {
                                type: 'string',
                                example: '1984'
                              },
                              author: {
                                type: 'string',
                                example: 'George Orwell'
                              },
                              isbn: {
                                type: 'string',
                                example: '978-0-452-28423-4'
                              },
                              genre: {
                                type: 'string',
                                example: 'science_fiction'
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          },
          Error: {
            type: 'object',
            properties: {
              error: {
                type: 'string',
                example: 'Validation failed'
              }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
