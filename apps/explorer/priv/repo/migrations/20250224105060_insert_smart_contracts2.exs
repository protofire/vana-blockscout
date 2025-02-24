defmodule Explorer.Repo.Migrations.InsertSmartContracts2 do
  use Ecto.Migration
  alias Explorer.Chain.SmartContract
  alias Explorer.Repo

  def up do
    smart_contracts = Path.join(:code.priv_dir(:explorer), "repo/migrations/smart_contracts.csv")

    smart_contracts
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Enum.each(&update_smart_contracts/1)
  end

  def down, do: :ok

  defp update_smart_contracts(row) do
    id = String.to_integer(row["id"])

    smart_contracts_additional_sources =
      Path.join(:code.priv_dir(:explorer), "repo/migrations/smart_contracts_additional_sources.csv")
      |> File.stream!()
      |> CSV.decode!(headers: true)

    changes = %{
      name: row["name"],
      address_hash: row["address_hash"],
      compiler_version: row["compiler_version"],
      optimization: row["optimization"] == "TRUE",
      optimization_runs: String.to_integer(row["optimization_runs"]),
      contract_source_code: row["contract_source_code"],
      constructor_arguments: row["constructor_arguments"],
      evm_version: row["evm_version"],
      abi: Jason.decode!(row["abi"]),
      verified_via_sourcify: row["verified_via_sourcify"] == "TRUE",
      verified_via_eth_bytecode_db: row["verified_via_eth_bytecode_db"] == "TRUE",
      verified_via_verifier_alliance: row["verified_via_verifier_alliance"] == "TRUE",
      partially_verified: row["partially_verified"] == "TRUE",
      file_path: row["file_path"],
      is_vyper_contract: row["is_vyper_contract"] == "TRUE",
      is_changed_bytecode: row["is_changed_bytecode"] == "TRUE",
      bytecode_checked_at: row["bytecode_checked_at"],
      contract_code_md5: row["contract_code_md5"],
      compiler_settings: Jason.decode!(row["compiler_settings"]),
      autodetect_constructor_args: row["autodetect_constructor_args"],
      is_yul: row["is_yul"],
      metadata_from_verified_bytecode_twin: row["metadata_from_verified_bytecode_twin"],
      license_type: String.to_integer(row["license_type"]),
      certified: nil,
      is_blueprint: row["is_blueprint"] == "TRUE",
      language:
        if row["language"] != "" do
          String.to_integer(row["language"])
        else
          nil
        end,
      smart_contract_additional_sources:
        Enum.filter(smart_contracts_additional_sources, fn additional_sources_row ->
          case(row["address_hash"] == additional_sources_row["address_hash"]) do
            true ->
              %{
                file_name: additional_sources_row["file_name"],
                contract_source_code: additional_sources_row["contract_source_code"],
                address_hash: additional_sources_row["address_hash"]
              }

            _ ->
              nil
          end
        end)
    }

    case Repo.get(SmartContract, id) do
      nil ->
        %SmartContract{}
        |> SmartContract.changeset(changes)
        |> Repo.insert()

      record ->
        record
        |> SmartContract.changeset(changes)
        |> Repo.update()
    end
  end
end
