class JsonWebToken
  SECRET_KEY = Rails.application.secret_key_base

  def self.encode_user(user, exp = 24.hours.from_now)
    payload = {
      user_id: user.id,
      email_address: user.email_address,
      name: user.name,
      role: user.role,
      created_at: user.created_at
    }

    encode(payload, exp)
  end

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i

    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]

    decoded.with_indifferent_access
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
