# StuffDB

Right now it's just a frontend to algolia and supabase... I'll update soon with functionality for things like WLED to locate stuff.

## Setup (local)

- Open a supabase account. The free tier will work, but just keep in mind you will need to visit the dashboard to unpause your project if it's inactive for a week.
  - Find your project credentials (App ID and public key (formerly known as anon key))
  - Paste them into the file titled `.env` in the root of this project (there will be slots indicated in the file)
- Setup your postgres database by visiting the supabase SQL editor and pasting the sql from [setup.sql](https://raw.githubusercontent.com/zentag/stuffdb/refs/heads/main/setup.sql)
- Open an algolia account
  - Select "yes" when it asks if you write code
  - Select "no, I don't use these" when it asks about platforms
  - Select "other" in industry selections
  - Select "product search" in usecase selections
  - Select "code (connect with API)" to import data
  - Select JavaScript in API language selection
  - Scroll down to the code snipped, and find the following line
    `const client = algoliasearch('<YOUR ALGOLIA APP ID HERE>', '<YOUR ALGOLIA KEY HERE>');`
  - Copy the app ID and key
  - Paste them into the file titled `.env` in the root of this project (there will be slots indicated in the file)
- Start the app!
  - In your terminal (with [pnpm](https://pnpm.io/) installed), run `pnpm i && pnpm build && pnpm preview`

## Contributing

I'm open to contributions. Add anything you want and push it - I'll probably accept it with a quick review.

## Support

I'm happy to help anyone out. Just shoot me a message on github.
