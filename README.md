# claude-toolkit

My skills, plugins and MCP servers for coding agents, in one repo. It works with Claude Code, Cursor, Codex, Copilot, Gemini CLI, OpenCode and any other agent that reads `SKILL.md` skills or MCP config.

## What's in it

| | Group | Skills | MCP server | Claude Code plugin |
| --- | --- | --- | --- | --- |
| My own skills | core | [`skills/`](skills) | | `my-skills` |
| Matt Pocock | core | [mattpocock/skills](https://github.com/mattpocock/skills) | | `mattpocock-skills` |
| Emil Kowalski | core | [emilkowalski/skills](https://github.com/emilkowalski/skills) | | `emil-design-eng` |
| Taste Skill | core | [`design-taste-frontend`](https://github.com/Leonxlnx/taste-skill) | | `taste-skill` |
| Vercel | platform | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | `https://mcp.vercel.com` | `vercel` |
| Neon | platform | [neondatabase/agent-skills](https://github.com/neondatabase/agent-skills) | `https://mcp.neon.tech/mcp` | `neon` |
| Supabase | platform | [supabase/agent-skills](https://github.com/supabase/agent-skills) | `https://mcp.supabase.com/mcp` | `supabase` |
| Linear | platform | | `https://mcp.linear.app/mcp` | `linear` |
| GitHub | platform | | `https://api.githubcopilot.com/mcp/` | `github` |
| HyperFrames (HeyGen) | content | [heygen-com/hyperframes](https://github.com/heygen-com/hyperframes) | | `hyperframes` |

**Core** is useful in every project. **Platform** is only worth turning on in projects that use that platform. **Content** is for making videos and other media.

## Install

### Any agent: skills

This uses [`npx skills`](https://github.com/vercel-labs/skills), which copies skills into each agent's skills folder.

```bash
curl -fsSL https://raw.githubusercontent.com/nguyeehub/claude-toolkit/main/scripts/install-skills.sh | bash -s -- core
```

- **Choose groups or repos:** `core`, `platform`, `content`, `all`, or any repo from [`skills.txt`](skills.txt), e.g. `core supabase/agent-skills`.
- **Choose agents:** add `--agent "cursor codex"`. The default is every agent `npx skills` supports.
- **Install for every project** instead of the current one: add `--global`.

### Any agent: MCP servers

[`mcp.json`](mcp.json) lists every server in the common `mcpServers` format. Copy the entries you want into your agent's config:

| Agent | Config file |
| --- | --- |
| Cursor | `.cursor/mcp.json` (project) or `~/.cursor/mcp.json` |
| Claude Code | `.mcp.json` (project), or use the plugins below |
| VS Code / Copilot | `.vscode/mcp.json` (uses `servers` instead of `mcpServers`) |
| Codex | `~/.codex/config.toml`, under `[mcp_servers.<name>]` |
| Gemini CLI | `~/.gemini/settings.json` |

Every server signs in with OAuth on first use, except GitHub, which reads `GITHUB_PERSONAL_ACCESS_TOKEN`.

### Claude Code cloud sessions

Cloud sessions don't load plugins, whether they're enabled in a repo's settings or in user settings. They do load skills from `~/.claude/skills`, so install the skills there from the environment's setup script. Paste this into the **Setup script** field of your cloud environment, e.g. **Default**, so it applies to every repo:

```bash
#!/bin/bash
curl -fsSL https://raw.githubusercontent.com/nguyeehub/claude-toolkit/main/scripts/install-skills.sh \
  | bash -s -- --global --agent claude-code all || true
```

For MCP in cloud sessions, use claude.ai connectors, or commit a project `.mcp.json` built from [`mcp.json`](mcp.json).

### Claude Code on your machine: plugins

Locally, the plugins bundle skills, MCP and hooks together.

- **Just one plugin:**
  ```
  /plugin install my-skills --marketplace nguyeehub/claude-toolkit
  ```
- **One project:** turn the plugins on in the project's `.claude/settings.json`, and commit it so collaborators get them too. This doesn't reach cloud sessions.
  ```bash
  ~/coding\ projects/claude-toolkit/scripts/install.sh --project . core vercel neon
  ```
- **Every project on this machine:**
  ```bash
  curl -fsSL https://raw.githubusercontent.com/nguyeehub/claude-toolkit/main/scripts/install.sh | bash -s -- --global core
  ```

## Add things

- **Your own skill:** add `skills/<name>/SKILL.md`, with `name` and `description` in its frontmatter. It reaches every agent through `npx skills`, and Claude Code through the `my-skills` plugin.
- **Someone else's skill repo:** add a line to [`skills.txt`](skills.txt) (add a comma-separated skill list after the group to install only those skills), and an entry to [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json) for Claude Code. If the repo has no plugin manifest, give its entry `"strict": false` and Claude Code will find its `skills/` folder, as with `emil-design-eng`.
- **An MCP server:** add it to [`mcp.json`](mcp.json).
- **Check it:** run `claude plugin validate .`.

## Updates

Nothing is pinned, so everything tracks each upstream repo's default branch.

| Where | How you get updates |
| --- | --- |
| Claude Code cloud sessions | The setup script's result is cached for about 7 days, then rebuilt with the latest. Edit the setup script (even a comment) to rebuild sooner. |
| Claude Code on your machine | `claude plugin marketplace update claude-toolkit`, then `claude plugin update <name>@claude-toolkit` |
| Other agents | `npx skills update`, or rerun `install-skills.sh` |

If an upstream change breaks something, pin it. For Claude Code, add `"sha": "<commit>"` to its `source` in `marketplace.json`. For `npx skills`, install a specific ref instead of the repo name.

## Notes

- Matt and Emil both ship a skill called `prototype`. Claude Code keeps both, as `mattpocock-skills:prototype` and `emil-design-eng:prototype`. In other agents, whichever installs last wins.
- Some things are Claude Code-only, such as the Vercel plugin's hooks. Other agents get the skills and MCP servers.
- Wispr Flow isn't here because it has no public plugin or skills. Connect it through your agent's connector or MCP settings.
