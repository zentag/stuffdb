/// <reference types="svelte" />
/// <reference types="vite/client" />
import { defineConfig } from "vite";
import sass from "vite-plugin-sass";

export default defineConfig({
  plugins: [sass({ sassOptions: { indentedSyntax: true } })],
});
