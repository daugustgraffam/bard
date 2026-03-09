# BARD — Bard Agentic Resource Distribution

A central skill repository for teams. Store reusable AI prompt templates (skills) in one place and share them across team members, computers, and AI agents (Claude Code, Cursor, Codex, etc.).

## Quick start

```bash
git clone <repo-url> ~/Development/bard
cd ~/Development/bard
./bard play
```

`bard play` installs the `bard` binary, syncs official skills to `~/.agents/`, creates agent symlinks, and rebuilds the registry. Re-run it any time to update.

### Add `bard` to your PATH

`bard play` symlinks the binary to `~/.local/bin/bard`. Add that directory to your PATH so you can run `bard` from anywhere.

**zsh** (default on macOS):

```bash
echo 'export PATH="${HOME}/.local/bin:${PATH}"' >> ~/.zshrc
source ~/.zshrc
```

**bash:**

```bash
echo 'export PATH="${HOME}/.local/bin:${PATH}"' >> ~/.bashrc
source ~/.bashrc
```

Verify it worked:

```bash
which bard     # should print ~/.local/bin/bard
bard play      # run from any directory
```

## What BARD does

- **Stores** reusable AI prompt templates (skills) as markdown files
- **Indexes** them in a JSON registry for fast lookup
- **Serves** them to any AI agent via symlinks and the `bard` CLI
- **Does not** call AI APIs — your agent reads the skill and executes it

## Commands

```
bard play                              # Install/update + sync skills + rebuild registry
bard list                              # Browse all skills
bard list --category coding            # Filter by category
bard info bard-code-review             # Show full skill content
bard show bard-summarize               # Fill {{variables}} interactively, print resolved prompt
bard compose my-skill --category devops  # Scaffold a new skill
```

## Starter skills (7)


| ID                      | Category | Description                              |
| ----------------------- | -------- | ---------------------------------------- |
| `bard-create-skill`     | meta     | Scaffold a new BARD skill                |
| `bard-improve-skill`    | meta     | Review and improve an existing skill     |
| `bard-code-review`      | coding   | Review code for bugs, style, performance |
| `bard-refactor`         | coding   | Refactor for readability and performance |
| `bard-summarize`        | writing  | Summarise text into key points           |
| `bard-compare`          | analysis | Compare two approaches, recommend one    |
| `bard-write-dockerfile` | devops   | Generate a production-ready Dockerfile   |


## Directory structure

```
~/.agents/                    # All runtime data
  skills/
    coding/
      bard-code-review.md     # Official skills (bard- prefix, managed by bard play)
      bard-refactor.md
      my-custom-skill.md      # Your skills (no prefix, never touched by bard play)
    writing/
    analysis/
    devops/
    meta/
  registry/
    skills.json               # Auto-generated index
```

## Skill format

```markdown
---
id: bard-code-review
name: Code Review
category: coding
tags: [review, quality, feedback]
agents: [claude, openai, cursor]
description: Reviews code for bugs, style, and improvements
---

## System Prompt

You are an expert code reviewer...

## User Prompt Template

Review the following {{language}} code:

` ` `{{language}}
{{code}}
` ` `

## Expected Output Format

Structured review with severity ratings...
```

## Creating your own skills

```bash
bard compose my-api-skill --category coding
# Creates ~/.agents/skills/coding/bard-my-api-skill.md
# Edit the scaffold, then:
bard play   # Rebuilds registry — your skill appears in bard list
```

Skills created via `bard compose` get the `bard-` prefix. If you create skills manually outside BARD, **omit** the `bard-` prefix — `bard play` will never overwrite files without it.

## Agent integration

After `bard play`, symlinks are created:


| Agent       | Symlink            | Points to    |
| ----------- | ------------------ | ------------ |
| Claude Code | `~/.claude/skills` | `~/.agents/` |
| Cursor      | `~/.cursor/skills` | `~/.agents/` |


Use `bard show <skill-id>` to resolve a skill's variables, then paste the output into your agent's chat or system prompt. BARD is agent-agnostic — the workflow is the same regardless of which tool you use.

> **Cursor note:** Cursor 1.0 has no global rules file that auto-loads across sessions. Use `bard show` to resolve skills and paste manually. The `~/.cursor/skills` symlink is there for direct file access and future compatibility.

## Requirements

- bash 3.2+
- git
- jq (`brew install jq`)

