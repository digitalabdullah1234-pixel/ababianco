import { drizzle } from "drizzle-orm/node-postgres";
import { migrate } from "drizzle-orm/node-postgres/migrator";
import pg from "pg";
import * as schema from "./schema";

const { Pool } = pg;

export const databaseUrl = process.env.DATABASE_URL?.trim() || undefined;

// The pool connects lazily, so the server can start and serve the website
// even before a database is configured. Queries fail until DATABASE_URL is set.
export const pool = new Pool({
  connectionString: databaseUrl,
  connectionTimeoutMillis: 10_000,
});
export const db = drizzle(pool, { schema });

/** Creates or updates the database tables from the SQL files in `migrations/`. */
export async function runMigrations(migrationsFolder: string): Promise<void> {
  await migrate(db, { migrationsFolder });
}

export * from "./schema";
