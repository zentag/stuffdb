<script lang="ts">
	import { sharedState } from "$lib/shared.svelte";
	import { Pencil } from "@lucide/svelte";
	let selectedTable = $derived(sharedState.selectedTable);
	let isBeingEdited = $state(false);
	let { hit, supabase } = $props();
	let editableProperties: { [key: string]: unknown } = $state({});
	$effect(() => {
		Object.keys(hit).forEach((key) => {
			if (
				key !== "id" &&
				key !== "objectID" &&
				key !== "table" &&
				key !== "_highlightResult"
			)
				editableProperties[key] = hit[key];
		});
	});
</script>

<article class="result_card">
	<div>
		<h4>{hit.name || hit.table}</h4>
		{#if isBeingEdited}
			<button
				onclick={async () => {
					await supabase
						.from(hit.table)
						.update(editableProperties)
						.eq("id", hit.id);
					isBeingEdited = false;
				}}>Save</button
			>
		{:else}
			<button class="edit_button" onclick={() => (isBeingEdited = true)}>
				<Pencil />
			</button>
		{/if}
	</div>
	{#each Object.keys(hit) as key}
		{#if key == "_highlightResult" || key == "name" || key == "objectID" || key == "id"}
			<!-- Do nothing-->
		{:else if isBeingEdited && key !== "table"}
			<label
				>{key}:
				<input type="text" bind:value={editableProperties[key]} /></label
			>
		{:else if key == "table"}
			{#if selectedTable == ""}
				<p><b>{key}:</b> {hit[key]}</p>
			{/if}
		{:else}
			<p><b>{key}:</b> {editableProperties[key]}</p>
		{/if}
	{/each}
</article>

<style lang="sass">
.result_card
  width: 16rem
  margin: 1rem
div 
  display: flex 
  flex-direction: row
  justify-content: space-between
.edit_button 
  background-color: transparent
  border-width: 0
  margin-top: -1rem
  margin-right: -1rem
.edit_button:focus 
  box-shadow: 0 0 #0000
</style>
