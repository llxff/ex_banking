defmodule ExBanking.AccountingSpec do
  use ESpec, async: false

  alias ExBanking.Accounting

  before do
    Application.stop(:ex_banking)
    Application.start(:ex_banking)

    :ok
  end

  it "should register new user" do
    expect(Accounting.add_account("user1")).to eq(:ok)

    {:ok, pid} = Accounting.find_account("user1")

    expect(Process.alive?(pid)).to eq(true)
  end

  it "should return error if user already exists" do
    Accounting.add_account("user1")
    expect(Accounting.add_account("user1")).to eq({:error, :user_already_exists})
  end

  it "should return error if user not found" do
    expect(Accounting.find_account("user2")).to eq({:error, :user_does_not_exist})
  end
end
