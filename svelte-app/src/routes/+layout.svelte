<script>
	import { invalidate } from "$app/navigation";
	import { onMount } from "svelte";
	import "../app.sass";
	import Header from "$lib/components/header.svelte";
	let { data, children } = $props();
	let { session, supabase } = $derived(data);

	onMount(() => {
		const { data } = supabase.auth.onAuthStateChange((_, newSession) => {
			if (newSession?.expires_at !== session?.expires_at) {
				invalidate("supabase:auth");
			}
		});

		return () => data.subscription.unsubscribe();
	});
</script>

<Header {supabase} />
{@render children()}
