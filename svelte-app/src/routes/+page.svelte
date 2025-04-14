<script lang="ts">
	import { update_index } from "$lib/util/algolia";
	import { client } from "$lib/util/algolia";
	import { auth, supabase } from "$lib/supabase";
	import type { SearchResponse } from "algoliasearch";
	import Login from "$lib/components/login.svelte";
	import NewColumn from "$lib/components/new_column.svelte";
	let selectedTable = $state("");
	let newTableName = $state("");
	let filters = $state({});
	let algoliaFilters = $state("");
	let algoliaResults = $state<Promise<SearchResponse<unknown>>>();
	let algoliaSearchText = $state("");
	async function newTable() {
		await supabase.rpc("create_table", {
			name: newTableName,
		});
		selectedTable = "";
	}
	$effect(() => {
		update_index();
		algoliaResults = client.searchSingleIndex({
			indexName: "stuff",
			searchParams: { filters: algoliaFilters, query: algoliaSearchText },
		});
	});
	$effect(() => {
		let tempFilters = "";
		Object.keys(filters).forEach(async (key) => {
			const filter = filters[key];
			if (filter[0]) {
				tempFilters += `${key} >= ${filter[0]} AND `;
			}
			if (filter[1]) {
				tempFilters += `${key} <= ${filter[1]} AND `;
			}
			// text filter
			if (filter.constructor === Object) {
				Object.keys(filter).forEach((k) => {
					if (filter[k]) tempFilters += `${key}:'${k}' OR `;
				});
			}
		});
		// workaround to bypass the OR statement from text statements
		if (selectedTable) {
			if (tempFilters.split("OR").pop() == " ")
				tempFilters = tempFilters.slice(0, -3) + "AND ";
			tempFilters += `table: ${selectedTable}`;
			algoliaFilters = tempFilters;
		} else algoliaFilters = "";
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
			<div id="options">
				{#each table.data as column}
					{#if column.type === "smallint"}
						{#if filters[column.name]?.[2]}
							<input
								type="number"
								placeholder={column.name + ": min"}
								class="number"
								oninput={(e) => {
									filters[column.name] = [
										e.target.value,
										filters[column.name]?.[1] || null,
										true,
									];
								}}
							/>
							<input
								type="number"
								placeholder={column.name + ": max"}
								class="number"
								oninput={(e) => {
									filters[column.name] = [
										filters[column.name]?.[0] || null,
										e.target.value,
										true,
									];
								}}
							/>
						{:else}
							<input
								type="number"
								placeholder={column.name}
								oninput={(e) => {
									if (e.target.value) {
										filters[column.name] = [
											e.target.value,
											e.target.value,
											filters[column.name]?.[2],
										];
									} else {
										delete filters[column.name];
									}
								}}
							/>
						{/if}

						<p>Range?</p>
						<input
							type="checkbox"
							class="rangecheck"
							oninput={(e) => {
								filters[column.name] = [
									null,
									null,
									filters[column.name]?.[2] ? false : true,
								];
							}}
						/>
					{:else if column.name === "name"}{:else if column.type === "text" && column.name !== "name"}
						<details class="dropdown">
							<summary>{column.name}</summary>
							<ul>
								{#await supabase
									.from(selectedTable)
									.select(column.name) then values}
									{#each [...new Set(values.data.map((val) => Object.keys(val).map((key) => val[key])[0]))] as value}
										<li>
											<label class="checkboxlabel">
												<input
													type="checkbox"
													class="checkbox"
													oninput={() => {
														if (!filters[column.name])
															filters[column.name] = {};
														filters[column.name][value] = filters[
															column.name
														]?.[value]
															? false
															: true;
													}}
												/>
												<p class="checkboxlabel">{value}</p></label
											>
										</li>
									{/each}
								{/await}
							</ul>
						</details>
					{:else if column.name === "id"}{:else}
						<input type="text" placeholder={column.name} />
					{/if}
				{/each}
			</div>
			<div class="searchdiv">
				{#if selectedTable !== "New thing type"}
					<input
						placeholder="search..."
						class="search"
						oninput={(e) => (algoliaSearchText = e.target.value)}
					/>
					{#if table.data[0]}
						<NewColumn {selectedTable} />
					{/if}
				{/if}
			</div>
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
#results 
  display: flex
  flex-wrap: wrap
  justify-content: center
.result_card
  width:16rem
  margin: 1rem
.searchdiv 
  display: flex
  place-content: space-between
  width: 100%
  flex-wrap: wrap
button
  margin-right: 1rem
#options
  display: flex 
  flex-direction: row
  flex-columns: 2
  flex-wrap: wrap
  align-items: center
input[type=number], input[type=text], select
  width:12rem
p:not(.checkboxlabel), select, input:not([type=checkbox]), button, h1, details
  margin-top: 1rem
  margin-left: 1rem
.header 
  display: flex
  align-items: center
.search 
  width: 21.5rem
.label 
  display: flex
  flex-direction: column
label > p 
  margin-bottom: -.5rem
label.checkboxlabel 
  display: flex
  align-items: center
.rangecheck
  margin-left: 1rem 
  margin-top: 0rem !important
input[type=checkbox]
  margin-top: .4rem
</style>
