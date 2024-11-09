defmodule WhatCouldItCost.Scrape do
  use Crawly.Spider

  @impl Crawly.Spider
  def base_url(), do: "https://www.trolley.co.uk/"

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
        img_url = Floki.find(x, "._product-img > img") |> Floki.attribute("src") |> Enum.at(0)
        product_id = String.split(img_url, "/", trim: true) |> List.last()

        %{
          # The title element contains a span, and a direct text node.
          # The span has the brand name, the direct text contains the product name
          # We can't select the direct text node directly, so we do some funky string stuff to extract just the product name
          name:
            Floki.find(x, "._title")
            |> Floki.text(sep: "|||")
            |> String.split("|||")
            |> List.last()
            |> String.trim(" "),
          brand: Floki.find(x, "._title > span") |> Floki.text() |> String.trim(" "),
          prev_price:
            Floki.find(document, "tr.product_#{product_id} td:nth-child(3)")
            # Take the first 4 store entries, which should be Asda, Tesco, Sainburys, and Morrisons.
            # We ignore all the others as they aren't always there, or contain outliers
            |> Enum.take(4)
            |> Enum.map(fn y ->
              y
              |> Floki.text()
              |> String.trim(" ")
              |> String.trim("£")
              |> Decimal.parse()
              |> elem(0)
            end)
            |> Enum.reduce(&Decimal.add(&1, &2))
            |> Decimal.div(Decimal.new(4))
            |> Decimal.round(2)
            |> Decimal.to_string(:normal),
          price:
            Floki.find(document, "tr.product_#{product_id} td:nth-child(4)")
            # Take the first 4 store entries, which should be Asda, Tesco, Sainburys, and Morrisons.
            # We ignore all the others as they aren't always there, or contain outliers
            |> Enum.take(4)
            |> Enum.map(fn y ->
              y
              |> Floki.text()
              |> String.trim(" ")
              |> String.trim("£")
              |> Decimal.parse()
              |> elem(0)
            end)
            |> Enum.reduce(&Decimal.add(&1, &2))
            |> Decimal.div(Decimal.new(4))
            |> Decimal.round(2)
            |> Decimal.to_string(:normal),
          product_id: product_id
        }
      end)

    %Crawly.ParsedItem{items: items, requests: []}
  end
end
