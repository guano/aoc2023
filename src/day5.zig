// --- Day 5: If You Give A Seed A Fertilizer ---
//
//With this map, you can look up the soil number required for each initial seed number:
//
//    Seed number 79 corresponds to soil number 81.
//    Seed number 14 corresponds to soil number 14.
//    Seed number 55 corresponds to soil number 57.
//    Seed number 13 corresponds to soil number 13.
//
//The gardener and his team want to get started as soon as possible, so they'd like to know the closest location that needs a seed. Using these maps, find the lowest location number that corresponds to any of the initial seeds. To do this, you'll need to convert each seed number through other categories until you can find its corresponding location number. In this example, the corresponding types are:
//
//    Seed 79, soil 81, fertilizer 81, water 81, light 74, temperature 78, humidity 78, location 82.
//    Seed 14, soil 14, fertilizer 53, water 49, light 42, temperature 42, humidity 43, location 43.
//    Seed 55, soil 57, fertilizer 57, water 53, light 46, temperature 82, humidity 82, location 86.
//    Seed 13, soil 13, fertilizer 52, water 41, light 34, temperature 34, humidity 35, location 35.
//
//So, the lowest location number in this example is 35.
//
//What is the lowest location number that corresponds to any of the initial seed numbers?

const std = @import("std");
const expect = std.testing.expect;
const stdout = std.io.getStdOut().writer();
const Chameleon = @import("chameleon.zig");

const almanac_tuple = struct { dst_start: u64, src_start: u64, length: u32 };
//const almanac_entry = struct { title: []u8, tuples: std.ArrayList(almanac_tuple), map: std.array_hash_map.AutoArrayHashMap(u32, u32) };
const almanac_entry = struct { title: []u8, tuples: std.ArrayList(almanac_tuple) };

// Parses a string line looking like "seeds: #### ### ## ## ##" and inserts the numbers into the arraylist
fn get_seeds(line: []u8, seedlist: *std.ArrayList(u32), seedtuples: *std.ArrayList([2]u32)) !void {
    // Trim off the "seeds: " string
    const seedsonly = std.mem.trimLeft(u8, line, "seeds: ");
    // Split the rest of the line on spaces
    var split = std.mem.splitAny(u8, seedsonly, " ");

    // Parse the numbers and insert into the stringlist
    while (split.next()) |num_str| {
        //std.debug.print("num:{s}", .{num});
        if (num_str.len == 0) {
            continue;
        } else {
            const num_str2 = while (split.next()) |n| {
                if (n.len != 0) {
                    break n;
                }
            } else "";

            const num = try std.fmt.parseInt(u32, num_str, 0);
            const num2 = try std.fmt.parseInt(u32, num_str2, 0);
            try seedlist.append(num);
            try seedlist.append(num2);
            try seedtuples.append(.{ num, num2 });
        }
    }
}

fn parse_almanac_entry(allocator: std.mem.Allocator, lines: [][]u8) !almanac_entry {
    const name = lines[0];
    var list = std.ArrayList(almanac_tuple).init(allocator);

    for (lines, 0..) |line, index| {
        //std.debug.print("line: {s}\n", .{line});
        if (index == 0) {
            continue;
        }
        var split = std.mem.splitAny(u8, line, " ");
        const dest_start_str = split.next();
        const src_start_str = split.next();
        const range_len_str = split.next();

        const dest_start = try std.fmt.parseInt(u32, dest_start_str.?, 0);
        const src_start = try std.fmt.parseInt(u32, src_start_str.?, 0);
        const range_len = try std.fmt.parseInt(u32, range_len_str.?, 0);

        const tu: almanac_tuple = .{ .dst_start = dest_start, .src_start = src_start, .length = range_len };

        try list.append(tu);
    }
    return almanac_entry{ .title = name, .tuples = list };
}

fn map_single(tup: almanac_tuple, in: u64) ?u64 {
    if (in >= tup.src_start and in <= tup.src_start + tup.length) {
        const diff = in - tup.src_start;
        const dest = tup.dst_start + diff;
        return dest;
    }
    return null;
}

