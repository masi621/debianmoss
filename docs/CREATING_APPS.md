# Creating apps for DebianMOSS

DebianMOSS supports two practical app styles:

1. terminal-first apps
2. desktop apps with `.desktop` launchers

## Optional `mossapp.json`

`mosspkg` can turn a simple manifest into a desktop entry.

```json
{
  "name": "Cool Tool",
  "exec": "/home/moss/.local/bin/cool-tool",
  "icon": "utilities-terminal",
  "terminal": false,
  "categories": "Development;Utility;"
}
```
