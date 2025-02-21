import { algoliasearch } from "algoliasearch";
import { supabase } from "$lib/supabase";
export const client = algoliasearch(
  "SRC6WYM3HX",
  "068a9e612ca8a12b04aed09540882236",
);

export async function update_index() {
  const realTables = (await supabase.rpc("list_tables")).data;
  // work around to upload after everything gets processed
  const tables = [...realTables, { schema: "public", tablename: "empty" }];
  let algoliaObjects = [];
  tables.forEach(async (table, index, array) => {
    const data = (await supabase.from(table.tablename).select()).data.map(
      (row) => {
        return {
          objectID: row.id,
          ...row,
          table: table.tablename,
        };
      },
    );
    algoliaObjects = [...algoliaObjects, ...data];
    if (index === array.length - 1) {
      await client.saveObjects({
        indexName: "stuff",
        objects: algoliaObjects,
      });
    }
  });
}