fn overlap(a: [2]u64, b: [2]u64) bool {
    if (a[0] >= b[0]) {
        // A[0] to right of B[0]
        if (a[0] <= b[0] + b[1]) {
            // A[0] inside of B
            return true;
        }
    } else {
        // A[0] to left of B[0]
        if (a[0] + a[1] >= b[0]) {
            // A[1] is to right of B[0] : Part of B is contained in A
            return true;
        }
    }
    return false;
}
const map_double_error = error{UnhandledCase};
const md_out = struct { out: ?[2]u64, fail: ?[2]?[2]u64 };
// Input: 2 tuples
//      Destination tuple
//      Source tuple
// Output:
//      1 or 0 success tuple (the intersection)
//      An array of 0-2 fail tuples, which correspond to source numbers not mapped
//          (pre-intersection, post-intersection)
//  TODO TODO TODO TODO: actually perform the map for the success
fn map_double(map: almanac_tuple, in: [2]u64) !md_out {
    //const almanac_tuple = struct { dst_start: u64, src_start: u64, length: u32 };
    if (in[0] < map.src_start and in[0] + in[1] < map.src_start) {
        // input strictly before output. 1 Fail: the input
        return md_out{ .out = null, .fail = [2]?[2]u64{ in, null } };
    } else if (in[0] < map.src_start and in[0] + in[1] < map.src_start + map.length) {
        // failed input on left, but overlap to end of input
        const i_len = in[0] + in[1] - map.src_start;
        const f_len = in[1] - i_len;

        const intersect = [2]u64{ in[0] + f_len, i_len };
        const fail = [2]u64{ in[0], f_len };

        return md_out{ .out = intersect, .fail = [2]?[2]u64{ fail, null } };
    } else if (in[0] < map.src_start and in[0] + in[1] > map.src_start + map.length) {
        // failed input on left AND failed input on right; extra overlap

        const intersect = [2]u64{ map.src_start, map.length };

        const f0_len = map.src_start - in[0];
        const fail0 = [2]u64{ in[0], f0_len };

        const f1_len = in[0] + in[1] - (map.src_start + map.length);
        const f1_start = map.src_start + map.length;
        const fail1 = [2]u64{ f1_start, f1_len };
        return md_out{ .out = intersect, .fail = [2]?[2]u64{ fail0, fail1 } };
    } else if (in[0] >= map.src_start and in[0] + in[1] <= map.src_start + map.length) {
        // All of input is successful
        return md_out{ .out = in, .fail = null };
    } else if (in[0] >= map.src_start and in[0] + in[1] > map.src_start + map.length) {
        // Intersect on left side of input, hangs off right side
        const f_start = map.src_start + map.length;
        const f_len = in[0] + in[1] - f_start;
        const fail = [2]u64{ f_start, f_len };

        const i_len = f_start - in[0];
        const intersect = [2]u64{ in[0], i_len };

        return md_out{ .out = intersect, .fail = [2]?[2]u64{ fail, null } };
    } else if (in[0] > map.src_start + map.length) {
        // Input is entirely to right
        return md_out{ .out = null, .fail = [2]?[2]u64{ in, null } };
    }
    return error{YouSuck};
}

fn get_almanac_map_value(entry: almanac_entry, in: u64) u64 {
    for (entry.tuples.items) |tup| {
        if (map_single(tup, in)) |result| {
            // If the input maps into anything, we have the result
            return result;
        }
    }
    // If the input doesn't map into anything, we keep the input
    return in;
}

