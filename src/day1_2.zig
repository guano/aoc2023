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
//
// /////////////////////
// This version is cleaned up a bit

const std = @import("std");
const expect = std.testing.expect;

fn parse_line_first_and_last(line: []const u8) !u32 {
    var first: ?u8 = null;
    var last: ?u8 = null;
    for (line) |char| {
        if (std.ascii.isDigit(char)) {
            last = char;
            if (first == null) first = char;
        }
    }
    const combined: [2]u8 = .{ first orelse '!', last orelse '!' };
    const combined_int = try std.fmt.parseInt(u8, &combined, 0);

    //std.debug.print("number: {d}: {s}\n", .{ combined_int, line });
    return combined_int;
}

fn word_to_numberchar(word: []const u8) ?u8 {
    if (std.mem.eql(u8, word, "zero")) {
        return '0';
    }
    if (std.mem.eql(u8, word, "one")) {
        return '1';
    }
    if (std.mem.eql(u8, word, "two")) {
        return '2';
    }
    if (std.mem.eql(u8, word, "three")) {
        return '3';
    }
    if (std.mem.eql(u8, word, "four")) {
        return '4';
    }
    if (std.mem.eql(u8, word, "five")) {
        return '5';
    }
    if (std.mem.eql(u8, word, "six")) {
        return '6';
    }
    if (std.mem.eql(u8, word, "seven")) {
        return '7';
    }
    if (std.mem.eql(u8, word, "eight")) {
        return '8';
    }
    if (std.mem.eql(u8, word, "nine")) {
        return '9';
    }
    return null;
    //switch (word) {
    //    "zero" =>   {return 1;},
    //    "one" =>    {return 1;},
    //    //-1...1 => {
    //    //    x = -x;
    //    //},
    //    //10, 100 => {
    //    //    //special considerations must be made
    //    //    //when dividing signed integers
    //    //    x = @divExact(x, 10);
    //    //},
    //    else => {return null;},
    //}
}

fn parse_line_spelled(line: []const u8) !u32 {
    // Need to get substrings
    var first: ?u8 = null;
    var last: ?u8 = null;
    //std.debug.print("{s}\n", .{line});
    character: for (line, 0..) |char, index| {
        //std.debug.print("sub: {s} ", .{line[index..line.len]});

        // If this index is a digit, don't try to get a word starting from here
        if (std.ascii.isDigit(char)) {
            last = char;
            if (first == null) first = char;
            continue :character;
        }

        // Go through all possible substrings
        var x: usize = index + 1;
        while (x <= line.len) : (x += 1) {
            const substring = line[index..x];
            //std.debug.print("{s} ", .{substring});

            const number: ?u8 = word_to_numberchar(substring);
            if (number != null) {
                last = number;
                if (first == null) {
                    first = number;
                }
            }
        }
        //std.debug.print("\n", .{});
    }
    const combined: [2]u8 = .{ first orelse '!', last orelse '!' };
    //std.debug.print("\n\ncombined:{c}\n", .{combined});
    const combined_int = try std.fmt.parseInt(u8, &combined, 0);

    //std.debug.print("number: {d}: {s}\n", .{ combined_int, line });
    return combined_int;
}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    std.debug.print("Hello, {s}!\n", .{"World"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout = std.io.getStdOut().writer();
    //var bw = std.io.bufferedWriter(stdout);
    //// Buffered writers are for suckers
    ////const stdout = bw.writer();
    //try stdout.print("Run `zig build test` to run the tests.\n", .{});
    //try bw.flush(); // Don't forget to flush!

    // Arguments
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.process.argsFree(std.heap.page_allocator, args);

    if (args.len < 2) {
        std.debug.print("You idiot, you need to give the filename for part 1 as input\n", .{});
        return error.ExpectedArgument;
    }

    // debugging arguments
    //for (args, 0..) |arg, i| {
    //    if (i == 0) continue;
    //    try stdout.print("arg {}: {s} type: {}\n", .{ i, arg, @TypeOf(arg) });
    //}

    ///////////////////////////////////////////////////////////////////////////
    // Part 1
    const infile = args[1];

    ////////////////////////////////////
    // Opening the file
    std.debug.print("infile: {s}\n", .{infile});
    const file = try std.fs.cwd().openFile(infile, .{ .mode = .read_only });
    defer file.close();

    var br = std.io.bufferedReader(file.reader());
    var in_stream = br.reader();

    ////////////////////////////////////
    // Reading the file (part 1)
    var buf: [1024]u8 = undefined;
    var total: u32 = 0;
    var total2: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        ////////////////////////////////////
        // Adding the total
        total += try parse_line_first_and_last(line);
        total2 += try parse_line_spelled(line);
    }

    try stdout.print("total: {d}\n", .{total});
    try stdout.print("total2: {d}\n", .{total2});
}
