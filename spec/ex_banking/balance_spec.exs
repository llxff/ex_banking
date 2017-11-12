defmodule ExBanking.BalanceSpec do
  use ESpec, async: true

  alias ExBanking.Balance

  describe ".new/0" do
    it do: expect(Balance.new()).to eq(%Balance{accounts: %{}})
  end

  describe ".amount/2" do
    let :balance, do: Balance.new()

    context "empty RUR balance" do
      it do: expect(Balance.amount(balance(), "RUR")).to eq(0.0)
    end

    context "existing balance" do
      it "should return actual balance" do
        {:ok, balance} = Balance.increase(balance(), 10.0, "RUR")

        expect(Balance.amount(balance, "RUR")).to eq(10.0)
      end
    end
  end

  describe ".increase/3" do
    let :balance, do: Balance.new()

    it "should increase balance" do
      {:ok, balance} = Balance.increase(balance(), 10.0, "RUR")

      expect(Balance.amount(balance, "RUR")).to eq(10.0)
      expect(Balance.amount(balance, "USD")).to eq(0.0)
    end
  end

  describe ".decrease/3" do
    let :balance do
      {:ok, balance} = Balance.increase(Balance.new(), 10.0, "RUR")

      balance
    end

    it "should decrease balance" do
      {:ok, balance} = Balance.decrease(balance(), 4.0, "RUR")

      expect(Balance.amount(balance, "RUR")).to eq(6.0)
    end
  end
end
