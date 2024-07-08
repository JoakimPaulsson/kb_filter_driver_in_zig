// SPDX-FileCopyrightText: 2024 Joakim Paulsson <jkmdn@proton.me>
// SPDX-License-Identifier: MIT
//
// MIT License
//
//  Copyright (c) 2024 Joakim Paulsson jkmdn@proton.me

const win = @import("std").os.windows;
const ntdef = @import("ntdef");
const UNICODE_STRING = ntdef.UNICODE_STRING;
const NTSTATUS = ntdef.NTSTATUS;

const wdm = @import("wdm");
const PDRIVER_OBJECT = wdm.PDRIVER_OBJECT;

const dpfilter = @import("dpfilter");
const DPFLTR_IHVDRIVER_ID = dpfilter.DPFLTR_IHVDRIVER_ID;
const DPFLTR_ERROR_LEVEL = dpfilter.DPFLTR_ERROR_LEVEL;

pub fn driverEntry(_: PDRIVER_OBJECT, _: *const UNICODE_STRING) callconv(.C) NTSTATUS {
    const kbfltr: *const [22:0]u8 = "Keyboard Filter Driver";
    _ = wdm.DbgPrintEx(DPFLTR_IHVDRIVER_ID, DPFLTR_ERROR_LEVEL, kbfltr);
    return 0;
}

comptime {
    @export(driverEntry, .{ .name = "DriverEntry" });
}
