Hermes as a CTO: from prompt to product

[header image — see diagram prompt at bottom]

Most founders do not need an AI that only reviews pull requests.

They need an AI that helps build the product.

The hard part is not one PR. It is the whole path from a rough idea to a real thing people can use.

The idea has to become a brief.

The brief has to become tasks.

The tasks have to become code.

The code has to be checked, shipped, monitored, and improved.

That is the workflow Oh My Hermes is trying to make simple.

Not just "review my PR."

"Help me build the product."


What is Hermes?

Hermes is an open-source autonomous agent built by Nous Research.

It is not a coding assistant trapped inside your IDE. It is not just a chatbot. It is closer to a long-running teammate that lives on a server, remembers your project, and talks to you through the places you already use: Telegram, Slack, Discord, WhatsApp, or the terminal.

What separates Hermes from everything else is what it has built in out of the box.

Persistent memory. It can remember what your product does, what stack you use, what decisions were made last week, and what not to repeat.

A native skill system. You give it a plain text workflow like "clarify requirements", "create a product brief", "choose the right coding engine", or "deploy to Vercel", and Hermes can follow it later.

Native cron. Native kanban. Native profiles. Native delegation.

That means Hermes already has the primitives for a product-building loop. Oh My Hermes is the opinionated playbook that connects them.


The idea behind Oh My Hermes

Oh My Hermes is a skill pack: 36 skills, 7 agent role definitions, and 6 workflows.

The goal is simple:

Turn Hermes into a practical CTO layer for building apps.

Not a magic founder replacement.

Not a vague "AI automation" demo.

A real operating loop for early product work:

Clarify the idea.

Write the brief.

Break it into tasks.

Choose the right builder.

Implement.

Review.

Ship.

Monitor.

Report back.

Like Oh My Zsh, the power was already there. The pack makes it easier to use without designing the whole workflow yourself.

The setup is not a command you have to paste into a terminal. It is a message you give to the AI agent already helping you with your project.

You tell Claude, Cursor, Codex, or any assistant:

Install Oh My Hermes on this project. Follow the agent installation guide at github.com/salomondiei08/oh-my-hermes/blob/main/INSTALL_FOR_AGENTS.md. Verify the install, then help me set up the CTO loop.

The agent handles the install and verification. Then you message your Hermes bot: set up the CTO loop

It inspects the project first, asks at most three useful questions with sensible
defaults, and keeps moving if you skip them. GitHub and production monitoring can
be connected when they become relevant.


From idea to product

[DIAGRAM — see prompt at bottom of article]

Here is the part I want to emphasize.

Oh My Hermes is not mainly about PR review.

PR review is just one checkpoint.

The real value is that Hermes can help move from a messy product request to a shipped feature.

Example:

"Build a small dashboard for my SaaS so I can see active users, failed payments, and support tickets."

A normal AI assistant might jump straight into code.

Oh My Hermes tries to slow down in the right places.

First, it reads what already exists and clarifies only what materially changes
the product.

It may ask who the dashboard is for, what decision it should support, or what the
smallest useful version is. It gives defaults and continues if you do not answer.

Then it writes a product brief.

Then it creates implementation tasks.

Then it chooses who should build each part.

For a small file fix, Codex might be enough.

For a multi-page feature, Claude Code might be better.

For deployment, monitoring, or repository operations, Hermes can handle the terminal work itself.

That is the full point: you are not asking one model to do everything. You are giving Hermes a system for routing the work.


The build loop

Here is what happens when the system is working well.

Step 1: The founder gives a rough idea or GitHub issue.

Hermes does not treat the first sentence as the final spec. If the request is unclear, it asks. If it is clear enough, it turns the request into a structured brief.

Step 2: The Product Agent and Designer turn it into buildable work.

Product writes the "what", the "why", and the acceptance criteria. Designer
defines the user flow, responsive behavior, and important states. Not vague
criteria like "it works." Concrete checks like "the dashboard loads in under 3
seconds and shows active users, failed payments, and open tickets."

Step 3: The Dev Agent builds.

The Dev Agent owns implementation. It picks the right engine, passes the right context, commits in logical chunks, and opens a PR when the work is ready.

This is where most of the value is. The system is not waiting for you to micromanage the next step. It is moving the build forward.

Step 4: Security and QA protect the build.

This is where PR review matters. Security checks for secrets, unsafe patterns, and obvious OWASP problems. QA checks the build, the preview, and whether the feature actually matches the acceptance criteria.

They are not the main event. They are the guardrails.

Step 5: You approve the product decision.

You get a message in plain English:

Dashboard feature is ready.

What changed: You can now see active users, failed payments, and open support tickets from one admin page.

Checks: build passing, preview healthy, no secrets found.

Preview: https://your-app-preview.vercel.app

Reply YES to ship. Reply NO and tell me what to change.

Step 6: Ops ships and watches production.

