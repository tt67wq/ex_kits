defmodule ExKits.Crypto.AES128CBC do
  @moduledoc """
  This module provides functions for encrypting and decrypting data using the AES-128-CBC algorithm.

  ## Examples

      secret_key = <<1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16>>
      iv = <<17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32>>

      plaintext = "hello world"
      ciphertext = ExKits.Crypto.AES128CBC.encrypt(plaintext, secret_key, iv)
      decrypted_text = ExKits.Crypto.AES128CBC.decrypt(ciphertext, secret_key, iv)

      assert decrypted_text == plaintext

  ## Security Warning

  This module provides a basic implementation of the AES-128-CBC algorithm
  and should not be used in production environments without proper security review and testing.
  """
  @block_size 16

  @type key :: <<_::128>>
  @type iv :: <<_::128>>

  @spec encrypt(binary, key(), iv()) :: binary
  def encrypt(plaintext, secret_key, iv) do
    plaintext = pkcs5padding(plaintext, @block_size)
    encrypted_text = :crypto.crypto_one_time(:aes_128_cbc, secret_key, iv, plaintext, true)
    Base.encode64(encrypted_text)
  end

  @spec decrypt(binary, key(), iv()) :: binary
  def decrypt(ciphertext, secret_key, iv) do
    {:ok, ciphertext} = Base.decode64(ciphertext)
    decrypted_text = :crypto.crypto_one_time(:aes_128_cbc, secret_key, iv, ciphertext, false)
    pkcs5unpad(decrypted_text)
  end

  defp pkcs5unpad(data) do
    to_remove = :binary.last(data)
    :binary.part(data, 0, byte_size(data) - to_remove)
  end

  # PKCS5Padding
  defp pkcs5padding(data, block_size) do
    to_add = block_size - rem(byte_size(data), block_size)
    data <> :binary.copy(<<to_add>>, to_add)
  end
end
