defmodule WhatCouldItCostWeb.PlayLiveTest do
  use WhatCouldItCostWeb.ConnCase

  def test_round(conn, input, expected_score) do
    {:ok, view, html} = live(conn, "/play/1001")

    # Product 1 actual price: £2.84
    assert html =~ "Blue Dragon"

    html =
      view
      |> element("form#price-form")
      |> render_submit(%{"price" => "#{input}"})

    assert html =~ ~r/Round Score.+#{expected_score} \/ 1000/
    assert html =~ ~r/Total Score.+#{expected_score}/
    assert html =~ "£2.84"
    assert html =~ "£#{input}"
  end

  test "submit answer £1 away", %{conn: conn} do
    test_round(conn, "1.84", 600)
  end

  test "submit answer £2.49 away", %{conn: conn} do
    test_round(conn, "0.60", 4)
  end

  test "submit answer £2.50 away", %{conn: conn} do
    test_round(conn, "0.59", 0)
  end
end
