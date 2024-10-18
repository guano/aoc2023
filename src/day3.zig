// --- Day 3: Gear Ratios ---
//
// You and the Elf eventually reach a gondola lift station; he says the gondola lift will take you up to the water source, but this is as far as he can bring you. You go inside.
//
// It doesn't take long to find the gondolas, but there seems to be a problem: they're not moving.
//
// "Aaah!"
//
// You turn around to see a slightly-greasy Elf with a wrench and a look of surprise. "Sorry, I wasn't expecting anyone! The gondola lift isn't working right now; it'll still be a while before I can fix it." You offer to help.
//
// The engineer explains that an engine part seems to be missing from the engine, but nobody can figure out which one. If you can add up all the part numbers in the engine schematic, it should be easy to work out which part is missing.
//
// The engine schematic (your puzzle input) consists of a visual representation of the engine. There are lots of numbers and symbols you don't really understand, but apparently any number adjacent to a symbol, even diagonally, is a "part number" and should be included in your sum. (Periods (.) do not count as a symbol.)
//
// Here is an example engine schematic:
//467..114..
// ...*......
// ..35..633.
// ......#...
// 617*......
// .....+.58.
// ..592.....
// ......755.
// ...$.*....
// .664.598..
//
// In this schematic, two numbers are not part numbers because they are not adjacent to a symbol: 114 (top right) and 58 (middle right). Every other number is adjacent to a symbol and so is a part number; their sum is 4361.
//
// Of course, the actual engine schematic is much larger. What is the sum of all of the part numbers in the engine schematic?

const std = @import("std");
const expect = std.testing.expect;

fn find_number(schematic: [][]const u8) !u32 {
    for (schematic, 0..) |line, line_index| {
        std.debug.print("line {d}: {s}\n", .{ line_index, line });
    }
    return 0;
}

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

    /////////////////////////////////////////////////////////////////////////////
    //// Part 1
    //const infile = args[1];

    //////////////////////////////////////
    //// Opening the file
    //std.debug.print("infile: {s}\n", .{infile});
    //const file = try std.fs.cwd().openFile(infile, .{ .mode = .read_only });
    //defer file.close();

    //var br = std.io.bufferedReader(file.reader());
    //var in_stream = br.reader();

    //////////////////////////////////////
    //// Reading the file (part 1)
    //var buf: [1024]u8 = undefined;
    //var total: u32 = 0;
    //var total_power: u32 = 0;
    //const limit = roundResults{ .red = 12, .green = 13, .blue = 14 };
    //while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
    //    ////////////////////////////////////
    //    // Adding the total

    //    const parsed_game = try parse_game(line, limit);
    //    total += parsed_game.game_num;
    //    total_power += parsed_game.game_power;
    //}
    //try stdout.print("total: {d}\n", .{total});
    //try stdout.print("total_power: {d}\n", .{total_power});

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
    //var buf: [1024]u8 = undefined;
    var total: u32 = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var list = std.ArrayList([]u8).init(allocator);
    defer list.deinit();

    //readUntilDelimiterOrEofAlloc( allocator, '\n', 1024)

    //while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
    while (try in_stream.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
        ////////////////////////////////////
        // Adding the total

        //const parsed_game = try parse_game(line, limit);
        //total += parsed_game.game_num;
        try list.append(line);
        //std.debug.print("giant list:\n{s}\n", .{list.items});
        total += 1;
    }
    for (list.items) |line2| {
        std.debug.print("{s}\n", .{line2});
    }
    //std.debug.print("giant list:\n{s}\n", .{list.items});

    //var rounds = std.mem.splitAny(u8, split.rest(), ";");

    try stdout.print("total: {d}\n", .{total});
}
