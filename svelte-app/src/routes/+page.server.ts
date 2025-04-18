import type { PageServerLoad } from "./$types";
import { PUBLIC_ALGOLIA_APP_ID } from "$env/static/public";
import { PRIVATE_ALGOLIA_ADMIN_KEY } from "$env/static/private";
import { algoliasearch } from "algoliasearch";
export const load: PageServerLoad = async ({ locals: { supabase } }) => {
  const client = algoliasearch(
    PUBLIC_ALGOLIA_APP_ID,
    PRIVATE_ALGOLIA_ADMIN_KEY,
  );
  const realTables = (await supabase.rpc("list_tables")).data;
  // work around to upload after everything gets processed
  const tables = [...realTables];
  let algoliaObjects = [];
  let facetAttributes = [];
  tables.forEach(async (table, index, array) => {
    const data = (await supabase.from(table.tablename).select()).data?.map(
      (row) => {
        facetAttributes = [...facetAttributes, ...Object.keys(row)];
        return {
          objectID: row.id,
          ...row,
          table: table.tablename,
        };
      },
    );
    if (!data) return;
    algoliaObjects = [...algoliaObjects, ...data];
    if (index === array.length - 1) {
      const indexResponse = await client.saveObjects({
        indexName: "stuff",
        objects: algoliaObjects,
      });
      const facetAttributesFiltered = [
        "table",
        ...new Set(
          facetAttributes.filter((attr) => {
            if (attr === "name" || attr === "id") return false;
            else return true;
          }),
        ),
      ];
      const settingsResponse = await client.setSettings({
        indexName: "stuff",
        indexSettings: { attributesForFaceting: facetAttributesFiltered },
      });
      return { supabase, indexResponse, settingsResponse };
    }
  });
};
