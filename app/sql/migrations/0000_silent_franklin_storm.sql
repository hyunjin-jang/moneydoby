CREATE TYPE "public"."setting_method" AS ENUM ('amount', 'income_based');

--> statement-breakpoint
CREATE TYPE "public"."goal_status" AS ENUM ('scheduled', 'in_progress', 'completed', 'failed');

--> statement-breakpoint
CREATE TYPE "public"."notification_type" AS ENUM ('budget', 'goal', 'expense', 'etc');

--> statement-breakpoint
CREATE TYPE "public"."role" AS ENUM ('admin', 'user');

--> statement-breakpoint
CREATE TABLE
	"budget_allocations" (
		"id" uuid PRIMARY KEY DEFAULT gen_random_uuid () NOT NULL,
		"recommendation_id" uuid,
		"category" text NOT NULL,
		"amount" bigint NOT NULL,
		"user_id" uuid,
		"created_at" timestamp DEFAULT now () NOT NULL,
		"updated_at" timestamp DEFAULT now () NOT NULL
	);

--> statement-breakpoint
CREATE TABLE
	"budget_fixed_expenses" (
		"id" uuid PRIMARY KEY DEFAULT gen_random_uuid () NOT NULL,
		"budget_id" uuid,
		"title" text NOT NULL,
		"amount" bigint NOT NULL,
		"user_id" uuid,
		"created_at" timestamp DEFAULT now () NOT NULL,
		"updated_at" timestamp DEFAULT now () NOT NULL
	);

--> statement-breakpoint
CREATE TABLE
	"budget_incomes" (
		"id" uuid PRIMARY KEY DEFAULT gen_random_uuid () NOT NULL,
		"budget_id" uuid,
		"title" text NOT NULL,
		"amount" bigint NOT NULL,
		"user_id" uuid,
		"created_at" timestamp DEFAULT now () NOT NULL,
		"updated_at" timestamp DEFAULT now () NOT NULL
	);

--> statement-breakpoint
CREATE TABLE
	"budget_recommendations" (
		"id" uuid PRIMARY KEY DEFAULT gen_random_uuid () NOT NULL,
		"budget_id" uuid,
		"title" text NOT NULL,
		"description" text NOT NULL,
		"savings" bigint NOT NULL,
		"saving_ratio" numeric(5, 2) NOT NULL,
		"user_id" uuid,
		"created_at" timestamp DEFAULT now () NOT NULL,
		"updated_at" timestamp DEFAULT now () NOT NULL,
		CONSTRAINT "budget_recommendations_user_id_unique" UNIQUE ("user_id")
	);

--> statement-breakpoint
CREATE TABLE
	"budgets" (
		"id" uuid PRIMARY KEY DEFAULT gen_random_uuid () NOT NULL,
		"setting_method" "setting_method" NOT NULL,
		"total_amount" bigint NOT NULL,
		"user_id" uuid,
		"date" timestamp DEFAULT now () NOT NULL,
		"created_at" timestamp DEFAULT now () NOT NULL,
		"updated_at" timestamp DEFAULT now () NOT NULL
	);

--> statement-breakpoint
CREATE TABLE
	"expense_categories" (
		"id" uuid PRIMARY KEY DEFAULT gen_random_uuid () NOT NULL,
		"name" text NOT NULL,
		"user_id" uuid,
		"created_at" timestamp DEFAULT now () NOT NULL,
		"updated_at" timestamp DEFAULT now () NOT NULL
	);

--> statement-breakpoint
CREATE TABLE
	"expenses" (
		"id" uuid PRIMARY KEY DEFAULT gen_random_uuid () NOT NULL,
		"description" text NOT NULL,
		"amount" bigint NOT NULL,
		"date" date NOT NULL,
		"category" uuid,
		"user_id" uuid,
		"created_at" timestamp DEFAULT now () NOT NULL,
		"updated_at" timestamp DEFAULT now () NOT NULL
	);

--> statement-breakpoint
CREATE TABLE
	"goals" (
		"id" uuid PRIMARY KEY DEFAULT gen_random_uuid () NOT NULL,
		"title" text NOT NULL,
		"amount" bigint NOT NULL,
		"start_date" date NOT NULL,
		"end_date" date NOT NULL,
		"status" "goal_status" DEFAULT 'scheduled' NOT NULL,
		"user_id" uuid,
		"created_at" timestamp DEFAULT now () NOT NULL,
		"updated_at" timestamp DEFAULT now () NOT NULL
	);

--> statement-breakpoint
CREATE TABLE
	"notifications" (
		"id" uuid PRIMARY KEY DEFAULT gen_random_uuid () NOT NULL,
		"user_id" uuid,
		"type" "notification_type" NOT NULL,
		"title" text NOT NULL,
		"description" text NOT NULL,
		"read" boolean DEFAULT false NOT NULL,
		"created_at" timestamp DEFAULT now () NOT NULL
	);

