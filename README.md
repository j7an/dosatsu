# dosatsu

dosatsu helps developers who use coding agents to generate pull requests
understand those pull requests better. It is a plugin for Claude Code and
Codex.

## Status

Early. The plugin installs on Claude Code and Codex but ships no skills yet.

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

## Update

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
