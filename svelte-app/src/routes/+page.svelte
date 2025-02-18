<script lang="ts">
	import { auth, supabase } from "$lib/supabase";
	import Login from "$lib/components/login.svelte";
	const defaultTableSelect = "Select thing type...";
	let selectedTable = $state("");
	let newTableName = $state("");
	async function newTable() {
		await supabase.rpc("create_table", {
			name: newTableName,
		});
		selectedTable = "";
	}
</script>

<h1>StuffDB</h1>
{#await auth.getUser() then user}
	{#if user.data.user}
		{#await supabase.rpc("list_tables" + selectedTable.slice(0, 0)) then tables}
			<select
				name="select"
				aria-label="select thing type..."
				bind:value={selectedTable}
			>
				<option selected disabled value="">select thing type... </option>
				{#each tables.data as table}
					<option>
						{table.tablename.split("_").join(" ")}
					</option>
				{/each}
				<option>New thing type</option>
			</select>
		{/await}
		{#await supabase.rpc("get_cols", { tablename: selectedTable }) then table}
			<div id="options">
				{#each table.data as column}
					{#if column.type === "smallint"}
						<input type="number" placeholder={column.name + ": min"} />
						<input type="number" placeholder={column.name + ": max"} />
					{:else if column.type === "text" && column.name !== "name"}
						<select name={column.name} aria-label={column.name}>
							<option selected disabled value="">{column.name}</option>
							{#await supabase
								.from(selectedTable)
								.select(column.name) then values}
								{#each values.data as value}
									<option>{value[column.name]}</option>
								{/each}
							{/await}
						</select>
					{:else if column.name === "id"}{:else}
						<input type="text" placeholder={column.name} />
					{/if}
				{/each}
			</div>
			{#if table.data[0]}
				<button>New column</button>
			{/if}
		{/await}
	{:else}
		<Login />
	{/if}
{/await}
{#if selectedTable == "New thing type"}
	<form onsubmit={newTable}>
		<label>
			Name of thing type:
			<input type="text" bind:value={newTableName} />
		</label>
		<button>Submit</button>
	</form>
{/if}

<style lang="sass">
#options
  display: flex 
  flex-direction: row
</style>
