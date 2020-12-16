class EncryptionService
  # from https://pawelurbanek.com/rails-secure-encrypt-decrypt
  # TODO: warn if production has no key--- like this: if Rails.env == "development"

  KEY = ActiveSupport::KeyGenerator.new(
    ENV["SECRET_KEY_BASE"] || 'development-key-base'
  ).generate_key(
    ENV["ENCRYPTION_SERVICE_SALT"] || 'development-salt',
    ActiveSupport::MessageEncryptor.key_len
  ).freeze

  private_constant :KEY

  delegate :encrypt_and_sign, :decrypt_and_verify, to: :encryptor

  def self.encrypt(value)
    new.encrypt_and_sign(value)
  end

  def self.decrypt(value)
    new.decrypt_and_verify(value)
  end

  private

  def encryptor
    ActiveSupport::MessageEncryptor.new(KEY)
  end
end
