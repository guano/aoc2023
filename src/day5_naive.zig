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

const card_score = struct { number: u32, score: u32, num_match: u32 };

const almanac_entry = struct { title: []u8, map: std.array_hash_map.AutoArrayHashMap(u32, u32) };

// Parses a string line looking like "seeds: #### ### ## ## ##" and inserts the numbers into the arraylist
fn get_seeds(line: []u8, seedlist: *std.ArrayList(u32)) !void {
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
            const num = try std.fmt.parseInt(u32, num_str, 0);
            try seedlist.append(num);
        }
    }
}

fn parse_almanac_entry(allocator: std.mem.Allocator, lines: [][]u8) !almanac_entry {
    const name = lines[0];
    var map = std.array_hash_map.AutoArrayHashMap(u32, u32).init(allocator);

    for (lines, 0..) |line, index| {
        std.debug.print("line: {s}\n", .{line});
        if (index == 0) {
            continue;
        }
        var split = std.mem.splitAny(u8, line, " ");
        const dest_start_str = split.next();
        const src_start_str = split.next();
        const range_len_str = split.next();

        const dest_start = try std.fmt.parseInt(u32, dest_start_str.?, 0);
        const src_start = try std.fmt.parseInt(u32, src_start_str.?, 0);
        var range_len = try std.fmt.parseInt(u32, range_len_str.?, 0);

        while (range_len > 0) : (range_len -= 1) {
            try map.put(src_start + range_len - 1, dest_start + range_len - 1);
        }
    }
    return almanac_entry{ .title = name, .map = map };
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
    defer seeds.deinit();

    // I know there are 192 scratchcards. Maybe soon I will just initialize to 0 and add 1 when we actually encounter it
    // The for loop adds 1 to scratchcard's own copy, so we can now initialize to 0
    //var scratchcard_copies: [192]u64 = [_]u64{0} ** 192;
    //var total_points: u32 = 0;
    var line_index: u32 = 0;
    var index_end_of_prev: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| : (line_index += 1) {
        try file_lines.append(line);

        try c.green().printOut("line {d} len {d}: {s}\n", .{ line_index, line.len, line });

        // First line of input is the seeds list
        if (line_index == 0) {
            try get_seeds(line, &seeds);
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
    var tmp: u32 = 0;
    var lowest: ?u32 = null;
    for (seeds.items) |seed| {
        tmp = seed;
        try c.blue().bold().printOut("\nseed {d}", .{seed});
        for (almanac.items) |a_e| {
            //const poop = a_e.map.get(tmp);
            tmp = a_e.map.get(tmp) orelse tmp;
            //tmp = poop;
            try c.blue().bold().printOut("{s}{d}", .{ a_e.title, tmp });
        }
        lowest = if (lowest == null or tmp < lowest.?) tmp else lowest;
        try c.blue().bold().printOut(" curlow:{d}", .{lowest.?});
    }

    // Deinit almanac entries
    for (almanac.items, 0..) |entry, index| {
        _ = entry;
        //try c.yellow().printOut("almanac_entry: {s}\n", .{entry.title});
        //try c.yellow().printOut("keys: {any}\n", .{entry.map.keys()});
        //try c.yellow().printOut("values: {any}\n", .{entry.map.values()});
        //entry.map.deinit();
        almanac.items[index].map.deinit();
    }
    try c.blue().bold().printOut("\nIt's over! lowest:{d}\n", .{lowest.?});
}
