-- Baseline schema. The IF NOT EXISTS and duplicate_object guards let it run
-- safely on a database whose tables were created earlier with `drizzle-kit push`.
CREATE TABLE IF NOT EXISTS "menu_cart_items" (
	"cart_id" uuid NOT NULL,
	"menu_item_id" text NOT NULL,
	"quantity" integer NOT NULL,
	CONSTRAINT "menu_cart_items_cart_id_menu_item_id_pk" PRIMARY KEY("cart_id","menu_item_id"),
	CONSTRAINT "menu_cart_items_quantity_bounds" CHECK ("menu_cart_items"."quantity" between 1 and 99)
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "menu_carts" (
	"id" uuid PRIMARY KEY NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "menu_categories" (
	"id" text PRIMARY KEY NOT NULL,
	"title_en" text NOT NULL,
	"title_ar" text NOT NULL,
	"sort_order" integer NOT NULL,
	"active" boolean DEFAULT true NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "menu_items" (
	"id" text PRIMARY KEY NOT NULL,
	"category_id" text NOT NULL,
	"name_en" text NOT NULL,
	"name_ar" text NOT NULL,
	"description_en" text DEFAULT '' NOT NULL,
	"description_ar" text DEFAULT '' NOT NULL,
	"price_sar" integer NOT NULL,
	"calories" integer,
	"image_path" text,
	"featured" boolean DEFAULT false NOT NULL,
	"sort_order" integer NOT NULL,
	"available" boolean DEFAULT true NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "restaurant_orders" (
	"id" uuid PRIMARY KEY NOT NULL,
	"cart_id" uuid NOT NULL,
	"payment_intent_id" text,
	"fulfillment" text NOT NULL,
	"customer_name" text NOT NULL,
	"phone" text NOT NULL,
	"delivery_address" text,
	"notes" text DEFAULT '' NOT NULL,
	"items" jsonb NOT NULL,
	"subtotal_halalas" integer NOT NULL,
	"currency" text DEFAULT 'sar' NOT NULL,
	"status" text DEFAULT 'pending' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "restaurant_orders_payment_intent_id_unique" UNIQUE("payment_intent_id")
);
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "menu_cart_items" ADD CONSTRAINT "menu_cart_items_cart_id_menu_carts_id_fk" FOREIGN KEY ("cart_id") REFERENCES "public"."menu_carts"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "menu_cart_items" ADD CONSTRAINT "menu_cart_items_menu_item_id_menu_items_id_fk" FOREIGN KEY ("menu_item_id") REFERENCES "public"."menu_items"("id") ON DELETE restrict ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "menu_items" ADD CONSTRAINT "menu_items_category_id_menu_categories_id_fk" FOREIGN KEY ("category_id") REFERENCES "public"."menu_categories"("id") ON DELETE restrict ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
