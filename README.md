# dosatsu

dosatsu helps developers who use coding agents to generate pull requests
understand those pull requests better. It is a plugin for Claude Code and
Codex.

## Status

Early. The plugin ships one skill, `understanding-changes`.

## Install

Claude Code:

```sh
claude plugin marketplace add j7an/dosatsu
claude plugin install dosatsu@dosatsu
```

Codex:

```sh
codex plugin marketplace add j7an/dosatsu
codex plugin add dosatsu@dosatsu
```

## Use

The `understanding-changes` skill has you explain a change in your own
words, one part at a time, and checks what you say against the code. It
corrects what you got wrong, teaches what is new to you, and ends with the
gaps that are left.

Ask for it in plain words, on Claude Code or Codex:

- "Help me understand this branch."
- "Help me understand commit `<sha>`."
- "Help me understand release `<tag>`."

On Claude Code you can also run `/dosatsu:understanding-changes`, followed
by a commit or `release <tag>`, or by nothing for the current branch.

Run it inside a checkout of the repository. It covers committed changes
only.

## Update

If you installed before `v0.1.0`, uninstall and install again.

Claude Code:

```sh
claude plugin marketplace update dosatsu
claude plugin update dosatsu@dosatsu
```

Codex:

```sh
codex plugin marketplace upgrade dosatsu
codex plugin add dosatsu@dosatsu
```

## Uninstall

Claude Code:

```sh
claude plugin uninstall dosatsu@dosatsu
claude plugin marketplace remove dosatsu
```

Codex:

```sh
codex plugin remove dosatsu@dosatsu
codex plugin marketplace remove dosatsu
```

## License

MIT
