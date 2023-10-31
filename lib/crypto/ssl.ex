defmodule ExKits.Crypto.SSL do
  @moduledoc """
  This module provides functions for loading SSL certificates and keys from PEM-encoded data.
  """
  defp decode_public(nil), do: nil

  defp decode_public(pem) do
    [{:Certificate, der_bin, :not_encrypted}] = :public_key.pem_decode(pem)
    der_bin
  end

  defp decode_private(pem) do
    [{type, der_bin, :not_encrypted}] = :public_key.pem_decode(pem)
    {type, der_bin}
  end

  @spec load_ssl(Keyword.t()) :: [any()]
  def load_ssl([]), do: []

  def load_ssl(ssl) do
    ssl = Enum.into(ssl, %{})

    [
      cacerts: ssl.ca_cert |> decode_public() |> List.wrap(),
      cert: ssl.cert |> decode_public(),
      key: ssl.key |> decode_private()
    ]
    |> Enum.reject(fn {_k, v} -> v == nil end)
  end

  @doc """
  decode a PEM-encoded certificate or key

  ## Examples

      iex> pem = File.read!("test/cert.pem")
      iex> ExKits.Crypto.SSL.load_pem(pem)
      {:Certificate,
        {:TBSCertificate, 0, 185741190458257600844327592762093690784461317564,
        {:AlgorithmIdentifier, {1, 2, 840, 113549, 1, 1, 11}, <<5, 0>>},
        {:rdnSequence,
         [
           [{:AttributeTypeAndValue, {2, 5, 4, 6}, <<19, 2, 65, 85>>}],
           [{:AttributeTypeAndValue, {2, 5, 4, 8}, "\f\nSome-State"}],
           [
             {:AttributeTypeAndValue, {2, 5, 4, 10},
              <<12, 24, 73, 110, 116, 101, 114, 110, 101, 116, 32, 87, 105, 100, 103,
                105, 116, 115, 32, 80, 116, 121, 32, 76, 116, 100>>}
           ]
         ]},
        {:Validity, {:utcTime, ~c"231031062646Z"}, {:utcTime, ~c"241030062646Z"}},
        {:rdnSequence,
         [
           [{:AttributeTypeAndValue, {2, 5, 4, 6}, <<19, 2, 65, 85>>}],
           [{:AttributeTypeAndValue, {2, 5, 4, 8}, "\f\nSome-State"}],
           [
             {:AttributeTypeAndValue, {2, 5, 4, 10},
              <<12, 24, 73, 110, 116, 101, 114, 110, 101, 116, 32, 87, 105, 100, 103,
                105, 116, 115, 32, 80, 116, 121, 32, 76, 116, 100>>}
           ]
         ]},
        {:SubjectPublicKeyInfo,
         {:AlgorithmIdentifier, {1, 2, 840, 113549, 1, 1, 1}, <<5, 0>>},
         <<48, 130, 1, 10, 2, 130, 1, 1, 0, 216, 146, 215, 34, 63, 210, 99, 245, 173,
           234, 130, 112, 247, 173, 214, 77, 124, 1, 187, 71, 140, 68, 143, 95, 147,
           53, 124, 153, ...>>}, :asn1_NOVALUE, :asn1_NOVALUE, :asn1_NOVALUE},
        {:AlgorithmIdentifier, {1, 2, 840, 113549, 1, 1, 11}, <<5, 0>>},
        <<105, 241, 117, 217, 15, 215, 93, 45, 194, 176, 225, 141, 85, 200, 101, 214,
         62, 69, 170, 91, 142, 107, 155, 200, 162, 31, 165, 214, 102, 37, 16, 39, 146,
         177, 255, 255, 150, 38, 96, 58, 8, 60, 226, 31, 22, 29, ...>>}
      }
  """
  @spec load_pem(binary) :: term()
  def load_pem(pem) do
    pem
    |> :public_key.pem_decode()
    |> List.first()
    |> :public_key.pem_entry_decode()
  end
end
