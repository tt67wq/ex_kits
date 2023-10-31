defmodule SSLTest do
  @moduledoc false
  use ExUnit.Case

  test "loading a certificate and key from PEM-encoded data" do
    pem = File.read!("test/cert.pem")
    ssl = ExKits.Crypto.SSL.load_pem(pem)
    assert {:Certificate, _, {:AlgorithmIdentifier, _, _}, _} = ssl
  end

  # test "loading a certificate and key from a map of PEM-encoded data" do
  #   ssl = %{
  #     cert: File.read!("test/cert.pem"),
  #     key: File.read!("test/key.pem")
  #   }

  #   [{:RSAPrivateKey, key}] = ExKits.Crypto.SSL.load_ssl(ssl)[:key]

  #   assert is_binary(key)
  # end
end
