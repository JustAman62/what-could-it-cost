# What Could It Cost?

What Could It Cost? is a simple web game where you try to guess how much a random grocery store product costs. Think "The Price is Right" vibes.

Play it now at [whatcoulditcost.amandhoot.com](https://whatcoulditcost.amandhoot.com).

## Data

Product data is scraped from [trolley.co.uk](https://www.trolley.co.uk/)'s Grocery Price Index, which compares prices for common grocery items between UK supermarkets. We take the average price of all the supermarkets listed as the actual price are trying to guess.

## How it Works

All games are 5 rounds long, and have a seed. The seed is used to seed the RNG which picks which products are chosen for the game. This means the 5 products chosen are deterministic by the seed, so that multiple players can play the same game.

Daily games have a seed calculated as the number of days since the 1st October 2024, plus an offset of 1000 days.

Scoring is determined on how far your guess is from the actual price. If you're bang-on, then you'll receive 1000 points. Every penny you are away from the price, you lose 4 points. Once you are £2.50 away from the price, you receive 0 points.

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
