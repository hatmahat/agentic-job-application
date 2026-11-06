CREATE TYPE application_status AS ENUM (
  'to_do',
  'applied',
  'online_assessment',
  'interview',
  'rejected',
  'offer'
);

CREATE TYPE user_approval_status AS ENUM (
  'pending',
  'approved',
  'skipped'
);

CREATE TABLE companies (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE countries (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE resume_versions (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  file_name TEXT NOT NULL,
  storage_path TEXT NOT NULL
);

CREATE TABLE jobs (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  company_id BIGINT NOT NULL REFERENCES companies (id),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  country_id BIGINT NOT NULL REFERENCES countries (id),
  location TEXT NOT NULL,
  url TEXT NOT NULL UNIQUE,
  fit_score INT NOT NULL,
  fit_reason TEXT NOT NULL
);

CREATE TABLE applications (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  job_id BIGINT NOT NULL UNIQUE REFERENCES jobs (id),
  user_approval_status user_approval_status NOT NULL DEFAULT 'pending',
  approved_at TIMESTAMPTZ,
  application_status application_status NOT NULL DEFAULT 'to_do',
  applied_at TIMESTAMPTZ,
  resume_version_id BIGINT REFERENCES resume_versions (id),
  expected_salary_idr BIGINT
);

CREATE TABLE application_status_histories (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  application_id BIGINT NOT NULL REFERENCES applications (id),
  previous_status application_status,
  current_status application_status NOT NULL,
  note TEXT
);

CREATE INDEX ON jobs (company_id);
CREATE INDEX ON jobs (country_id);
CREATE INDEX ON applications (resume_version_id);
CREATE INDEX ON application_status_histories (application_id);

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TRIGGER jobs_set_updated_at
  BEFORE UPDATE ON jobs
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER applications_set_updated_at
  BEFORE UPDATE ON applications
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();