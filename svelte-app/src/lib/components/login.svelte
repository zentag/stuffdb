<script lang="ts">
	import { goto } from "$app/navigation";
	import { auth } from "$lib/supabase";
	let email = $state("");
	let password = $state("");
	let visible = $state(true);
	async function handleSubmit(event) {
		event.preventDefault();
		auth.signInWithPassword({
			email: email,
			password: password,
		});
		goto("/");
		visible = false;
	}
</script>

{#if visible}
	<form onsubmit={handleSubmit}>
		<label>
			Email
			<input name="email" type="email" bind:value={email} />
		</label>
		<label>
			Password
			<input name="password" type="password" bind:value={password} />
		</label>
		<button>Log in</button>
	</form>
{/if}

<style lang="sass">
  form 
    padding: 1rem
</style>
