# StuffDB

## Status: WIP

Right now it's just a frontend to algolia and supabase.
Also, you must refresh several times to update the algolia index (having the item show in results)

### TODO:

- [x] Make values in new_thing.svelte dissapear after add
- [ ] Make an API page to refresh the aglolia index: make components that update the db fetch this page
- [ ] Rewrite result.svelte so that it knows what the column type is when editing (using supabase get_cols() results that can be passed from main page)
- [ ] Add delete button to result.svelte
- [ ] Fix mobile interface

### Setup (local)

- Open a supabase account. The free tier will work, but just keep in mind you will need to visit the dashboard to unpause your project if it's inactive for a week.
  - Create a free organization
  - Create a project within the organization
  - Click the gear on the left side
  - Click 'Data API' under the 'CONFIGURATION' header
  - Copy your project credentials (App ID and public key (formerly known as anon key))
  - Paste them into the file titled `.env` in the `svelte-app` folder of this project (there will be slots indicated in the file)
  - Click `Authentication` on the left side
  - Click the green `Add user` button and click `Create new user`
  - Make a user with email and password - This is necessary to access data
  - Click `Sign in / Sign Up` under `Configuration` in the `Authentication` menu on the left
  - Disable signup for new users - This is necessary for security
  - Save changes
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
  - Paste the app ID into the file titled `.env` in the `svelte-app` folder of this project (there will be slots indicated in the file)
  - Create an .env.local file with the same and write `PRIVATE_ALGOLIA_ADMIN_KEY="your key here"`, making sure to use your key in the quotes NEVER SHARE OR PUBLISH THIS KEY
- Start the app!
  - In your terminal (with [pnpm](https://pnpm.io/) installed), run `pnpm i && pnpm build && pnpm preview`
- Finish configuration
  - Go to algolia's dashboard homepage, and click API Keys
    ![An image highlighting which button to click on the dashboard](https://github.com/zentag/stuffdb/blob/main/docs/images/algolia_api_keys.png?raw=true)
  - Copy the search only key and paste it into the .env file
  - Still on the Algolia dashboard, click `Search` on the left menu
  - Click `Configuration` near the middle of your screen
  - Set your attributes that can be searched with algolia here (recommended are `name` and `description`)
  - Click `Review and Save Settings` at the bottom right of your screen

### Strange quirks

- Using `text` type columns offers a dropdown select for filters, while using `varchar` defaults to using custom values (text is for often duplicated values, while varchar is for unique)
  **You cannot:**
- Name a column `true` or `false`

### Contributing

I'm open to contributions. Add anything you want and push it - I'll probably accept it with a quick review.

### Support

I'm happy to help anyone out. Just shoot me a message on github.
