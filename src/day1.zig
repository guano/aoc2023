// The newly-improved calibration document consists of lines of text; each line originally contained a specific calibration value that the Elves now need to recover. On each line, the calibration value can be found by combining the first digit and the last digit (in that order) to form a single two-digit number.
//
// For example:
//
// 1abc2
// pqr3stu8vwx
// a1b2c3d4e5f
// treb7uchet
//
// In this example, the calibration values of these four lines are 12, 38, 15, and 77. Adding these together produces 142.
//
// Consider your entire calibration document. What is the sum of all of the calibration values?

const std = @import("std");
const expect = std.testing.expect;

//fn file_open_and_get_total() ![]u8 {
fn file_open_and_get_total(infile: []u8) !u32 {
    std.debug.print("infile: {s}\n", .{infile});
    // try to open a file starting from the cwd Current Working Directory
    const file = try std.fs.cwd().openFile(
        infile,
        .{ .mode = .read_only },
    );
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var linecount: u32 = 0;

    var total: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        //std.debug.print("Line {d}: {s}\n", .{ linecount, line });
        linecount += 1;

        var first: ?u8 = null;
        var last: ?u8 = null;
        for (line) |char| {
            //std.debug.print("{c}", .{char});
            switch (char) {
                '0'...'9' => { // std.ascii.isDigit is probably better
                    //std.debug.print("Y", .{});
                    if (first == null) first = char;
                    last = char;
                },
                else => {
                    //std.debug.print("N", .{});
                },
            }
            //std.debug.print(" ", .{});
        }
        const combined: [2]u8 = .{ first orelse '!', last orelse '!' };
        //std.debug.print("first: {c}, last: {c} combined: {s}\n", .{ first orelse 0, last orelse 0, combined });
        //std.debug.print("combined: {s}\n", .{combined});
        //pub fn parseInt(comptime T: type, buf: []const u8, base: u8) ParseIntError!T
        //std.debug.print("Line {d} combined: {s} {d}: {s}\n", .{ linecount, combined, combined_int, line });
        const combined_int = try std.fmt.parseInt(u8, &combined, 0);

        std.debug.print("Line {d} combined: {d}: {s}\n", .{ linecount, combined_int, line });
        total += combined_int;
    }
    std.debug.print("total: {d}\n", .{total});
    return total;
}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    std.debug.print("Hello, {s}!\n", .{"World"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    // Buffered writers are for suckers
    //const stdout = bw.writer();
    const stdout = stdout_file;

    try stdout.print("Run `zig build test` to run the tests.\n", .{});
    try bw.flush(); // Don't forget to flush!

    // Arguments
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.process.argsFree(std.heap.page_allocator, args);

    if (args.len < 2) {
        std.debug.print("You idiot, you need to give the filename as input!\n", .{});
        return error.ExpectedArgument;
    }

    for (args, 0..) |arg, i| {
        if (i == 0) continue;
        try stdout.print("arg {}: {s} type: {}\n", .{ i, arg, @TypeOf(arg) });
    }
    try stdout_file.print("how many toes does a fish have?: {}\n", .{123});
    try stdout.print("Filename opening: {s}\n", .{args[1]});

    const total = try file_open_and_get_total(args[1]);
    try stdout.print("total: {d}\n", .{total});
}
