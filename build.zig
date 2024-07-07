// SPDX-FileCopyrightText: 2024 Joakim Paulsson <jkmdn@proton.me>
// SPDX-License-Identifier: MIT
//
// MIT License
//
//  Copyright (c) 2024 Joakim Paulsson jkmdn@proton.me

const std = @import("std");
const LazyPath = std.Build.LazyPath;

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const obj = b.addObject(.{
        .name = "kbfltr",
        .root_source_file = b.path("src/main.zig"),
        .target = b.resolveTargetQuery(.{ .os_tag = .windows, .abi = .msvc }),
        .optimize = optimize,
        .link_libc = true,
    });

    const win_kit = "/mnt/c/Program Files (x86)/Windows Kits/10";

    const win_kit_include = win_kit ++ "/Include/";
    const win_kit_version = "10.0.26100.0";

    const km_include_path = LazyPath{
        .cwd_relative = win_kit_include ++ win_kit_version ++ "/km/",
    };
    const shared_include_path = LazyPath{
        .cwd_relative = win_kit_include ++ win_kit_version ++ "/shared/",
    };
    const ucrt_include_path = LazyPath{
        .cwd_relative = win_kit_include ++ win_kit_version ++ "/ucrt/",
    };
    const vs_include_path = LazyPath{
        .cwd_relative = "/mnt/c/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.40.33807/include/",
    };

    obj.addIncludePath(km_include_path);
    obj.addIncludePath(shared_include_path);
    obj.addIncludePath(ucrt_include_path);
    obj.addIncludePath(vs_include_path);

    const installing = b.addInstallArtifact(obj, .{ .dest_dir = .{ .override = .{ .custom = "obj" } } });

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
