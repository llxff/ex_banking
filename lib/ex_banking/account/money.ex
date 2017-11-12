defmodule ExBanking.Money do
  @spec round(number) :: number
  def round(value) when is_integer(value), do: value
  def round(value) when is_float(value), do: Float.round(value * 100) / 100
end
