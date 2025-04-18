<script lang="ts">
	import { v4 as uuid } from "uuid";

	let data = $state({});
	let { table, selectedTable, supabase } = $props();

	async function add_thing() {
		await supabase.from(selectedTable).insert({ id: uuid(), ...data });
		data = {};
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
		{:else if column.name === "id"}{:else if column.type == "text"}
			{#if data[column.name] == "Value not on list"}
				<input
					type="text"
					placeholder={column.name}
					oninput={(e) => (data[column.name] = e.target.value)}
				/>
			{:else}
				<select aria-label={column.name} bind:value={data[column.name]}>
					<option selected disabled value="">{column.name}</option>
					{#await supabase.from(selectedTable).select(column.name) then values}
						{#each [...new Set(values.data.map((val) => Object.keys(val).map((key) => val[key])[0]))] as value}
							<option>
								{value}
							</option>
						{/each}
					{/await}
					<option>None</option>
					<option>Value not on list</option>
				</select>
			{/if}
		{:else}
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
input[type=number], input[type=text], select
  width:12rem
input:not([type=checkbox]), select
  margin-top: 1rem
  margin-left: 1rem
button 
  margin-left: 1rem

</style>
