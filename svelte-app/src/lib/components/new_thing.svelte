<script lang="ts">
	import { supabase } from "$lib/supabase";
	import { v4 as uuid } from "uuid";

	let data = $state({});
	let { table, selectedTable } = $props();

	async function add_thing() {
		await supabase.from(selectedTable).insert({ id: uuid(), ...data }),
			(data = {});
	}
</script>

<div id="options">
	{#each table.data as column}
		{#if column.type === "smallint"}
			<input
				type="number"
				placeholder={column.name}
				oninput={(e) => {
					if (e.target.value) {
						data[column.name] = e.target.value;
					} else {
						delete data[column.name];
					}
				}}
			/>
		{:else if column.name === "id"}{:else}
			<input
				type="text"
				placeholder={column.name}
				oninput={(e) => (data[column.name] = e.target.value)}
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
input[type=number], input[type=text]
  width:12rem
input:not([type=checkbox])
  margin-top: 1rem
  margin-left: 1rem
button 
  margin-left: 1rem

</style>
