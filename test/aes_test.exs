defmodule ExKits.Crypto.AES128CBCTest do
  @moduledoc false
  use ExUnit.Case

  test "encrypting and decrypting a string" do
    secret_key = <<1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16>>
    iv = <<17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32>>

    plaintext = "hello world"
    ciphertext = ExKits.Crypto.AES128CBC.encrypt(plaintext, secret_key, iv)
    decrypted_text = ExKits.Crypto.AES128CBC.decrypt(ciphertext, secret_key, iv)

    assert decrypted_text == plaintext
  end

  test "encrypting and decrypting a binary" do
    secret_key = <<1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16>>
    iv = <<17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32>>

    plaintext = <<1, 2, 3, 4, 5>>
    ciphertext = ExKits.Crypto.AES128CBC.encrypt(plaintext, secret_key, iv)
    decrypted_text = ExKits.Crypto.AES128CBC.decrypt(ciphertext, secret_key, iv)

    assert decrypted_text == plaintext
  end
end
