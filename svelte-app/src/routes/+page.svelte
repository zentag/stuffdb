<script lang="ts">
	import { auth, supabase } from "$lib/supabase";
	import Login from "$lib/components/login.svelte";
	let selectedTable = $state("");
	let newTableName = $state("");
	let filters = $state({});
	async function newTable() {
		await supabase.rpc("create_table", {
			name: newTableName,
		});
		selectedTable = "";
	}
	$inspect(filters);
</script>

{#await auth.getUser() then user}
	{#if user.data.user}
		{#await supabase.rpc("list_tables" + selectedTable.slice(0, 0)) then tables}
			<div class="header">
				<h1>StuffDB</h1>
				<select
					name="select"
					aria-label="select thing type..."
					bind:value={selectedTable}
				>
					<option selected disabled value="">all</option>
					{#each tables.data as table}
						<option>
							{table.tablename.split("_").join(" ")}
						</option>
					{/each}
					<option>New thing type</option>
				</select>
			</div>
		{/await}
		{#await supabase.rpc("get_cols", { tablename: selectedTable }) then table}
			<div id="options">
				{#each table.data as column}
					{#if column.type === "smallint"}
						{#if filters[column.name]?.[2]}
							<input
								type="number"
								placeholder={column.name + ": min"}
								class="number"
								onchange={(e) => {
									filters[column.name] = [
										e.target.value,
										filters[column.name]?.[1] || null,
									];
								}}
							/>
							<input
								type="number"
								placeholder={column.name + ": max"}
								class="number"
								onchange={(e) => {
									filters[column.name] = [
										filters[column.name]?.[0] || null,
										e.target.value,
									];
								}}
							/>
						{:else}
							<input
								type="number"
								placeholder={column.name}
								onchange={(e) =>
									(filters[column.name] = [
										e.target.value,
										e.target.value,
										filters[column.name]?.[2],
									])}
							/>
						{/if}

						<p>Range?</p>
						<input
							type="checkbox"
							class="rangecheck"
							onchange={(e) => {
								filters[column.name] = [
									filters[column.name]?.[0],
									filters[column.name]?.[1],
									filters[column.name]?.[2] ? false : true,
								];
							}}
						/>
					{:else if column.type === "text" && column.name !== "name"}
						<details class="dropdown">
							<summary>{column.name}</summary>
							<ul>
								{#await supabase
									.from(selectedTable)
									.select(column.name) then values}
									{#each values.data as value}
										<li>
											<label class="checkboxlabel">
												<input
													type="checkbox"
													name={value[column.name]}
													class="checkbox"
												/>
												<p class="checkboxlabel">{value[column.name]}</p></label
											>
										</li>
									{/each}
								{/await}
							</ul>
						</details>
					{:else if column.name === "id"}{:else}
						<input type="text" placeholder={column.name} />
					{/if}
				{/each}
			</div>
			<div class="searchdiv">
				{#if selectedTable !== "New thing type"}
					<input placeholder="search..." class="search" />
					{#if table.data[0]}
						<button>New column</button>
					{/if}
				{/if}
			</div>
		{/await}
	{:else}
		<h1>StuffDB</h1>
		<Login />
	{/if}
{/await}
{#if selectedTable == "New thing type"}
	<form onsubmit={newTable}>
		<label class="label">
			<p>Name of thing type:</p>
			<input type="text" bind:value={newTableName} />
		</label>
		<button>Submit</button>
	</form>
{/if}
<div>
	{#if selectedTable === "all"}{/if}
</div>

<style lang="sass">
.searchdiv 
  display: flex 
  place-content: space-between
  width: 100vw
button
  margin-right: 1rem
#options
  display: flex 
  flex-direction: row
  flex-columns: 2
  flex-wrap: wrap
  align-items: center
input[type=number], input[type=text], select
  width:12rem
p:not(.checkboxlabel), select, input:not([type=checkbox]), button, h1, details
  margin-top: 1rem
  margin-left: 1rem
.header 
  display: flex
  align-items: center
.search 
  width: 21.5rem
.label 
  display: flex
  flex-direction: column
label > p 
  margin-bottom: -.5rem
label.checkboxlabel 
  display: flex
  align-items: center
.rangecheck
  margin-left: 1rem 
  margin-top: 0rem !important
input[type=checkbox]
  margin-top: .4rem
</style>