pub fn main() !void {
    // Need an allocator for all our data
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Color print
    var c = Chameleon.initRuntime(.{ .allocator = allocator });
    defer c.deinit();
    try c.cyan().bold().printOut("Hello, World!\n", .{});

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
    // Reading the file
    var file_lines = std.ArrayList([]u8).init(allocator);
    try c.cyan().bold().printOut("arraylist type: {any}", .{@TypeOf(file_lines)});
    defer file_lines.deinit();

    // Almanac is a list of almanac entries
    var almanac = std.ArrayList(almanac_entry).init(allocator);
    defer almanac.deinit();

    // Seeds is a list of seed numbers
    var seeds = std.ArrayList(u32).init(allocator);
    var seed_tuples = std.ArrayList([2]u32).init(allocator);
    defer seeds.deinit();
    defer seed_tuples.deinit();

    var line_index: u32 = 0;
    var index_end_of_prev: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| : (line_index += 1) {
        try file_lines.append(line);

        try c.green().printOut("line {d} len {d}: {s}\n", .{ line_index, line.len, line });

        // First line of input is the seeds list
        if (line_index == 0) {
            try get_seeds(line, &seeds, &seed_tuples);
            try c.yellow().printOut("seeds: {any}\n", .{seeds.items});
        }

        if (line.len == 0) {
            // The line after seeds doesn't designate an almanac entry
            if (line_index == 1) {
                index_end_of_prev = line_index;
                continue;
            }

            //const a_e = parse_almanac_entry(file_lines.items[index_end_of_prev + 1 .. line_index]);
            const a_e = try parse_almanac_entry(allocator, file_lines.items[index_end_of_prev + 1 .. line_index]);
            try almanac.append(a_e);

            // try c.cyan().printOut("almanac_entry: {s}\n", .{a_e.title});
            // try c.cyan().printOut("keys: {any}\n", .{a_e.map.keys()});
            // try c.cyan().printOut("values: {any}\n", .{a_e.map.values()});
            index_end_of_prev = line_index;
        }
    }
    // Now we have the whole almanac, time to figure out which seeds
    // go into the least-valued plot
    var tmp: u64 = 0;
    var lowest: ?u64 = null;
    for (seeds.items) |seed| {
        tmp = seed;
        try c.blue().bold().printOut("\nseed {d}", .{seed});
        for (almanac.items) |a_e| {
            //_ = a_e;
            tmp = get_almanac_map_value(a_e, tmp);

            //const poop = a_e.map.get(tmp);
            //tmp = a_e.map.get(tmp) orelse tmp;
            //tmp = poop;
            try c.blue().bold().printOut("{s}{d}", .{ a_e.title, tmp });
        }
        lowest = if (lowest == null or tmp < lowest.?) tmp else lowest;
        try c.blue().bold().printOut(" curlow:{d}", .{lowest.?});
    }
    try c.blue().bold().printOut("\nIt's over! lowest:{d}\n", .{lowest.?});

    // Part 2: seed tuple boogaloo
    // go into the least-valued plot
    tmp = 0;
    lowest = null;
    for (seed_tuples.items) |seed_tuple| {
        //tmp = seed_tuple[0];
        //const seed_tuple_cnt = seed_tuple[1];
        //try c.blue().bold().printOut("\nseed {d}", .{seed_tuple});
        for (0..seed_tuple[0] + seed_tuple[1]) |realseed| {
            tmp = realseed;
            for (almanac.items) |a_e| {
                tmp = get_almanac_map_value(a_e, tmp);
                //try c.blue().bold().printOut("{s}{d}", .{ a_e.title, tmp });
            }
            lowest = if (lowest == null or tmp < lowest.?) tmp else lowest;
            //try c.blue().bold().printOut(" curlow:{d}", .{lowest.?});
        }
        try c.green().bold().printOut("\nseed tuple {any} complete", .{seed_tuple});
    }
    try c.blue().bold().printOut("\nIt's over! lowest:{d}\n", .{lowest.?});

    // Deinit almanac entries
    for (almanac.items, 0..) |entry, index| {
        _ = entry;
        //try c.yellow().printOut("almanac_entry: {s}\n", .{entry.title});
        //try c.yellow().printOut("keys: {any}\n", .{entry.map.keys()});
        //try c.yellow().printOut("values: {any}\n", .{entry.map.values()});
        //entry.map.deinit();
        //almanac.items[index].map.deinit();

        almanac.items[index].tuples.deinit();
    }
}
