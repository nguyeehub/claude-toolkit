# claude-toolkit

My Claude Code skills and plugins, packaged as a plugin marketplace so the same setup works in local, project and cloud sessions.

## What's in it

| Plugin | Group | Source |
| --- | --- | --- |
| `my-skills` | core | [`plugins/my-skills`](plugins/my-skills) (this repo) |
| `mattpocock-skills` | core | [mattpocock/skills](https://github.com/mattpocock/skills) |
| `emil-design-eng` | core | [emilkowalski/skills](https://github.com/emilkowalski/skills) |
| `vercel` | platform | [vercel/vercel-plugin](https://github.com/vercel/vercel-plugin) |
| `neon` | platform | [neondatabase/agent-skills](https://github.com/neondatabase/agent-skills) |
| `supabase` | platform | [supabase-community/supabase-plugin](https://github.com/supabase-community/supabase-plugin) |
| `linear` | platform | [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/linear) |
| `github` | platform | [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/github) |

Wispr Flow isn't here because it has no plugin. It's a claude.ai connector, which follows your account into cloud sessions on its own.

## Use it

**In a project.** Commit the result, and every cloud session on that repo gets these plugins:

```bash
~/coding\ projects/claude-toolkit/scripts/install.sh --project . core vercel neon
```

**Machine-wide, e.g. a cloud environment's setup script:**

```bash
curl -fsSL https://raw.githubusercontent.com/nguyeehub/claude-toolkit/main/scripts/install.sh | bash -s -- --global core
```

Arguments are groups (`core`, `platform`, `all`) or plugin names, and you can mix them. The default is `core`.

## Add things

- **Your own skill:** add `plugins/my-skills/skills/<name>/SKILL.md` and push.
- **Someone else's plugin or skill repo:** add an entry to [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json) with a `category` of `core` or `platform`. A repo that's only a `skills/` folder with no plugin manifest still works if you add `"strict": false`, as with `emil-design-eng`.
- Check it with `claude plugin validate .` (Claude Code 2.1.2xx or newer).

## Updates

Upstream entries aren't pinned, so they track each repo's default branch:

- **Cloud sessions** start fresh and get the latest versions every time. There's nothing to run.
- **Local machines** keep a cache. Refresh it with `claude plugin marketplace update claude-toolkit`, then `claude plugin update <name>@claude-toolkit`.

If an upstream change breaks something, pin that entry by adding `"sha": "<commit>"` to its `source`, and bump the sha when you're ready to move.

## Notes

- The `github` plugin reads `GITHUB_PERSONAL_ACCESS_TOKEN` from the environment.
- Vercel, Neon, Supabase and Linear are also claude.ai connectors on my account. Turning on the plugin as well gives you their skills, but it can duplicate MCP tools, so turn on platform plugins only in the projects that use them.
