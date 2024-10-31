import Config

config :crawly,
  closespider_timeout: 5,
  concurrent_requests_per_domain: 1,
  closespider_itemcount: 100,
  middlewares: [
    Crawly.Middlewares.DomainFilter,
    Crawly.Middlewares.UniqueRequest,
    {Crawly.Middlewares.UserAgent, user_agents: ["Crawly Bot"]}
  ],
  pipelines: [
    {Crawly.Pipelines.Validate, fields: [:name]},
    {Crawly.Pipelines.DuplicatesFilter, item_id: :name},
    Crawly.Pipelines.JSONEncoder,
    {Crawly.Pipelines.WriteToFile, extension: "jl", folder: "./data"}
  ]
