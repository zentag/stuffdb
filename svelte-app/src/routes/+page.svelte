<script lang="ts">
	import { auth, supabase } from "$lib/supabase";
	import Login from "$lib/components/login.svelte";
	let selectedTable = $state("Select component...");
</script>

<h1>StuffDB</h1>
{#await auth.getUser() then user}
	{#if user.data.user}
		{#await supabase.rpc("list_tables") then tables}
			<select name="select" aria-label="Select" required value={selectedTable}>
				<option>{selectedTable}</option>
				{#each tables.data as table}
					<option>
						{table.tablename}
					</option>
				{/each}
			</select>
		{/await}
	{:else}
		<Login />
	{/if}
{/await}
