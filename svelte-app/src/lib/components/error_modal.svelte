<script lang="ts">
	let { dialogOpen = $bindable(), errorMsg } = $props();
</script>

<dialog open={dialogOpen}>
	<article>
		<header>
			<button aria-label="Close" rel="prev" onclick={() => (dialogOpen = false)}
			></button>
			<p>
				<strong>⚠️ Oh no!</strong>
			</p>
		</header>
		<p>
			{errorMsg}
		</p>
	</article>
</dialog>

<style lang="sass">
button 
  float: right
</style>
