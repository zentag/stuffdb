<script lang="ts">
	import { v4 as uuid } from "uuid";
	import { sharedState } from "$lib/shared.svelte";
	import ErrorModal from "./error_modal.svelte";
	let selectedTable = $derived(sharedState.selectedTable);
	let data: { [key: string]: number | string | boolean | undefined } = $state(
		{},
	);
	let useCustom: { [key: string]: boolean } = $state({});
	let { table, supabase } = $props();
	let tableData: { name: string; type: string }[] = table.data;
	let dialogOpen = $state(false);
	let errorMsg = $state("");
	$effect(() => {
		tableData.forEach((column) => {
			if (data[column.name] == "Use value not on list") {
				useCustom[column.name] = true;
				data[column.name] = "";
			}
			if (data[column.name] === undefined && column.type === "boolean")
				data[column.name] = false;
		});
	});
	async function add_thing() {
		if (Object.keys(data).length !== 0) {
			const res = await supabase
				.from(selectedTable)
				.insert({ id: uuid(), ...data });
			if (res.error) {
				dialogOpen = true;
				errorMsg = res.error.message;
			}
		}

		data = {};
		let savedSelectedTable = sharedState.selectedTable;
		sharedState.selectedTable = "";
		sharedState.selectedTable = savedSelectedTable;
	}
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

<ErrorModal bind:dialogOpen {errorMsg} />
<div id="options">
	{#each tableData as column}
		{#if columnIsNumber(column.type)}
			<input
				type="number"
				placeholder={column.name}
				bind:value={data[column.name]}
			/>
		{:else if column.type == "boolean"}
			<select
				oninput={(e) => {
					const value = (e.target as HTMLInputElement)?.value;

					if (value == "") {
						data[column.name] = undefined;
					}
				}}
			>
				<option value="" disabled selected>{column.name}</option>
				<option>true</option>
				<option>false</option>
				<option value="">don't define</option>
			</select>
		{:else if column.name === "id"}{:else if column.type == "text"}
			{#if useCustom[column.name]}
				<input
					type="text"
					placeholder={column.name}
					bind:value={data[column.name]}
				/>
			{:else}
				<select aria-label={column.name} bind:value={data[column.name]}>
					<option selected disabled value="">{column.name}</option>
					{#await supabase.from(selectedTable).select(column.name) then values}
						{#each [...new Set(values.data.map((val: { [key: string]: boolean }) => Object.keys(val).map((key) => val[key])[0]))] as value}
							{#if value && value !== ""}
								<option>
									{value}
								</option>
							{/if}
						{/each}
					{/await}
					<option value={null}>None</option>
					<option>Use value not on list</option>
				</select>
			{/if}
		{:else}
			<input
				type="text"
				placeholder={column.name}
				bind:value={data[column.name]}
			/>
		{/if}
	{/each}
	<button onclick={add_thing}>Add</button>
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
input:not([type=checkbox]), select
  margin-top: 1rem
  margin-left: 1rem
button 
  margin-left: 1rem

</style>
