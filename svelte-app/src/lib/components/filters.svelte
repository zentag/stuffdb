<script lang="ts">
	import { sharedState } from "$lib/shared.svelte";
	let selectedTable = $derived(sharedState.selectedTable);
	let filters: Filters = $state({});
	let { table, algoliaFilters = $bindable(), supabase } = $props();
	let tableData: Column[] = $derived(table.data);
	type Column = {
		name: string;
		type: string;
	};
	type Filters = {
		[key: string]:
			| [number | null, number | null, boolean]
			| { [key: string]: boolean };
	};
	$inspect(tableData);
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
					if (k === "true" || k === "false") tempFilters += `${key}:${k} OR `;
					//@ts-expect-error - this is because ts does not know we have checked that it is the object, not the array
					else if (filter[k]) tempFilters += `${key}:'${k}' OR `;
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
	function columnIsNumber(type: string) {
		if (
			type === "smallint" ||
			type === "integer" ||
			type === "bigint" ||
			type === "double precision" ||
			type === "numeric" ||
			type === "real"
		)
			return true;
		else return false;
	}
</script>

<div id="options">
	{#each tableData as column}
		{#if columnIsNumber(column.type)}
			{#if filters[column.name]?.[2]}
				<input
					type="number"
					placeholder={column.name + ": min"}
					class="number"
					oninput={(e) => {
						filters[column.name] = [
							Number((e.target as HTMLInputElement)?.value),
							Number(filters[column.name]?.[1]) || null,
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
							Number(filters[column.name]?.[0]) || null,
							Number((e.target as HTMLInputElement)?.value),
							true,
						];
					}}
				/>
			{:else}
				<input
					type="number"
					placeholder={column.name}
					oninput={(e) => {
						if ((e.target as HTMLInputElement)?.value) {
							filters[column.name] = [
								Number((e.target as HTMLInputElement)?.value),
								Number((e.target as HTMLInputElement)?.value),
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
				oninput={() => {
					filters[column.name] = [
						null,
						null,
						filters[column.name]?.[2] ? false : true,
					];
				}}
			/>
		{:else if column.type == "boolean"}
			<select
				oninput={(e) => {
					const value = (e.target as HTMLInputElement)?.value;
					if (value === "") delete filters[column.name];
					else if (value === "true") filters[column.name] = { true: true };
					else if (value === "false") filters[column.name] = { false: true };
				}}
			>
				<option value="" disabled selected>{column.name}</option>
				<option>true</option>
				<option>false</option>
				<option value="">either</option>
			</select>
		{:else if column.name === "name"}{:else if column.type === "text" && column.name !== "name"}
			<details class="dropdown">
				<summary>{column.name}</summary>
				<ul>
					{#await supabase.from(selectedTable).select(column.name) then values}
						{#each [...new Set(values.data.map((val: { [key: string]: string }) => Object.keys(val).map((key) => val[key])[0]))] as value}
							<li>
								<label class="checkboxlabel">
									<input
										type="checkbox"
										class="checkbox"
										oninput={() => {
											if (!filters[column.name]) filters[column.name] = {};
											// @ts-expect-error - ts can't understand that we're using a set to get unique values, and that value will always be a string.
											filters[column.name][value] = // @ts-expect-error
												filters[column.name]?.[value] ? false : true;
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
input[type=number], input[type=text], select
  width:12rem
p:not(.checkboxlabel), input:not([type=checkbox]), details, select
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
