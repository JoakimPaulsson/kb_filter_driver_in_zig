# Keyboard filter driver in Zig

> [!CAUTION]
> This is a work in progress and will not compile as is. We are running in to [Issue #1499](https://github.com/ziglang/zig/issues/1499). The plan is to patch the translation output in the build script.

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
