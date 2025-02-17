<script lang="ts">
	import { db } from "$lib/db";
</script>

<h1>Welcome to SvelteKit</h1>
{#await db.from("capacitors").select("*") then data}
	<p>
		{JSON.stringify(data.data[0])}
	</p>
{/await}
