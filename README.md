# carbon_postmark_adapter

This is luckyframework/carbon's adapter for Postmark: https://postmarkapp.com/

https://github.com/luckyframework/carbon

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     carbon_postmark_adapter:
       github: makisu/carbon_postmark_adapter
   ```

2. Run `shards install`

## Usage

Set your `POSTMARK_SERVER_TOKEN` inside `.env`

```
POSTMARK_SERVER_TOKEN=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

and update your `config/email.cr` file with:

```crystal
require "carbon_postmark_adapter"

BaseEmail.configure do |settings|
  if Lucky::Env.production?
    postmark_server_token = postmark_server_token_from_env
    settings.adapter = Carbon::PostmarkAdapter.new(server_token: postmark_server_token)
  else
    settings.adapter = Carbon::DevAdapter.new(print_emails: true)
  end
end

private def postmark_server_token_from_env
  ENV["POSTMARK_SERVER_TOKEN"]? || raise_missing_key_message
end

private def raise_missing_key_message
  puts "Missing POSTMARK_SERVER_TOKEN. Set the POSTMARK_SERVER_TOKEN env variable to '' if not sending emails, or set the POSTMARK_SERVER_TOKEN ENV var.".colorize.red
  exit(1)
end
```

## Contributing

1. Fork it (<https://github.com/your-github-user/carbon_postmark_adapter/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Xavi Ablaza](https://github.com/xaviablaza) - creator and maintainer
