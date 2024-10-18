// --- Day 2: Cube Conundrum ---
//
// You're launched high into the atmosphere! The apex of your trajectory just barely reaches the surface of a large island floating in the sky. You gently land in a fluffy pile of leaves. It's quite cold, but you don't see much snow. An Elf runs over to greet you.
//
// The Elf explains that you've arrived at Snow Island and apologizes for the lack of snow. He'll be happy to explain the situation, but it's a bit of a walk, so you have some time. They don't get many visitors up here; would you like to play a game in the meantime?
//
// As you walk, the Elf shows you a small bag and some cubes which are either red, green, or blue. Each time you play this game, he will hide a secret number of cubes of each color in the bag, and your goal is to figure out information about the number of cubes.
//
// To get information, once a bag has been loaded with cubes, the Elf will reach into the bag, grab a handful of random cubes, show them to you, and then put them back in the bag. He'll do this a few times per game.
//
// You play several games and record the information from each game (your puzzle input). Each game is listed with its ID number (like the 11 in Game 11: ...) followed by a semicolon-separated list of subsets of cubes that were revealed from the bag (like 3 red, 5 green, 4 blue).
//
// For example, the record of a few games might look like this:
//
// Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
// Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
// Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
// Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
// Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
//
// In game 1, three sets of cubes are revealed from the bag (and then put back again). The first set is 3 blue cubes and 4 red cubes; the second set is 1 red cube, 2 green cubes, and 6 blue cubes; the third set is only 2 green cubes.
//
// The Elf would first like to know which games would have been possible if the bag contained only 12 red cubes, 13 green cubes, and 14 blue cubes?
//
// In the example above, games 1, 2, and 5 would have been possible if the bag had been loaded with that configuration. However, game 3 would have been impossible because at one point the Elf showed you 20 red cubes at once; similarly, game 4 would also have been impossible because the Elf showed you 15 blue cubes at once. If you add up the IDs of the games that would have been possible, you get 8.
//
// Determine which games would have been possible if the bag had been loaded with only 12 red cubes, 13 green cubes, and 14 blue cubes. What is the sum of the IDs of those games?

// PART 2: As you continue your walk, the Elf poses a second question: in each game you played, what is the fewest number of cubes of each color that could have been in the bag to make the game possible?

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

const Color = enum { red, green, blue };
const roundResults = struct {
    red: u32 = 0,
    green: u32 = 0,
    blue: u32 = 0,
    fn set(self: *roundResults, color: Color, value: u32) void {
        switch (color) {
            Color.red => {
                self.red = value;
            },
            Color.green => {
                self.green = value;
            },
            Color.blue => {
                self.blue = value;
            },
        }
    }
};

fn color_to_enum(word: []const u8) ?Color {
    if (std.mem.eql(u8, word, "red")) {
        return Color.red;
    }
    if (std.mem.eql(u8, word, "green")) {
        return Color.green;
    }
    if (std.mem.eql(u8, word, "blue")) {
        return Color.blue;
    }
    return null;
}

const parse_game_return = struct { game_num: u32 = 0, game_power: u32 = 0 };

//fn parse_game(line: []const u8, limit: roundResults) !u32 {
fn parse_game(line: []const u8, limit: roundResults) !parse_game_return {
    // Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
    var split = std.mem.splitAny(u8, line, ":");

    // The game number is the first thing after the string "Game "
    const game = std.mem.trimLeft(u8, split.first(), "Game ");
    const game_num = try std.fmt.parseInt(u8, game, 0);

    var minimum_required: roundResults = .{};

    var game_success = true;

    // The rounds are split by ;
    var rounds = std.mem.splitAny(u8, split.rest(), ";");
    while (rounds.next()) |round| {
        std.debug.print("round:{s}\n", .{round});
        var result: roundResults = .{};
        var color_str_split = std.mem.splitAny(u8, round, ",");
        while (color_str_split.next()) |color_str| {
            std.debug.print("color_str:{s}", .{color_str});
            var cur_color_str = std.mem.splitAny(u8, color_str, " ");
            _ = cur_color_str.first();

            const cur_color_num = cur_color_str.next().?;
            const cur_color = cur_color_str.rest();
            const cur_color_fixed = color_to_enum(cur_color);
            const cur_color_num_fixed = try std.fmt.parseInt(u32, cur_color_num, 0);

            //std.debug.print("cur_color:{s}{any}", .{ cur_color, cur_color_fixed });
            //std.debug.print("cur_color_num:{s}{any}\n", .{ cur_color_num, cur_color_num_fixed });
            std.debug.print("  num:{d}", .{cur_color_num_fixed});
            std.debug.print("  color:{any}\n", .{cur_color_fixed});
            //result.set(cur_color.?, cur_color_num);
            result.set(cur_color_fixed.?, cur_color_num_fixed);
        }
        std.debug.print("result:{}\n", .{result});

        // If the current round doesn't meet the limit, this game doesn't count
        if ((limit.green < result.green) or (limit.red < result.red) or (limit.blue < result.blue)) {
            game_success = false;
        }

        // Update the minimum requirement for this game
        minimum_required.red = if (result.red > minimum_required.red) result.red else minimum_required.red;
        minimum_required.green = if (result.green > minimum_required.green) result.green else minimum_required.green;
        minimum_required.blue = if (result.blue > minimum_required.blue) result.blue else minimum_required.blue;
    }
    const power = minimum_required.red * minimum_required.green * minimum_required.blue;
    // All rounds in this game meet the limit; return the game number to be summed
    if (game_success) {
        return .{ .game_num = game_num, .game_power = power };
    } else {
        return .{ .game_num = 0, .game_power = power };
    }
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
        std.debug.print("You idiot, you need to give the filename for day 2 as input!\n", .{});
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
    var total_power: u32 = 0;
    const limit = roundResults{ .red = 12, .green = 13, .blue = 14 };
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        ////////////////////////////////////
        // Adding the total

        const parsed_game = try parse_game(line, limit);
        total += parsed_game.game_num;
        total_power += parsed_game.game_power;
    }

    try stdout.print("total: {d}\n", .{total});
    try stdout.print("total_power: {d}\n", .{total_power});
}
