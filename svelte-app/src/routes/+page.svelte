<script lang="ts">
	import { auth } from "$lib/supabase";
	import Login from "$lib/components/login.svelte";
</script>

<h1>Welcome to SvelteKit</h1>
{#await auth.getUser() then user}
	<p>{JSON.stringify(user)}</p>
	{#if user.data.user}
		<p>
			{JSON.stringify(user)}
		</p>
	{:else}
		<Login />
	{/if}
{/await}
