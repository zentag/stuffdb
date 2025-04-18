<script lang="ts">
	let { hit, selectedTable } = $props();
</script>

<article class="result_card">
	<h4>{hit.name || hit.table}</h4>
	{#each Object.keys(hit) as key}
		{#if key !== "_highlightResult" && key !== "name" && key !== "objectID" && key !== "id" && (key !== "table" || selectedTable == "")}
			<p><b>{key}:</b> {hit[key]}</p>
		{/if}
	{/each}
</article>

<style lang="sass">
.result_card
  width:16rem
  margin: 1rem
</style>
