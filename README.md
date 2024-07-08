# Keyboard filter driver in Zig

> [!CAUTION]
> This is a work in progress. We are running in to [Issue #1499](https://github.com/ziglang/zig/issues/1499). We are patching the translation output in the build script pretty aggressively. One improvement would be to patch only unions with oqaque types.

This project aims to develop a keyboard filter driver using Zig. 

## Building
### Requirements

- Windows 10 with WSL
- Visual Studio 2022 Community
    - _NOTE: the MSVC build tool version is hard coded for now_
- Windows SDK + WDK version 10.0.26100.0
- Nix with Flakes
    - This will make sure the Zig compiler has the correct version and you don't need to have installed beforehand
- Optional: Direnv

### Building

**NOTE:** the patching of the translation outputs doesn't always apply and require a clean build.

#### Using direnv
```shell
> direnv allow
> zig build
```
once ``direnv allow`` is ran once, you won't need to run it again.

#### Using Nix with Flakes without direnv
```shell
> direnv allow
> zig build
```

#### Using Nix without Flakes and direnv
_Not implemented yet!_

### Installation
_TBD_
