defmodule TxtLocalEx.Errors.ApiError do
  defexception [:reason]

  def exception(reason),
    do: %__MODULE__{reason: reason}

  def message(%__MODULE__{reason: reason}),
    do: "TxtLocalEx::ApiError - #{reason}"
end
