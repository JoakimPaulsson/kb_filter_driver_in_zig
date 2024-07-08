// SPDX-FileCopyrightText: 2024 Joakim Paulsson <jkmdn@proton.me>
// SPDX-License-Identifier: MIT
//
// MIT License
//
//  Copyright (c) 2024 Joakim Paulsson jkmdn@proton.me

const std = @import("std");
const OptimizeMode = std.builtin.OptimizeMode;
const ResolvedTarget = std.Build.ResolvedTarget;
const Build = std.Build;
const LazyPath = Build.LazyPath;
const TranslateC = Build.Step.TranslateC;

const win_kit = "/mnt/c/Program Files (x86)/Windows Kits/10";

const win_kit_include = win_kit ++ "/Include/";
const win_kit_version = "10.0.26100.0";

const km_include_path_raw = win_kit_include ++ win_kit_version ++ "/km/";
const shared_include_path_raw = win_kit_include ++ win_kit_version ++ "/shared/";
const ucrt_include_path_raw = win_kit_include ++ win_kit_version ++ "/ucrt/";
const vs_include_path_raw = "/mnt/c/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.40.33807/include/";

const km_include_path = LazyPath{ .cwd_relative = km_include_path_raw };
const shared_include_path = LazyPath{ .cwd_relative = shared_include_path_raw };
const ucrt_include_path = LazyPath{ .cwd_relative = ucrt_include_path_raw };
const vs_include_path = LazyPath{ .cwd_relative = vs_include_path_raw };

fn addHeaderAsModule(
    b: *Build,
    optimize: OptimizeMode,
    target: ResolvedTarget,
    obj: *Build.Step.Compile,
    comptime name: []const u8,
    comptime path: []const u8,
) void {
    const cwd_relative = path ++ name ++ ".h";
    const translation = b.addTranslateC(.{
        .root_source_file = LazyPath{ .cwd_relative = cwd_relative },
        .target = target,
        .optimize = optimize,
        .link_libc = false,
    });

    translation.defineCMacroRaw("_AMD64_");
    translation.defineCMacroRaw("_KERNEL_MODE");

    translation.addIncludeDir(km_include_path_raw);
    translation.addIncludeDir(shared_include_path_raw);
    translation.addIncludeDir(ucrt_include_path_raw);
    translation.addIncludeDir(vs_include_path_raw);

    const module = translation.addModule(name);
    translationPatches(b, obj, translation, name);
    obj.root_module.addImport(name, module);
}

fn unionOpaquePatch(
    b: *Build,
    file_path: LazyPath,
) *Build.Step.Run {
    const cmd = b.addSystemCommand(&.{ "sed", "-i", "s/unnamed_0: /unnamed_0: */" });
    cmd.addFileArg(file_path);
    return cmd;
}

fn translationPatches(
    b: *Build,
    obj: *Build.Step.Compile,
    translation: *TranslateC,
    comptime name: []const u8,
) void {
    if (std.mem.eql(u8, name, "wdm")) {
        const output_file = translation.getOutput();
        const patch2 = unionOpaquePatch(b, output_file);

        patch2.step.dependOn(&translation.step);

        const step = b.step(name ++ "_patch_step", name);
        step.dependOn(&translation.step);
        step.dependOn(&patch2.step);

        b.getInstallStep().dependOn(step);

        obj.step.dependOn(step);
    }
}

pub fn build(b: *Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.resolveTargetQuery(.{ .os_tag = .windows, .abi = .msvc });

    const obj = b.addObject(.{
        .name = "kbfltr",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    addHeaderAsModule(b, optimize, target, obj, "fltkernel", km_include_path_raw);
    addHeaderAsModule(b, optimize, target, obj, "dpfilter", shared_include_path_raw);
    addHeaderAsModule(b, optimize, target, obj, "ntdef", shared_include_path_raw);
    addHeaderAsModule(b, optimize, target, obj, "wdm", km_include_path_raw);

    const installing = b.addInstallArtifact(
        obj,
        .{ .dest_dir = .{ .override = .{ .custom = "obj" } } },
    );

    const link_exe = "/mnt/c/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.40.33807/bin/Hostx64/x64/link.exe";

    // /mnt/c/program files (x86)/windows kits/10/lib/10.0.26100.0/km/x64
    // const lib_path = "/LIBPATH:" ++ win_kit ++ "/Lib/" ++ win_kit_version ++ "/km/x64";
    const lib_path = "/LIBPATH:C:\\Program Files (x86)\\Windows Kits\\10\\Lib\\10.0.26100.0\\km\\x64";
    // std.debug.print("lib path: {s}\n\n", .{lib_path});

    const driver_out_path = "./zig-out/driver/";
    const mk_driver_out_path = b.addSystemCommand(&.{ "mkdir", "-p", driver_out_path });

    // const obj_path = obj.out_filename;
    const obj_path = "./zig-out/obj/kbfltr.obj";
    const out = "/OUT:" ++ driver_out_path ++ "kbfltr.sys";
    const pdb = "/PDB:" ++ driver_out_path ++ "kbfltr.pdb";
    const map = "/MAP:" ++ driver_out_path ++ "kbfltr.map";

    const linking = b.addSystemCommand(&.{
        link_exe,
        lib_path,
        "/TIME",
        "/DEBUG",
        "/DRIVER",
        "/NODEFAULTLIB",
        "/NODEFAULTLIB:libucrt.lib",
        "/NODEFAULTLIB:libucrtd.lib",
        "/SUBSYSTEM:NATIVE",
        "/ENTRY:DriverEntry",
        "/NODEFAULTLIB:msvcrt.lib",
        "/OPT:REF",
        "/OPT:ICF",
        "ntoskrnl.lib",
        "hal.lib",
        "wmilib.lib",
        obj_path,
        out,
        pdb,
        map,
    });
    linking.step.dependOn(&obj.step);
    linking.step.dependOn(&mk_driver_out_path.step);

    b.getInstallStep().dependOn(&installing.step);
    b.getInstallStep().dependOn(&linking.step);
}
