<script lang="ts">
	import { client } from "$lib/util/algolia";
	import { auth, supabase } from "$lib/supabase";
	import type { SearchResponse } from "algoliasearch";
	import Login from "$lib/components/login.svelte";
	import Filters from "$lib/components/filters.svelte";
	import NewColumn from "$lib/components/new_column.svelte";
	import NewThing from "$lib/components/new_thing.svelte";
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

{#await auth.getUser() then user}
	{#if user.data.user}
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
					<NewThing {table} {selectedTable} />
				{:else}
					<Filters {table} bind:algoliaFilters {selectedTable} />
				{/if}
				<hr id="up" />
				<div class="searchdiv">
					<input
						placeholder="search..."
						class="search"
						oninput={(e) => (algoliaSearchText = e.target.value)}
					/>
					{#if table.data[0]}
						<NewColumn bind:selectedTable />
					{/if}
				</div>
				<hr />
			{/if}
		{/await}
	{:else}
		<h1>StuffDB</h1>
		<Login />
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
						<article class="result_card">
							<h4>{hit.name || hit.table}</h4>
							{#each Object.keys(hit) as key}
								{#if key !== "_highlightResult" && key !== "name" && key !== "objectID" && key !== "id" && (key !== "table" || selectedTable == "")}
									<p><b>{key}:</b> {hit[key]}</p>
								{/if}
							{/each}
						</article>
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
.result_card
  width:16rem
  margin: 1rem
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