After approval, Ops deploys, runs health checks, logs the release, and keeps monitoring. If something breaks, it tells you what failed in plain language.

The promise is not "AI wrote some code."

The promise is "the product moved."


The seven agents and what they own

[DIAGRAM — see prompt at bottom of article]

CTO is the main Hermes session. It keeps the whole product lifecycle moving,
delegates to the other six agents, and is the one that talks to you.

Product turns ideas, feedback, analytics, and issues into buildable outcomes. It
also owns positioning, SEO, launch strategy, and content planning.

Designer owns user flows, visual direction, responsive behavior, rendered
verification, and optional HyperFrames launch videos with licensed music.

Dev builds the product. It owns in-progress work, chooses the right engine, implements the feature or fix, commits carefully, and opens the PR.

Security protects the product. It checks PRs for secrets, unsafe code patterns, OWASP issues, and supply chain risk. It does not exist to slow everything down. It exists so you can ship without being reckless.

QA checks whether the thing actually works. It reviews the PR, runs the preview health check, compares the result to the acceptance criteria, and writes a plain-English summary for you.

Ops ships and watches the product. It deploys, checks production, scans logs, reports incidents, and offers rollback when a recent deploy looks guilty.

The point is not that each agent is complicated.

The point is that each agent has a job.

That is what makes the loop understandable.


This is Hermes doing what it already does

The thing worth understanding is that Oh My Hermes is not asking Hermes to do anything unusual.

The kanban is native. Hermes already has a board where tasks can move from idea to work to review to done.

The scheduling is native. Product review, daily reports, health checks, log
observation, and recurring security reviews are cron jobs pointing at skill
prompts.

The profiles and delegation are native. Hermes can run different named roles with different instructions and shared project context.

The memory is native. The product brief, architecture choices, deploy history, and decisions can stay available across sessions.

Oh My Hermes provides the playbook.

The skills tell Hermes how to clarify, plan, build, review, deploy, monitor, and report.

The agent files define who owns what.

The workflows connect the stages.

It is a thin layer of instructions on top of powerful infrastructure that already exists.


What changes when you use it

The first thing you notice is that ideas stop sitting still.

Instead of writing "we should build this someday", you can turn the idea into a brief, tasks, code, review, deploy, and monitoring.

The second thing is that you stop being the project manager for every tiny step.

You still decide what matters.

You still approve what ships.

You still guide the product.

But you are no longer the glue between every tool.

The third thing is that the project develops a memory.

Why did we choose Supabase?

What did we ship last week?

Which health check failed after the last deploy?

What did the founder reject and why?

The answers live in the operating loop, not in your head.

That is the real value.

Not automation for its own sake.

Less coordination.

More building.


What it does not replace

Product thinking. The PM Agent triages and scores, but if you are building the wrong thing, no system fixes that.

Taste. Hermes can help execute a product direction. It cannot decide what your users should love.

Ambiguous architecture. When a task involves genuinely uncertain technical choices, the Dev Agent should escalate. That is by design.

Bad inputs. A clear request produces a clear build path. "Fix the thing that broke" produces a question back to you.

Real engineering judgment. The system makes routine product work move faster. It should still ask when the decision is expensive, irreversible, or strategic.


Get started

If you use Claude, Cursor, Codex, Copilot, or any AI assistant, send it this message:

Install Oh My Hermes on this project. Follow the agent installation guide at github.com/salomondiei08/oh-my-hermes/blob/main/INSTALL_FOR_AGENTS.md. Verify the install, then help me set up the CTO loop.

The agent handles the install and verification. You answer its questions. When it is ready, it tells you to message your Hermes bot.

Then message your Hermes bot: set up the CTO loop

Everything else happens in the conversation.

Full repo, all skills, all agent definitions, MIT license:
github.com/salomondiei08/oh-my-hermes

The loop is not the product.

The product is the product.

Oh My Hermes is there to keep it moving.

Go build something worth shipping.

DIAGRAM PROMPTS (generate these and embed in the article)

Header image:
Wide dark banner. A founder sketching an app idea on a notebook beside a glowing terminal. On the terminal: "idea -> brief -> build -> ship". Cinematic green light, dark background, clean product-building mood, no text overlay needed.

Build loop diagram (place after "From idea to product" heading):
Clean horizontal flow diagram on dark background. Title: "From idea to product".
Nodes left to right: Rough idea -> Product brief -> Design -> Build -> Security
and Reviewer -> Founder approval -> Production -> Learn. White labels and
connecting arrows. Below Build, a small fork showing Hermes / Codex / Claude
Code. Minimal, no decorative elements.

Agents grid (place after "The seven agents" heading):
Seven-card grid on dark background. Title: "The 7 Oh My Hermes agents". Cards:
CTO / Product lifecycle; Product / Brief and growth; Designer / UX and launch
creative; Builder / Working increments; Security / Risk checks; Reviewer /
Product verification; Ops / Release and reliability. Dark cards, white text,
clean grid, no decorative elements.
