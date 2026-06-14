<script>
	import { sharedState } from "$lib/shared.svelte";
	import { page } from "$app/state";
	let { supabase } = $props();
</script>

<header>
	<h1>StuffDB</h1>
	{#if page.url.pathname == "/"}
		{#await supabase.rpc("list_tables" + sharedState.selectedTable.slice(0, 0) /*This is to make this update on selected table change*/) then tables}
			<select
				name="select"
				aria-label="select thing type..."
				bind:value={sharedState.selectedTable}
			>
				<option selected value="">all</option>
				{#each tables.data as table}
					<option>
						{table.tablename.split("_").join(" ")}
					</option>
				{/each}
				<option>New thing type</option>
			</select>
		{/await}
	{/if}
</header>

<style lang="sass">
header 
  display: flex
  margin-top: 1rem
  margin-left: 1rem
  align-items: center
select 
  width: 12rem
  margin-left: 1rem
</style>
