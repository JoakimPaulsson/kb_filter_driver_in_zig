// SPDX-FileCopyrightText: 2024 Joakim Paulsson <jkmdn@proton.me>
// SPDX-License-Identifier: MIT
//
// MIT License
//
//  Copyright (c) 2024 Joakim Paulsson jkmdn@proton.me

const win = @import("std").os.windows;
const wdk = @cImport({
    @cDefine("_AMD64_", "1");
    @cDefine("_KERNEL_MODE", "1");
    @cDefine("POOL_NX_OPTIN", "1");
    @cDefine("POOL_ZERO_DOWN_LEVEL_SUPPORT", "1");
    @cDefine("_UNICODE", "1");
    @cDefine("UNICODE", "1");
    @cInclude("ntifs.h");
    @cInclude("ntddk.h");
    @cInclude("wdm.h");
    @cInclude("ntstrsafe.h");
    @cInclude("ntimage.h");
    @cInclude("fltkernel.h");
});

pub fn driverEntry(_: wdk.PDRIVER_OBJECT, _: *const wdk.UNICODE_STRING) callconv(.C) wdk.NTSTATUS {
    const kbfltr: *const [35:0]u8 = "Keyboard Filter Driver";
    _ = wdk.DbgPrintEx(wdk.DPFLTR_IHVDRIVER_ID, wdk.DPFLTR_ERROR_LEVEL, kbfltr);
    return 0;
}

comptime {
    @export(driverEntry, .{ .name = "DriverEntry" });
}
