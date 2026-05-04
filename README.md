# ccluau

a Luau to CC:Tweaked Lua (Cobalt) transpiler that can bundle itself. it lets you run raw Luau code on CC:Tweaked computers and turtles without worrying about version compatibility.

it preserves line positions for function calls, so when your code crashes in CraftOS, the line numbers actually match your Luau source.

## features

- **Luau support**: transpile Luau code to Lua 5.1 (Cobalt) compatible code.
- **self-bundling**: the transpiler is written in Luau and can transpile itself into a single Lua file that runs directly on a CC:Tweaked computer.
- **error alignment**: preserves line numbers for function calls so debugging doesn't suck.
- **type definitions**: includes full type definitions for the CC:Tweaked API.
- **polyfills**: automatically includes polyfills for Luau features that aren't in standard Lua.

## installation

### cli (linux)
if you're on linux, you can use the setup script to install Lune and get everything ready:
```bash
chmod +x setup
./setup
```

### CC:Tweaked
you can generate a setup script for CraftOS by running the bundler:
```bash
lune run bundler/main.luau
```
this will upload a setup script to x0.at and give you a command to run in your CC:Tweaked computer.

## usage

### transpiling a file
to transpile a `.luau` file to `.lua`:
```bash
lune run transpiler/main.luau <input.luau> [output.lua]
```

### vscode setup
to get autocompletion and type checking for the CC:Tweaked API, add this to your `.vscode/settings.json`:

```json
{
    "luau-lsp.types.definitionFiles": {
        "cctweaked": "typedefs/cctweaked.d.luau"
    }
}
```

## license

MIT - copyright (c) 2026 bitceil
