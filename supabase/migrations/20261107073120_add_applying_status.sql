-- Pipeline status for "the agent is applying right now".
-- Sits between to_do and applied.
ALTER TYPE application_status ADD VALUE IF NOT EXISTS 'applying' AFTER 'to_do';
