defmodule Singula.DibsPaymentMethod do
  defstruct [
    :dibs_ccPart,
    :dibs_ccPrefix,
    :dibs_ccType,
    :dibs_expM,
    :dibs_expY,
    :transactionId,
    :receipt,
    defaultMethod: true
  ]

  @type t :: %__MODULE__{}

  def new(transactionId, receipt, dibs_ccPart, dibs_ccPrefix, dibs_ccType, dibs_expM, dibs_expY) do
    %__MODULE__{
      transactionId: transactionId,
      receipt: receipt,
      dibs_ccPart: dibs_ccPart,
      dibs_ccPrefix: dibs_ccPrefix,
      dibs_ccType: dibs_ccType,
      dibs_expM: dibs_expM,
      dibs_expY: dibs_expY
    }
  end
end