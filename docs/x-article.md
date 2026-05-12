# Hermes as a CTO: from prompt to product

*X article — publish via X Articles (Premium required)*

---

Most founders think the bottleneck is writing code.

It is not. The bottleneck is everything around the code. Reading the issue. Writing the ticket. Assigning the work. Reviewing the PR. Checking the build. Deploying. Telling someone it shipped. Starting over.

That coordination layer is where your week disappears.

What if you had a CTO who handled all of it, reported to you every morning, and only interrupted you when a real decision was needed?

That is what Hermes becomes when you set it up right. This article shows you exactly how.

---

## What is Hermes?

Hermes is an open-source autonomous agent built by Nous Research. It is not a coding assistant you open in an IDE. It is not a chatbot you ask questions. It is closer to a permanent team member that lives on a server, never sleeps, remembers everything you have worked on together, and reaches you wherever you are — Telegram, Slack, Discord, WhatsApp, your terminal.

What separates Hermes from everything else is what it has built in out of the box.

Persistent memory across sessions. It learns your project over time and never forgets how it solved something last week.

A native skill system. You give it a markdown file describing a workflow — deploy to Vercel, triage a GitHub issue, run a security scan — and Hermes knows how to execute it from that point on. No code. No plugins. Text files.

Native cron scheduling. Native kanban. Native sub-agent spawning. You can run up to three parallel agents in isolated sessions, all sharing the same memory and kanban board.

None of this requires setup beyond installing Hermes. It is all there. The question is how to use it well.

---

## The idea behind Oh My Hermes

Oh My Hermes is a skill pack — 23 skills, 6 agent role definitions, 5 workflows — that wires all of Hermes' native capabilities into one coherent CTO system.

Like Oh My Zsh does for your terminal: the power was already there. The pack makes it immediately useful.

The setup is one command and one conversation with your bot.

```bash
curl -fsSL https://raw.githubusercontent.com/salomondiei08/oh-my-hermes/main/install.sh | bash
```

Then you message your bot: "set up the CTO loop"

It asks for your GitHub repository, walks you through creating a fine-grained token with exact steps through the GitHub UI, asks for your production URL and what time you want your daily report, and configures everything. You never need to open the terminal again.

---

## From prompt to product — the full loop

[DIAGRAM: horizontal flow — GitHub issue → PM Agent → Dev Agent → Security Agent → QA Agent → You (YES/NO) → Ops Agent → Live in production. Below Dev Agent: fork showing Hermes / Codex / Claude Code. Dark background, white labels.]

Diagram prompt:
```
Clean horizontal flow diagram on dark background.
Title: "From prompt to product — the Oh My Hermes CTO loop"
Nodes left to right:
GitHub issue → PM Agent → Dev Agent → Security Agent → QA Agent → You (YES/NO) → Ops Agent → Live in production
Each node is a rounded rectangle. Dark navy background. White labels and connecting arrows.
Below the Dev Agent node, a small fork showing: Hermes / Codex / Claude Code.
Minimal. No decorative elements.
```

Here is what happens from the moment someone opens a GitHub issue to the moment the fix is live in production.

**Step 1 — The PM Agent reads the issue.**

It scores it by urgency and impact: bug labels, number of user comments, age, priority tags. It writes a proper kanban ticket with a clear title, the business reason in one sentence, and two to four testable acceptance criteria. If the issue is too vague, it does not guess — it asks you for clarification.

**Step 2 — The Dev Agent picks up the ticket.**

It looks at what needs to be done and chooses the right tool. Config and ops work goes to Hermes itself. A quick bug in one or two files goes to Codex. A multi-file feature with unclear structure goes to Claude Code. It implements the fix, commits after every logical unit of work, and scans the diff before every commit to make sure no secrets or API keys are included.

**Step 3 — The Security Agent reviews the PR.**

Every single PR, before it reaches you. It scans the diff for hardcoded credentials, dangerous patterns like raw SQL concatenation or eval(), and OWASP issues. If package files changed, it runs an audit for CVEs. If something critical turns up, the PR is blocked and you get an immediate alert. Every Monday it also runs a supply chain check — publisher changes, typosquatting, new CVEs since last week.

**Step 4 — The QA Agent checks everything.**

It verifies the build passes, runs a health check on the Vercel preview URL, and confirms the changes actually match the acceptance criteria on the ticket. Then it writes a summary in plain English — not a diff, not a list of files, but what the user will actually experience differently.

**Step 5 — You get one message.**

> PR 12 — Fix login redirect for new users
>
> What changed: Users who hadn't verified their email were sent to a 404. They now see "Check your inbox."
>
> Build: passing  |  Preview: healthy at 180ms  |  No secrets found
> Preview: https://myapp-fix-login.vercel.app
>
> Reply YES to ship. Reply NO and tell me why.

