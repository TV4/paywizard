defmodule Singula.ItemTest do
  use ExUnit.Case, async: true
  alias Singula.Item

  test "ppv" do
    payload = %{
      "active" => true,
      "categoryId" => 213,
      "description" => "PPV - 249",
      "entitlements" => [%{"id" => 5961, "name" => "Matchbiljett 249 kr"}],
      "itemId" => "A2D895F14D6B4F2DA03C",
      "itemType" => "PPV",
      "name" => "PPV - 249",
      "pricing" => %{"oneOff" => %{"amount" => "149.00", "currency" => "SEK"}}
    }

    assert Item.new(payload) == %Item{
             id: "A2D895F14D6B4F2DA03C",
             currency: :SEK,
             category_id: 213,
             name: "PPV - 249",
             entitlements: [%Singula.Entitlement{id: 5961, name: "Matchbiljett 249 kr"}],
             one_off_price: "149.00",
             active: true
           }
  end

  test "service with free trial" do
    payload = %{
      "active" => true,
      "categoryId" => 101,
      "description" => "C More TV4",
      "entitlements" => [%{"id" => 5960, "name" => "C More TV4"}],
      "freeTrial" => %{"active" => true, "numberOfDays" => 14},
      "itemId" => "6D3A56FF5065478ABD61",
      "itemType" => "SERVICE",
      "name" => "C More TV4",
      "pricing" => %{
        "frequency" => %{"frequency" => "MONTH", "length" => 1},
        "initial" => %{"amount" => "0.00", "currency" => "SEK"},
        "recurring" => %{"amount" => "139.00", "currency" => "SEK"}
      }
    }

    assert Item.new(payload) == %Item{
             id: "6D3A56FF5065478ABD61",
             currency: :SEK,
             category_id: 101,
             name: "C More TV4",
             entitlements: [%Singula.Entitlement{id: 5960, name: "C More TV4"}],
             recurring_billing: %{amount: "139.00", month_count: 1},
             free_trial: %Singula.FreeTrial{number_of_days: 14},
             active: true
           }
  end

  test "service with minimum term" do
    payload = %{
      "active" => true,
      "categoryId" => 226,
      "description" =>
        "Field Sales - All Sport 12 months for 199 SEK and then 12 months (rest of subscruption) for 399 SEK. ",
      "entitlements" => [%{"id" => 5963, "name" => "C More All Sport"}],
      "itemId" => "4FC7D926073348038362",
      "itemType" => "SERVICE",
      "minimumTerm" => %{"frequency" => "MONTH", "length" => 24},
      "name" => "Field Sales - All Sport 12 plus 12",
      "pricing" => %{
        "frequency" => %{"frequency" => "MONTH", "length" => 1},
        "initial" => %{"amount" => "0.00", "currency" => "SEK"},
        "recurring" => %{"amount" => "399.00", "currency" => "SEK"}
      }
    }

    assert Item.new(payload) == %Item{
             id: "4FC7D926073348038362",
             currency: :SEK,
             category_id: 226,
             name: "Field Sales - All Sport 12 plus 12",
             entitlements: [%Singula.Entitlement{id: 5963, name: "C More All Sport"}],
             recurring_billing: %{amount: "399.00", month_count: 1},
             minimum_term_month_count: 24,
             active: true
           }
  end

  test "service with initial price" do
    payload = %{
      "active" => true,
      "categoryId" => 226,
      "description" =>
        "Field Sales - All Sport 12 months for 199 SEK and then 12 months (rest of subscription) for 399 SEK and Apple TV full price (1990 SEK). ",
      "entitlements" => [%{"id" => 5963, "name" => "C More All Sport"}],
      "itemId" => "8FB4E247D57B40E09FA7",
      "itemType" => "SERVICE",
      "minimumTerm" => %{"frequency" => "MONTH", "length" => 24},
      "name" => "Field Sales - All Sport 12 plus 12 Apple TV full price",
      "pricing" => %{
        "frequency" => %{"frequency" => "MONTH", "length" => 1},
        "initial" => %{"amount" => "1990.00", "currency" => "SEK"},
        "recurring" => %{"amount" => "399.00", "currency" => "SEK"}
      }
    }

    assert Item.new(payload) == %Item{
             id: "8FB4E247D57B40E09FA7",
             currency: :SEK,
             category_id: 226,
             name: "Field Sales - All Sport 12 plus 12 Apple TV full price",
             entitlements: [%Singula.Entitlement{id: 5963, name: "C More All Sport"}],
             recurring_billing: %{amount: "399.00", month_count: 1},
             one_off_price: "1990.00",
             minimum_term_month_count: 24,
             active: true
           }
  end

  test "service without entitlements" do
    payload = %{
      "active" => true,
      "categoryId" => 275,
      "description" => "C More - TVE",
      "itemId" => "9AB5E7C5C9FE4B55AAA4",
      "itemType" => "SERVICE",
      "minimumTerm" => %{"frequency" => "MONTH", "length" => 1},
      "name" => "C More - TVE",
      "pricing" => %{
        "frequency" => %{"frequency" => "MONTH", "length" => 1},
        "initial" => %{"amount" => "0.00", "currency" => "SEK"},
        "recurring" => %{"amount" => "0.00", "currency" => "SEK"}
      }
    }

    assert Item.new(payload) == %Item{
             category_id: 275,
             currency: :SEK,
             entitlements: [],
             free_trial: nil,
             id: "9AB5E7C5C9FE4B55AAA4",
             minimum_term_month_count: 1,
             name: "C More - TVE",
             one_off_price: nil,
             recurring_billing: %{amount: "0.00", month_count: 1},
             active: true
           }
  end
end
