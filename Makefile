.PHONY: help migration db-push

# Show available commands.
# Usage: make help
help:
	@echo "make migration NAME=<name>  create an empty supabase/migrations/<timestamp>_<name>.sql"
	@echo "make db-push                apply pending migrations to the linked Supabase project"

# Create a new, empty migration file. Edit it, then run db-push.
# Usage: make migration NAME=add_salary_to_jobs
migration:
	@test -n "$(NAME)" || { echo "error: NAME is required, e.g. make migration NAME=add_salary_to_jobs"; exit 1; }
	supabase migration new $(NAME)

# Apply all pending migrations to the linked Supabase project (live database!).
# Prompts for the DB password unless SUPABASE_DB_PASSWORD is set.
# Usage: make db-push
#        SUPABASE_DB_PASSWORD=your-password make db-push
db-push:
	supabase db push --remote
