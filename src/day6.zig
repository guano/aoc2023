// --- Day 6: Wait For It ---
// Your toy boat has a starting speed of zero millimeters per millisecond. For each whole millisecond you spend at the beginning of the race holding down the button, the boat's speed increases by one millimeter per millisecond.
//
//
// Time:      7  15   30
// Distance:  9  40  200
//
// This document describes three races:
//
//     The first race lasts 7 milliseconds. The record distance in this race is 9 millimeters.
//     The second race lasts 15 milliseconds. The record distance in this race is 40 millimeters.
//     The third race lasts 30 milliseconds. The record distance in this race is 200 millimeters.
//
//Since the current record for this race is 9 millimeters, there are actually 4 different ways you could win: you could hold the button for 2, 3, 4, or 5 milliseconds at the start of the race.
// In the second race, you could hold the button for at least 4 milliseconds and at most 11 milliseconds and beat the record, a total of 8 different ways to win.
// In the third race, you could hold the button for at least 11 milliseconds and no more than 19 milliseconds and still beat the record, a total of 9 ways you could win.
// To see how much margin of error you have, determine the number of ways you can beat the record in each race; in this example, if you multiply these values together, you get 288 (4 * 8 * 9).
// Determine the number of ways you could beat the record in each race. What do you get if you multiply these numbers together?
//

const std = @import("std");
const expect = std.testing.expect;
const stdout = std.io.getStdOut().writer();
const Chameleon = @import("chameleon.zig");

const race = struct { time: u64, distance: u64 };
fn get_races(times: []const u8, distances: []const u8, races: *std.ArrayList(race)) !void {
    const times_str = std.mem.trimLeft(u8, times, "Time:");
    const distances_str = std.mem.trimLeft(u8, distances, "Distance:");

    var t = std.mem.splitAny(u8, times_str, " ");
    var d = std.mem.splitAny(u8, distances_str, " ");

    while (t.next()) |time| {
        if (time.len == 0) {
            continue;
        } else {
            const time_num = try std.fmt.parseInt(u32, time, 0);
            std.debug.print("time:{d}", .{time_num});

            while (d.next()) |distance| {
                if (distance.len == 0) {
                    continue;
                } else {
                    const distance_num = try std.fmt.parseInt(u32, distance, 0);
                    std.debug.print("distance:{d}", .{distance_num});

                    const r = race{ .time = time_num, .distance = distance_num };
                    try races.append(r);
                    break;
                }
            }
        }
        std.debug.print("\n", .{});
    }
}

// All of the races are actually one race with spaces! re-parse and eliminate the spaces
fn get_races_part2(times: []const u8, distances: []const u8) !race {
    const times_str = std.mem.trimLeft(u8, times, "Time:");
    const distances_str = std.mem.trimLeft(u8, distances, "Distance:");

    var t = std.mem.splitAny(u8, times_str, " ");
    var d = std.mem.splitAny(u8, distances_str, " ");

    var t_full: [100]u8 = [_]u8{0} ** 100;
    var d_full: [100]u8 = [_]u8{0} ** 100;

    var t_index: usize = 0;
    var d_index: usize = 0;

    while (t.next()) |time| {
        if (time.len == 0) {
            continue;
        } else {
            // TODO: couldn't figure out how to do this > 1 char at a time
            for (time) |char| {
                //std.debug.print("\nputting {c} into index {d}\n", .{ char, t_index });
                t_full[t_index] = char;
                t_index += 1;
            }
        }
    }

    while (d.next()) |distance| {
        if (distance.len == 0) {
            continue;
        } else {
            // TODO: couldn't figure out how to do this > 1 char at a time
            for (distance) |char| {
                //std.debug.print("\nputting {c} into index {d}\n", .{ char, d_index });
                d_full[d_index] = char;
                d_index += 1;
            }
        }
    }
    //std.debug.print("\ntime:{any}xx", .{t_full});
    //std.debug.print("\ndistance:{any}xx", .{d_full});
    const tt = t_full[0..t_index];
    const dd = d_full[0..d_index];
    //std.debug.print("\ntime:{any}xx", .{tt});
    //std.debug.print("\ndistance:{any}xx", .{dd});

    const fulltime = try std.fmt.parseInt(u64, tt, 0);
    std.debug.print("\ntime: {d}", .{fulltime});
    const fulldist = try std.fmt.parseInt(u64, dd, 0);
    std.debug.print("\ndistance: {d}", .{fulldist});

    return race{ .time = fulltime, .distance = fulldist };
}

// Naive way to count wins. Just calculate all of them and add them up
fn get_num_wins(r: race) u32 {
    var count: u32 = 0;
    for (0..r.time) |w| {
        if (w * (r.time - w) > r.distance) {
            count += 1;
        }
    }
    return count;
}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    std.debug.print("Hello, {s}!\n", .{"World"});

    // Arguments
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.process.argsFree(std.heap.page_allocator, args);

    if (args.len < 2) {
        std.debug.print("You idiot, you need to give the filename for the day as input!\n", .{});
        return error.ExpectedArgument;
    }

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
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var list = std.ArrayList([]u8).init(allocator);
    defer list.deinit();

    // Color print
    var c = Chameleon.initRuntime(.{ .allocator = allocator });
    defer c.deinit();
    try c.green().bold().printOut("Hello, world!\n", .{});

    while (try in_stream.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
        try list.append(line);
    }
    if (list.items.len != 2) {
        try c.red().bold().printOut("should be 2 lines long: {any}\n", .{list.items});
        // TODO: raise an error here
    }

    var races = std.ArrayList(race).init(allocator);
    defer races.deinit();
    try get_races(list.items[0], list.items[1], &races);

    const bigrace = try get_races_part2(list.items[0], list.items[1]);
    try c.yellow().bold().printOut("\nbigrace: {any}\n", .{bigrace});

    var wins_total: u64 = 1; // start with 1 because we multiply
    for (races.items) |r| {
        const num_wins = get_num_wins(r);
        try c.cyan().bold().printOut("\nwins: {d}, race: {any}\n", .{ num_wins, r });
        wins_total *= num_wins;
    }
    try c.green().bold().printOut("\ntotal wins: {d}\n", .{wins_total});

    // Time for some algebra with floating point
    // the distance we go = waittime * (totaltime - waittime); d = w(t-w)
    // the derivative of that dw/dt = -2w + t
    // Set derivative = 0 to find max (hint, it's t/2)
    // Use the quadratic formula to figure out when we equal the record
    // subtract the two roots and we have the number of ways to win the race
    const time: f64 = @floatFromInt(bigrace.time);
    const distance: f64 = @floatFromInt(bigrace.distance);

    const base_time: f64 = time / 2;

    const discriminant: f64 = std.math.pow(f64, time, 2) - 4 * distance;
    const disc: f64 = std.math.sqrt(discriminant) / 2;

    const roots: [2]f64 = .{ base_time - disc, base_time + disc };

    const roots_int: [2]u64 = .{ @intFromFloat(roots[0]), @intFromFloat(roots[1]) };

    try c.green().bold().printOut("\nmax: {any}, disc: {any}, roots: {any}, {any}, rootsint: {d}, {d}\n", .{ base_time, disc, roots[0], roots[1], roots_int[0], roots_int[1] });

    try c.green().bold().printOut("Number of ways to win the bigrace: {d}\n", .{roots_int[1] - roots_int[0]});
}
