require 'rails_helper'

RSpec.describe JsonWebToken, type: :service do
  let(:payload) { { user_id: 1, email: 'test@example.com' } }
  let(:secret_key) { Rails.application.secret_key_base }

  describe '.encode' do
    context 'when payload is provided without custom expiration' do
      it 'encodes the payload with default expiration' do
        token = JsonWebToken.encode(payload)

        expect(token).to be_a(String)
        expect(token.split('.').length).to eq(3)
      end

      it 'includes expiration time in the payload' do
        token = JsonWebToken.encode(payload)
        decoded_payload = JWT.decode(token, secret_key)[0]

        expected_exp = 24.hours.from_now.to_i
        expect(decoded_payload['exp']).to be_within(60).of(expected_exp) # Allow 1 minute tolerance
      end

      it 'preserves original payload data' do
        token = JsonWebToken.encode(payload)
        decoded_payload = JWT.decode(token, secret_key)[0]

        expect(decoded_payload['user_id']).to eq(1)
        expect(decoded_payload['email']).to eq('test@example.com')
      end
    end

    context 'when payload is provided with custom expiration' do
      let(:custom_exp) { 1.hour.from_now }

      it 'encodes the payload with custom expiration' do
        token = JsonWebToken.encode(payload, custom_exp)
        decoded_payload = JWT.decode(token, secret_key)[0]

        expect(decoded_payload['exp']).to eq(custom_exp.to_i)
      end
    end

    context 'when payload is empty' do
      it 'encodes empty payload successfully' do
        token = JsonWebToken.encode({})
        decoded_payload = JWT.decode(token, secret_key)[0]

        expect(decoded_payload.keys).to contain_exactly('exp')
      end
    end
  end

  describe '.decode' do
    let(:token) { JsonWebToken.encode(payload) }

    context 'when token is valid' do
      it 'decodes the token successfully' do
        decoded = JsonWebToken.decode(token)

        expect(decoded).to be_a(HashWithIndifferentAccess)
        expect(decoded[:user_id]).to eq(1)
        expect(decoded[:email]).to eq('test@example.com')
        expect(decoded[:exp]).to be_present
      end
    end

    context 'when token is invalid' do
      it 'returns nil for malformed token' do
        invalid_token = 'invalid.token.format'

        expect(JsonWebToken.decode(invalid_token)).to be_nil
      end

      it 'returns nil for token with wrong signature' do
        wrong_token = JWT.encode(payload, 'wrong_secret')

        expect(JsonWebToken.decode(wrong_token)).to be_nil
      end

      it 'returns nil for empty token' do
        expect(JsonWebToken.decode('')).to be_nil
      end

      it 'returns nil for nil token' do
        expect(JsonWebToken.decode(nil)).to be_nil
      end
    end

    context 'when token is expired' do
      it 'returns nil for expired token' do
        expired_token = JsonWebToken.encode(payload, 1.second.ago)

        expect(JsonWebToken.decode(expired_token)).to be_nil
      end
    end
  end

  describe 'SECRET_KEY constant' do
    it 'uses Rails secret key base' do
      expect(JsonWebToken::SECRET_KEY).to eq(Rails.application.secret_key_base)
    end
  end
end
