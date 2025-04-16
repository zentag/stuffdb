<script>
	import { supabase } from "$lib/supabase";
	let newColumnName = $state("");
	let newColumnDatatype = $state("");
	let props = $props();
	$inspect(newColumnName);
	$inspect(newColumnDatatype);
	$inspect(props);
</script>

<div>
	<input
		placeholder="Column Name..."
		id="new_col_input"
		bind:value={newColumnName}
	/>
	<select bind:value={newColumnDatatype}>
		<option selected disabled value="">Datatype</option>
		<option>int2</option>
		<option>int4</option>
		<option>int8</option>
		<option>float4</option>
		<option>float8</option>
		<option>numeric</option>
		<option>json</option>
		<option>jsonb</option>
		<option>text</option>
		<option>varchar</option>
		<option>uuid</option>
		<option>date</option>
		<option>time</option>
		<option>timetz</option>
		<option>timestamp</option>
		<option>timestamptz</option>
		<option>bool</option>
		<option>bytes</option>
	</select>
	<button
		onclick={async () => {
			await supabase.rpc("create_column", {
				tablename: props.selectedTable,
				name: newColumnName,
				datatype: newColumnDatatype,
			});
		}}>New column</button
	>
</div>

<style lang="sass">
input, select, button
  width: 12rem
  margin-right: 1rem
button
  width: 8rem
div 
  display: flex
</style>
