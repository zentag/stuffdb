<script lang="ts">
	import { auth, supabase } from "$lib/supabase";
	import Login from "$lib/components/login.svelte";
	const defaultTableSelect = "Select thing type...";
	let selectedTable = $state(defaultTableSelect);
	let newTableName = $state("");
	async function newTable() {
		await supabase.rpc("create_table", {
			name: newTableName,
		});
		selectedTable = defaultTableSelect;
	}
</script>

<h1>StuffDB</h1>
{#await auth.getUser() then user}
	{#if user.data.user}
		{#await supabase.rpc("list_tables") then tables}
			<select
				name="select"
				aria-label="Select"
				required
				bind:value={selectedTable}
			>
				<option>{defaultTableSelect}</option>
				{#each tables.data as table}
					<option>
						{table.tablename.split("_").join(" ")}
					</option>
				{/each}
				<option>+ New thing type</option>
			</select>
		{/await}
		{#await supabase.rpc("get_cols", { tablename: selectedTable }) then table}
			{#each table.data as column}{/each}
		{/await}
	{:else}
		<Login />
	{/if}
{/await}
{#if selectedTable == "+ New thing type"}
	<form onsubmit={newTable}>
		<label>
			Name of thing type:
			<input type="text" bind:value={newTableName} />
		</label>
		<button>Submit</button>
	</form>
{/if}
