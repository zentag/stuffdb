import { error } from "@sveltejs/kit";
import type { PageServerLoad } from "./$types";
import { algoliasearch } from "algoliasearch";
import { supabase } from "$lib/supabase";

export const load: PageServerLoad = async ({ params }) => {
  const client = algoliasearch(
    import.meta.env.VITE_ALGOLIA_APP_ID,
    import.meta.env.VITE_ALGOLIA_ADMIN_KEY,
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
      await client.saveObjects({
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
      await client.setSettings({
        indexName: "stuff",
        indexSettings: { attributesForFaceting: facetAttributesFiltered },
      });
    }
  });
};
