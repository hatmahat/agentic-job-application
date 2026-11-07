# agentic-job-application

An agentic job application pipeline for overseas backend roles. An AI agent finds relevant jobs, scores them against my CV, drafts tailored resumes, and logs everything in Supabase. The agent only submits applications I have explicitly approved.

## How it works

1. The agent searches the internet for relevant jobs, scores each one against my CV, and logs them. New applications start as approval `pending` + pipeline `to_do`.
2. I review them and approve or skip each one.
3. The agent applies to all approved applications, marking each one `applying` while it works on it.
4. Once an application is submitted, it moves to `applied`. Every status change is recorded in the history table.

Every application has two separate status columns, described in the next section.

> Approval-before-submit and history logging are agent conventions, not enforced by the database.

## Statuses

### Approval status (`user_approval_status`): did I say yes?

| Status | Meaning | Set by |
|---|---|---|
| `pending` | Waiting for my decision (default for new applications) | Agent, on insert |
| `approved` | I approved it; the agent may apply | Me |
| `skipped` | I rejected it; the agent leaves it alone | Me |

### Pipeline status (`application_status`): how far along is it?

| Status | Meaning | Set by |
|---|---|---|
| `to_do` | Found and logged, not applied yet (default) | Agent, on insert |
| `applying` | The agent is applying right now | Agent |
| `applied` | Application submitted | Agent |
| `online_assessment` | Received an online assessment | Agent or me |
| `interview` | In the interview stage | Agent or me |
| `rejected` | Rejected at any stage | Agent or me |
| `offer` | Received an offer | Agent or me |

### Example: one job from start to finish

| Step | Approval status | Pipeline status |
|---|---|---|
| Agent finds and logs the job | `pending` | `to_do` |
| I approve it | `approved` | `to_do` |
| Agent is applying | `approved` | `applying` |
| Application submitted | `approved` | `applied` |
| Later: OA, interview, offer or rejection | `approved` | `online_assessment` / `interview` / `offer` / `rejected` |

A job I skip stays `skipped` + `to_do` and is never applied to.

## Data model

| Table | Purpose |
|---|---|
| `companies`, `countries` | Lookup tables |
| `jobs` | Job listings with description, location, URL, fit score and reason |
| `applications` | One per job, with approval status, pipeline status, expected salary (IDR) and an optional resume version |
| `application_status_histories` | Timeline of pipeline status changes and notes (OA, rejection) |
| `resume_versions` | Resume files (name and storage path); an application can link to one |

## Database workflow

The schema lives in `supabase/migrations/` and is applied to the linked Supabase project with the Supabase CLI:

```sh
make migration NAME=add_salary_to_jobs   # create an empty migration file, then edit it
make db-push                             # apply pending migrations to the live database
```

## Stack

Supabase (Postgres), Claude (agent), Google Drive (resume storage)

## Status

Schema deployed. Agent workflow in progress.