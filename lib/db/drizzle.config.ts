import { defineConfig } from "drizzle-kit";

// `generate` only reads the schema files; the other commands need a database.
const needsDatabase = !process.argv.includes("generate");

if (needsDatabase && !process.env.DATABASE_URL) {
  throw new Error("DATABASE_URL is not set. Add it to your environment first.");
}

export default defineConfig({
  // Relative paths (run from lib/db) also work on Windows.
  schema: "./src/schema/index.ts",
  out: "./migrations",
  dialect: "postgresql",
  dbCredentials: {
    url: process.env.DATABASE_URL ?? "",
  },
});
