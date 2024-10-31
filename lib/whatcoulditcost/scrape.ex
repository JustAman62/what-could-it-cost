defmodule WhatCouldItCost.Scrape do
  use Crawly.Spider

  @impl Crawly.Spider
  def base_url(), do: "https://www.trolley.co.uk//"

  @impl Crawly.Spider
  def init() do
    urls =
      Enum.map(1..100, fn i ->
        "https://www.trolley.co.uk/grocery-price-index/?ajax_product=1&page=#{i}"
      end)
      |> IO.inspect(label: "start_urls")
      |> Enum.to_list()

    [start_urls: urls]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    # Parse response body to document
    {:ok, document} = Floki.parse_document(response.body)

    # Create item (for pages where items exists)
    items =
      document
      |> Floki.find("tr.tr:not(.-store)")
      |> Enum.map(fn x ->
        %{
          name: Floki.find(x, "._title") |> Floki.text() |> String.trim(" "),
          brand: Floki.find(x, "._title > span") |> Floki.text() |> String.trim(" "),
          price: Floki.find(x, "td:nth-child(4)") |> Floki.text() |> String.trim(" ") |> String.trim("£"),
          img: Floki.find(x, "._product-img > img") |> Floki.attribute("src") |> Enum.at(0)
        }
      end)

    %Crawly.ParsedItem{items: items, requests: []}
  end
end
