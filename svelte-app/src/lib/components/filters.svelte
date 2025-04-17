<script lang="ts">
	import { supabase } from "$lib/supabase";

	let filters = $state({});
	let { table, algoliaFilters = $bindable(), selectedTable } = $props();

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
					{#await supabase.from(selectedTable).select(column.name) then values}
						{#each [...new Set(values.data.map((val) => Object.keys(val).map((key) => val[key])[0]))] as value}
							<li>
								<label class="checkboxlabel">
									<input
										type="checkbox"
										class="checkbox"
										oninput={() => {
											if (!filters[column.name]) filters[column.name] = {};
											filters[column.name][value] = filters[column.name]?.[
												value
											]
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

<style lang="sass">

#options
  display: flex 
  flex-direction: row
  flex-columns: 2
  flex-wrap: wrap
  align-items: center
input[type=number], input[type=text]
  width:12rem
p:not(.checkboxlabel), input:not([type=checkbox]), details
  margin-top: 1rem
  margin-left: 1rem
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