**Step 6 — You reply YES.**

The Ops Agent merges, deploys to production, runs a three-layer health check — app endpoint, Supabase connection, Vercel logs — and sends you a confirmation with the live URL.

The entire loop. From GitHub issue to live in production. Your total involvement: one word.

---

## The six agents and what they own

[DIAGRAM: six card grid]

Diagram prompt:
```
Six card grid on dark background. Title: "The 6 Oh My Hermes agents"
Each card has: agent name (bold, top), one-line role, kanban column owned (bottom, smaller text).
Cards:
  CTO — Orchestrates + reports to you / All columns
  PM — Triages + writes tickets / Backlog
  Dev — Implements + opens PRs / In Progress
  Security — Scans every PR + weekly supply chain / Between Dev and QA
  QA — Reviews + health checks + writes summary / Review
  Ops — Deploys + monitors 24/7 / Done + monitoring
Dark cards on darker background. White text. Clean grid layout.
```

**CTO** is the main Hermes session. It orchestrates everything, watches the kanban, delegates to the other five agents, and is the only one that talks to you. It sends you a morning report every day. It escalates to you only when a human decision is genuinely required. It does not write code.

**PM** owns the backlog. Its job is to make sure the Dev Agent never has to guess at what a ticket means. Every card it creates has testable acceptance criteria. Ambiguous issues get a question back to you before anything starts.

**Dev** owns In Progress. It picks the top ticket, chooses the right engine, builds the fix, and opens the PR. It never starts a second ticket while one is in progress. It never commits a secret.

**Security** sits between Dev and QA on every PR. It also runs every Monday independently to assess the supply chain. It does not write fixes — it sends specific feedback to Dev with instructions, then blocks the merge until the issue is resolved.

**QA** is the last check before anything reaches you. It will not approve a PR without running the health check on the preview URL. If the build fails or the preview is unhealthy, it sends the card back to Dev with specific feedback. It never guesses.

**Ops** runs 24 hours a day. Health check every 15 minutes. Vercel log scan every hour. When something breaks it retries once, identifies the failing layer, and alerts you in plain language. If the last deploy was under two hours ago, it offers a rollback. It always confirms with you before executing it.

---

## This is Hermes doing what it already does

The thing worth understanding is that Oh My Hermes is not asking Hermes to do anything unusual.

The kanban is native. Every `hermes kanban create`, `hermes kanban claim`, `hermes kanban complete` command in these skills exists in stock Hermes.

The scheduling is native. The hourly triage, the 15-minute health checks, the Monday security scan, the morning report — all of it is `hermes cron add` pointing at a skill prompt.

The sub-agents are native. Hermes supports up to three parallel sub-sessions. The CTO spawns PM, Dev, Security, QA, and Ops as sub-agents. They share memory and kanban access without any custom plumbing.

The memory is native. When the Dev Agent writes a PR description, it draws from the same memory the CTO has built over weeks. Context is always there.

Oh My Hermes provides the playbook. The 23 skill files tell Hermes exactly what steps to take in each situation. The agent role files define ownership. The workflow files wire the stages together.

It is a thin layer of instructions on top of powerful infrastructure that already exists.

---

## What changes after one week

The first thing you notice is that the backlog is moving without you.

You check Telegram in the morning. There is a report: two things shipped yesterday, one is in review, one needs your input because the issue was ambiguous. You reply in one sentence. The loop continues.

The second thing is that you stop second-guessing the small stuff. Did that commit include a secret? The Security Agent would have blocked it. Did the deploy break the database? The Ops Agent would have told you within 15 minutes. Is the preview healthy? The QA Agent ran the health check before you ever saw the PR.

The third thing is harder to describe. Your mental model of your own project changes. You stop being the person who manages the process. You become the person who makes the decisions that actually require a human — what to build next, what to prioritize, what direction to take when something is ambiguous.

That is the real value. Not automation for its own sake. The fact that the coordination layer disappears and what is left is only the work that needed you all along.

---

## What it does not replace

Product thinking. The PM Agent triages and scores, but if you are building the wrong thing, no system fixes that.

Ambiguous problems. When a task involves genuinely uncertain technical choices, the Dev Agent escalates. That is by design.

Badly written issues. The system is as good as the GitHub issues you write. A clear issue — title, description, expected behavior — produces a clear ticket and a clean PR. "Fix the thing that broke" produces a question back to you.

---

## Get started

One command to install. One message to configure. Full loop running by the end of the afternoon.

```bash
curl -fsSL https://raw.githubusercontent.com/salomondiei08/oh-my-hermes/main/install.sh | bash
```

Then message your bot: set up the CTO loop

Everything else happens in the conversation.

Full repo, all skills, all agent definitions, MIT license:
github.com/salomondiei08/oh-my-hermes

The loop runs without you. Go build something worth shipping.
