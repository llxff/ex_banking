defmodule ExBankingSpec do
  use ESpec, async: false
  import Mock

  alias ExBanking.{Accounting, RateLimiter}

  before do
    Application.stop(:ex_banking)
    Application.start(:ex_banking)

    :ok
  end

  describe ".create_user/1" do
    it "should return error with wrong user" do
      expect(ExBanking.create_user(1)).to eq({:error, :wrong_arguments})
    end

    it "should create user" do
      expect(ExBanking.create_user("user")).to eq(:ok)
    end

    it "should return error if user already exists" do
      ExBanking.create_user("user")

      expect(ExBanking.create_user("user")).to eq({:error, :user_already_exists})
    end
  end

  describe ".get_balance/2" do
    it "should return error with wrong user" do
      expect(ExBanking.get_balance(1, "RUR")).to eq({:error, :wrong_arguments})
    end

    it "should return error with wrong currency" do
      expect(ExBanking.get_balance("user", :RUR)).to eq({:error, :wrong_arguments})
    end

    it "should return error if user does not exist" do
      expect(ExBanking.get_balance("user", "RUR")).to eq({:error, :user_does_not_exist})
    end

    it "should return error if has a lot of requests" do
      ExBanking.create_user("user")

      with_mock(RateLimiter, [callable?: fn(_) -> false end]) do
        expect(ExBanking.get_balance("user", "RUR")).to eq({:error, :too_many_requests_to_user})
      end
    end

    it "should return default balance" do
      ExBanking.create_user("user")

      expect(ExBanking.get_balance("user", "RUR")).to eq({:ok, 0.0})
    end

    it "should return real balance" do
      ExBanking.create_user("user")
      ExBanking.deposit("user", 10.0, "USD")

      expect(ExBanking.get_balance("user", "USD")).to eq({:ok, 10.0})
    end
  end

  describe ".deposit/3" do
    it "should return error with wrong user" do
      expect(ExBanking.deposit(1, 10.0, "RUR")).to eq({:error, :wrong_arguments})
    end

    it "should return error with wrong amount" do
      expect(ExBanking.deposit("user", -10.0, "RUR")).to eq({:error, :wrong_arguments})
    end

    it "should return error with wrong currency" do
      expect(ExBanking.deposit("user", 10.0, :RUR)).to eq({:error, :wrong_arguments})
    end

    it "should return error if user does not exist" do
      expect(ExBanking.deposit("user", 10.0, "RUR")).to eq({:error, :user_does_not_exist})
    end

    it "should return error if has a lot of requests" do
      ExBanking.create_user("user")

      with_mock(RateLimiter, [callable?: fn(_) -> false end]) do
        expect(ExBanking.deposit("user", 10.0, "RUR")).to eq({:error, :too_many_requests_to_user})
      end
    end

    it "should increase balance of currencies" do
      ExBanking.create_user("user")

      expect(ExBanking.deposit("user", 1.00002, "RUR")).to eq({:ok, 1.0})
      expect(ExBanking.deposit("user", 2.00293, "RUR")).to eq({:ok, 3.0})

      expect(ExBanking.deposit("user", 10.0, "USD")).to eq({:ok, 10.0})
      expect(ExBanking.deposit("user", 20.0, "USD")).to eq({:ok, 30.0})

      expect(ExBanking.get_balance("user", "RUR")).to eq({:ok, 3.0})
      expect(ExBanking.get_balance("user", "USD")).to eq({:ok, 30.0})
    end
  end

  describe ".withdraw/3" do
    it "should return error with wrong user" do
      expect(ExBanking.withdraw(1, 10.0, "RUR")).to eq({:error, :wrong_arguments})
    end

    it "should return error with wrong amount" do
      expect(ExBanking.withdraw("user", -10.0, "RUR")).to eq({:error, :wrong_arguments})
    end

    it "should return error with wrong currency" do
      expect(ExBanking.withdraw("user", 10.0, :RUR)).to eq({:error, :wrong_arguments})
    end

    it "should return error if user does not exist" do
      expect(ExBanking.withdraw("user", 10.0, "RUR")).to eq({:error, :user_does_not_exist})
    end

    it "should return error if balance is less than amount" do
      ExBanking.create_user("user")

      expect(ExBanking.withdraw("user", 10.0, "RUR")).to eq({:error, :not_enough_money})
    end

    it "should return error if has a lot of requests" do
      ExBanking.create_user("user")

      with_mock(RateLimiter, [callable?: fn(_) -> false end]) do
        expect(ExBanking.withdraw("user", 10.0, "RUR")).to eq({:error, :too_many_requests_to_user})
      end
    end

    it "should decrease balance" do
      ExBanking.create_user("user")

      ExBanking.deposit("user", 20.0, "RUR")
      expect(ExBanking.withdraw("user", 10.0, "RUR")).to eq({:ok, 10.0})
      expect(ExBanking.get_balance("user", "RUR")).to eq({:ok, 10.0})

      ExBanking.deposit("user", 0.15, "USD")
      expect(ExBanking.withdraw("user", 0.11, "USD")).to eq({:ok, 0.04})
      expect(ExBanking.get_balance("user", "USD")).to eq({:ok, 0.04})
    end
  end

  describe ".get_balance/2" do
    it "should return error with wrong user" do
      expect(ExBanking.get_balance(1, "RUR")).to eq({:error, :wrong_arguments})
    end

    it "should return error with wrong currency" do
      expect(ExBanking.get_balance("user", :RUR)).to eq({:error, :wrong_arguments})
    end

    it "should return error if user does not exist" do
      expect(ExBanking.get_balance("user", "RUR")).to eq({:error, :user_does_not_exist})
    end

    it "should return error if has a lot of requests" do
      ExBanking.create_user("user")

      with_mock(RateLimiter, [callable?: fn(_) -> false end]) do
        expect(ExBanking.get_balance("user", "RUR")).to eq({:error, :too_many_requests_to_user})
      end
    end

    it "should return default balance" do
      ExBanking.create_user("user")

      expect(ExBanking.get_balance("user", "RUR")).to eq({:ok, 0.0})
      expect(ExBanking.get_balance("user", "USD")).to eq({:ok, 0.0})
    end

    it "should return real balance" do
      ExBanking.create_user("user")

      ExBanking.deposit("user", 0.15, "RUR")
      expect(ExBanking.get_balance("user", "RUR")).to eq({:ok, 0.15})

      ExBanking.deposit("user", 0.05, "USD")
      expect(ExBanking.get_balance("user", "USD")).to eq({:ok, 0.05})
    end
  end

  describe ".send/4" do
    it "should return error with wrong sender" do
      expect(ExBanking.send(1, "user", 10.0, "RUR")).to eq({:error, :wrong_arguments})
    end

    it "should return error with wrong recipient" do
      expect(ExBanking.send("user", 1, 10.0, "RUR")).to eq({:error, :wrong_arguments})
    end

    it "should return error with wrong amount" do
      expect(ExBanking.send("user", "user2", -10.0, "RUR")).to eq({:error, :wrong_arguments})
    end

    it "should return error with wrong currency" do
      expect(ExBanking.send("user", "user2", 10.0, :RUR)).to eq({:error, :wrong_arguments})
    end

    it "should return error when sender and recipient are the same" do
      expect(ExBanking.send("user", "user", 10.0, "RUR")).to eq({:error, :wrong_arguments})
    end

    it "should return error if sender does not exist" do
      expect(ExBanking.send("user", "user2", 10.0, "RUR")).to eq({:error, :sender_does_not_exist})
    end

    it "should return error if recipient does not exist" do
      ExBanking.create_user("user")

      expect(ExBanking.send("user", "user2", 10.0, "RUR")).to eq({:error, :receiver_does_not_exist})
    end

    it "should return error if balance is less than amount" do
      ExBanking.create_user("user")
      ExBanking.create_user("user2")

      expect(ExBanking.send("user", "user2", 10.0, "RUR")).to eq({:error, :not_enough_money})
    end

    it "should return error if sender has a lot of requests" do
      ExBanking.create_user("user")
      ExBanking.create_user("user2")

      {:ok, sender_pid} = Accounting.find_account("user")

      with_mock(RateLimiter, [callable?: fn(^sender_pid) -> false end]) do
        expect(ExBanking.send("user", "user2", 10.0, "RUR")).to eq({:error, :too_many_requests_to_sender})
      end
    end

    it "should return error if recipient has a lot of requests" do
      ExBanking.create_user("user")
      ExBanking.create_user("user2")

      ExBanking.deposit("user", 15.15, "RUR")

      {:ok, sender_pid} = Accounting.find_account("user")
      {:ok, recipient_pid} = Accounting.find_account("user2")

      with_mock(RateLimiter, [callable?: fn
          (^sender_pid) -> true
          (^recipient_pid) -> false
      end]) do
        expect(ExBanking.send("user", "user2", 10.0, "RUR")).to eq({:error, :too_many_requests_to_receiver})
      end
    end

    it "should decrease balance" do
      ExBanking.create_user("user")
      ExBanking.create_user("user2")

      ExBanking.deposit("user", 15.15, "RUR")

      expect(ExBanking.send("user", "user2", 11.11, "RUR")).to eq({:ok, 4.04, 11.11})
      expect(ExBanking.get_balance("user", "RUR")).to eq({:ok, 4.04})
      expect(ExBanking.get_balance("user2", "RUR")).to eq({:ok, 11.11})
    end
  end
end
