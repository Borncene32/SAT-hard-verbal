-- Run once in Supabase SQL Editor. Safe to rerun.
create table if not exists public.sat_questions (
  id text primary key,
  sort_order integer not null unique,
  domain text not null,
  skill text not null,
  difficulty text not null,
  passage text not null default '',
  visual text not null default '',
  question text not null,
  choices jsonb not null,
  correct_answer text not null check (correct_answer in ('A', 'B', 'C', 'D')),
  explanations jsonb not null,
  created_at timestamptz not null default now()
);

create table if not exists public.sat_progress (
  user_id uuid not null references auth.users(id) on delete cascade,
  question_id text not null references public.sat_questions(id) on delete cascade,
  attempts text[] not null default array[]::text[],
  selected_choice text check (selected_choice is null or selected_choice in ('A', 'B', 'C', 'D')),
  status text not null default 'unanswered' check (status in ('unanswered', 'in-progress', 'correct', 'failed')),
  elapsed_seconds integer not null default 0 check (elapsed_seconds >= 0),
  marked_for_review boolean not null default false,
  eliminated_choices text[] not null default array[]::text[],
  note text not null default '',
  updated_at timestamptz not null default now(),
  primary key (user_id, question_id)
);


alter table public.sat_questions enable row level security;
alter table public.sat_progress enable row level security;
grant select on public.sat_questions to anon, authenticated;
grant select, insert, update, delete on public.sat_progress to authenticated;

drop policy if exists "Anyone can read SAT questions" on public.sat_questions;
create policy "Anyone can read SAT questions" on public.sat_questions for select to anon, authenticated using (true);
drop policy if exists "Users read their own SAT progress" on public.sat_progress;
create policy "Users read their own SAT progress" on public.sat_progress for select to authenticated using (auth.uid() = user_id);
drop policy if exists "Users create their own SAT progress" on public.sat_progress;
create policy "Users create their own SAT progress" on public.sat_progress for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "Users update their own SAT progress" on public.sat_progress;
create policy "Users update their own SAT progress" on public.sat_progress for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "Users delete their own SAT progress" on public.sat_progress;
create policy "Users delete their own SAT progress" on public.sat_progress for delete to authenticated using (auth.uid() = user_id);
