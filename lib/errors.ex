defmodule TxtLocalEx.Errors.ApiError do
  defexception [:reason, :args]

  def exception(reason, args), do: %__MODULE__{reason: reason, args: args}

  def message(%__MODULE__{reason: reason}), do: "TxtLocalEx::ApiError - #{reason}"
end

defmodule TxtLocalEx.Errors.ApiLimitExceeded do
  defexception [:reason, :args]

  def exception(reason, args), do: %__MODULE__{reason: reason, args: args}

  def message(%__MODULE__{reason: reason}), do: "TxtLocalEx::ApiLimitExceeded - #{reason}"
end
