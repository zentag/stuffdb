<script lang="ts">
	import type { PageData } from "./$types";
	import { client } from "$lib/util/algolia";
	import type { SearchResponse } from "algoliasearch";
	import Filters from "$lib/components/filters.svelte";
	import NewColumn from "$lib/components/new_column.svelte";
	import NewThing from "$lib/components/new_thing.svelte";
	import Result from "$lib/components/result.svelte";
	let { data }: { data: PageData } = $props();
	let { supabase } = $derived(data);
	let selectedTable = $state("");
	let newTableName = $state("");
	let algoliaFilters = $state("");
	let algoliaResults = $state<Promise<SearchResponse<unknown>>>();
	let algoliaSearchText = $state("");
	let showNewThing = $state(false);
	async function newTable() {
		await supabase.rpc("create_table", {
			name: newTableName,
		});
		selectedTable = "";
	}
	$effect(() => {
		algoliaResults = client.searchSingleIndex({
			indexName: "stuff",
			searchParams: { filters: algoliaFilters, query: algoliaSearchText },
		});
	});
</script>

{#await supabase.rpc("list_tables" + selectedTable.slice(0, 0) /*This is to make this update on selected table change*/) then tables}
	<div class="header">
		<h1>StuffDB</h1>
		<select
			name="select"
			aria-label="select thing type..."
			bind:value={selectedTable}
		>
			<option selected value="">all</option>
			{#each tables.data as table}
				<option>
					{table.tablename.split("_").join(" ")}
				</option>
			{/each}
			<option>New thing type</option>
		</select>
	</div>
{/await}
{#await supabase.rpc("get_cols", { tablename: selectedTable }) then table}
	{#if selectedTable !== "New thing type"}
		{#if selectedTable !== ""}
			<div role="group" class="group">
				<input
					value="Filters"
					type="button"
					class={showNewThing ? "outline" : ""}
					onclick={() => (showNewThing = false)}
				/>
				<input
					value="Add New Thing"
					type="button"
					class={showNewThing ? "" : "outline"}
					onclick={() => (showNewThing = true)}
				/>
			</div>
		{/if}
		{#if showNewThing}
			<NewThing {table} {selectedTable} {supabase} />
		{:else}
			<Filters {supabase} {table} bind:algoliaFilters {selectedTable} />
		{/if}
		<hr id="up" />
		<div class="searchdiv">
			<input
				placeholder="search..."
				class="search"
				oninput={(e) => (algoliaSearchText = e.target.value)}
			/>
			{#if selectedTable !== "New thing type" && selectedTable !== ""}
				<NewColumn {supabase} bind:selectedTable />
			{/if}
		</div>
		<hr />
	{/if}
{/await}
{#if selectedTable == "New thing type"}
	<form onsubmit={newTable}>
		<label class="label">
			<p>Name of thing type:</p>
			<input type="text" bind:value={newTableName} />
		</label>
		<button>Submit</button>
	</form>
{/if}
<div>
	{#if selectedTable !== "New thing type"}
		{#await algoliaResults then res}
			{#if res?.hits}
				<div id="results">
					{#each res.hits as hit}
						<Result {hit} {selectedTable} />
					{/each}
				</div>
			{/if}
		{/await}
	{/if}
</div>

<style lang="sass">
.group
  margin-left: 1rem 
  width: auto
#results 
  display: flex
  flex-wrap: wrap
  justify-content: center
form > button 
 margin-left: 1rem
.searchdiv 
  display: flex
  place-content: space-between
  width: 100%
  flex-wrap: wrap
  padding-left: 1rem
button
  margin-right: 1rem
.header 
  display: flex
  margin-top: 1rem
  margin-left: 1rem
  align-items: center
.search 
  width: 21.5rem
.label 
  display: flex
  flex-direction: column
  margin-left: 1rem
label > p 
  margin-bottom: 0rem
select 
 width: 12rem
 margin-left: 1rem
hr 
  width: auto
  margin-left: 1rem
  margin-right: 1rem
hr#up 
  margin-top: 0
</style>
