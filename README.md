# What Could It Cost?

What Could It Cost? is a simple web game where you try to guess how much a random grocery store product costs. Think "The Price is Right" vibes.

## Data

Product data is scraped from [trolley.co.uk](https://www.trolley.co.uk/), which compares prices for common grocery items between UK supermarkets. We take the average price of all the supermarkets as our price you are trying to guess.

## Commands

```sh
# Download deps
mix deps.get

# Download & setup deps (first time)
mix setup

# Start the server
mix phx.server

# Scrape data to ./data dir
iex -S mix run -e "Crawly.Engine.start_spider(WhatCouldItCost.Scrape)"
```
