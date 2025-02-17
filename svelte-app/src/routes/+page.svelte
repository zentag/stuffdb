<script lang="ts">
	import { supabase } from "$lib/supabase";
</script>

<h1>Welcome to SvelteKit</h1>
{#await supabase.from("capacitors").select("*") then data}
	<p>
		{JSON.stringify(data.data[0])}
	</p>
{/await}
