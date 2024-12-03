defmodule WhatCouldItCostWeb.PlayLiveTest do
  use WhatCouldItCostWeb.ConnCase

  def test_round_cheap_product(conn, input, expected_score) do
    {:ok, view, html} = live(conn, ~p"/play/1001")

    assert html =~ "Babybel"

    html =
      view
      |> element("form#price-form")
      |> render_submit(%{"price" => "#{input}"})

    assert html =~ ~r/Round Score.+#{expected_score} \/ 1000/
    assert html =~ ~r/Total Score.+#{expected_score}/
    assert html =~ "£2.38"
    assert html =~ "£#{input}"
  end

  test "cheap product submit exact answer", %{conn: conn} do
    test_round_cheap_product(conn, "2.38", 1000)
  end

  test "cheap product submit answer £1.25 lower", %{conn: conn} do
    test_round_cheap_product(conn, "1.13", 500)
  end

  test "cheap product submit answer £1.25 higher", %{conn: conn} do
    test_round_cheap_product(conn, "3.63", 500)
  end

  test "cheap product submit answer £2.50 higher", %{conn: conn} do
    test_round_cheap_product(conn, "4.88", 0)
  end

  def test_round_expensive_product(conn, input, expected_score) do
    {:ok, view, html} = live(conn, ~p"/play/1006")

    assert html =~ "Martini"

    html =
      view
      |> element("form#price-form")
      |> render_submit(%{"price" => "#{input}"})

    assert html =~ ~r/Round Score.+#{expected_score} \/ 1000/
    assert html =~ ~r/Total Score.+#{expected_score}/
    assert html =~ "£11.56"
    assert html =~ "£#{input}"
  end

  test "expensive produce submit exact answer", %{conn: conn} do
    test_round_expensive_product(conn, "11.56", 1000)
  end

  test "expensive produce submit answer 12.5% lower", %{conn: conn} do
    test_round_expensive_product(conn, "10.12", 502)
  end

  test "expensive produce submit answer 12.5% higher", %{conn: conn} do
    test_round_expensive_product(conn, "13.00", 502)
  end

  test "expensive produce submit answer 25% lower", %{conn: conn} do
    test_round_expensive_product(conn, "8.67", 0)
  end

  test "expensive produce submit answer 25% higher", %{conn: conn} do
    test_round_expensive_product(conn, "14.45", 0)
  end

  test "expensive produce submit answer extremely higher", %{conn: conn} do
    test_round_expensive_product(conn, "1400.40", 0)
  end
end
