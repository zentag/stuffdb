import { algoliasearch } from "algoliasearch";
import {
  PUBLIC_ALGOLIA_APP_ID,
  PUBLIC_ALGOLIA_SEARCH_ONLY_KEY,
} from "$env/static/public";
export const client = algoliasearch(
  PUBLIC_ALGOLIA_APP_ID,
  PUBLIC_ALGOLIA_SEARCH_ONLY_KEY,
);
