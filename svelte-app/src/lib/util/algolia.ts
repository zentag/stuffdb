import { algoliasearch } from "algoliasearch";

export const client = algoliasearch(
  import.meta.env.VITE_ALGOLIA_APP_ID,
  import.meta.env.VITE_ALGOLIA_SEARCH_ONLY_API_KEY,
);