--> statement-breakpoint
ALTER TABLE "notifications" ENABLE ROW LEVEL SECURITY;

--> statement-breakpoint
CREATE TABLE
	"profiles" (
		"id" uuid PRIMARY KEY NOT NULL,
		"avatar" text,
		"name" text NOT NULL,
		"username" text NOT NULL,
		"role" "role" DEFAULT 'user' NOT NULL,
		"created_at" timestamp DEFAULT now () NOT NULL,
		"updated_at" timestamp DEFAULT now () NOT NULL,
		CONSTRAINT "profiles_username_unique" UNIQUE ("username")
	);

--> statement-breakpoint
ALTER TABLE "budget_allocations" ADD CONSTRAINT "budget_allocations_recommendation_id_budget_recommendations_id_fk" FOREIGN KEY ("recommendation_id") REFERENCES "public"."budget_recommendations" ("id") ON DELETE cascade ON UPDATE no action;

--> statement-breakpoint
ALTER TABLE "budget_allocations" ADD CONSTRAINT "budget_allocations_user_id_profiles_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."profiles" ("id") ON DELETE cascade ON UPDATE no action;

--> statement-breakpoint
ALTER TABLE "budget_fixed_expenses" ADD CONSTRAINT "budget_fixed_expenses_budget_id_budgets_id_fk" FOREIGN KEY ("budget_id") REFERENCES "public"."budgets" ("id") ON DELETE cascade ON UPDATE no action;

--> statement-breakpoint
ALTER TABLE "budget_fixed_expenses" ADD CONSTRAINT "budget_fixed_expenses_user_id_profiles_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."profiles" ("id") ON DELETE cascade ON UPDATE no action;

--> statement-breakpoint
ALTER TABLE "budget_incomes" ADD CONSTRAINT "budget_incomes_budget_id_budgets_id_fk" FOREIGN KEY ("budget_id") REFERENCES "public"."budgets" ("id") ON DELETE cascade ON UPDATE no action;

--> statement-breakpoint
ALTER TABLE "budget_incomes" ADD CONSTRAINT "budget_incomes_user_id_profiles_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."profiles" ("id") ON DELETE cascade ON UPDATE no action;

--> statement-breakpoint
ALTER TABLE "budget_recommendations" ADD CONSTRAINT "budget_recommendations_budget_id_budgets_id_fk" FOREIGN KEY ("budget_id") REFERENCES "public"."budgets" ("id") ON DELETE cascade ON UPDATE no action;

--> statement-breakpoint
ALTER TABLE "budget_recommendations" ADD CONSTRAINT "budget_recommendations_user_id_profiles_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."profiles" ("id") ON DELETE cascade ON UPDATE no action;

--> statement-breakpoint
ALTER TABLE "budgets" ADD CONSTRAINT "budgets_user_id_profiles_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."profiles" ("id") ON DELETE cascade ON UPDATE no action;

--> statement-breakpoint
ALTER TABLE "expense_categories" ADD CONSTRAINT "expense_categories_user_id_profiles_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."profiles" ("id") ON DELETE cascade ON UPDATE no action;

--> statement-breakpoint
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_category_expense_categories_id_fk" FOREIGN KEY ("category") REFERENCES "public"."expense_categories" ("id") ON DELETE set null ON UPDATE no action;

--> statement-breakpoint
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_user_id_profiles_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."profiles" ("id") ON DELETE cascade ON UPDATE no action;

--> statement-breakpoint
ALTER TABLE "goals" ADD CONSTRAINT "goals_user_id_profiles_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."profiles" ("id") ON DELETE cascade ON UPDATE no action;

--> statement-breakpoint
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_profiles_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."profiles" ("id") ON DELETE cascade ON UPDATE no action;

--> statement-breakpoint
ALTER TABLE "profiles" ADD CONSTRAINT "profiles_id_users_id_fk" FOREIGN KEY ("id") REFERENCES "auth"."users" ("id") ON DELETE cascade ON UPDATE no action;

--> statement-breakpoint
CREATE POLICY "notification-insert-policy" ON "notifications" AS PERMISSIVE FOR INSERT TO "authenticated"
WITH
	CHECK (
		(
			select
				auth.uid ()
		) = "notifications"."user_id"
	);

--> statement-breakpoint
CREATE POLICY "notification-select-policy" ON "notifications" AS PERMISSIVE FOR
SELECT
	TO "authenticated" USING (
		(
			select
				auth.uid ()
		) = "notifications"."user_id"
	);