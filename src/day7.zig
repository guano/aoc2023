// --- Day 7: Camel Cards ---
//
// Every hand is exactly one type. From strongest to weakest, they are:
//
//     Five of a kind, where all five cards have the same label: AAAAA
//     Four of a kind, where four cards have the same label and one card has a different label: AA8AA
//     Full house, where three cards have the same label, and the remaining two cards share a different label: 23332
//     Three of a kind, where three cards have the same label, and the remaining two cards are each different from any other card in the hand: TTT98
//     Two pair, where two cards share one label, two other cards share a second label, and the remaining card has a third label: 23432
//     One pair, where two cards share one label, and the other three cards have a different label from the pair and each other: A23A4
//     High card, where all cards' labels are distinct: 23456
//
//To play Camel Cards, you are given a list of hands and their corresponding bid (your puzzle input). For example:
//
//32T3K 765
//T55J5 684
//KK677 28
//KTJJT 220
//QQQJA 483
//
//This example shows five hands; each hand is followed by its bid amount. Each hand wins an amount equal to its bid multiplied by its rank, where the weakest hand gets rank 1, the second-weakest hand gets rank 2, and so on up to the strongest hand. Because there are five hands in this example, the strongest hand will have rank 5 and its bid will be multiplied by 5.
//
//So, the first step is to put the hands in order of strength:
//
//    32T3K is the only one pair and the other hands are all a stronger type, so it gets rank 1.
//    KK677 and KTJJT are both two pair. Their first cards both have the same label, but the second card of KK677 is stronger (K vs T), so KTJJT gets rank 2 and KK677 gets rank 3.
//    T55J5 and QQQJA are both three of a kind. QQQJA has a stronger first card, so it gets rank 5 and T55J5 gets rank 4.
//
//Now, you can determine the total winnings of this set of hands by adding up the result of multiplying each hand's bid with its rank (765 * 1 + 220 * 2 + 28 * 3 + 684 * 4 + 483 * 5). So the total winnings in this example are 6440.
// Find the rank of every hand in your set. What are the total winnings?

const std = @import("std");
const expect = std.testing.expect;
const stdout = std.io.getStdOut().writer();
const Chameleon = @import("chameleon.zig");

const phand = struct { str: []const u8, bet: u32, strength: u8 };

fn get_index_from_char(char: u8) u8 {
    switch (char) {
        'A' => {
            return 0;
        },
        'K' => {
            return 1;
        },
        'Q' => {
            return 2;
        },
        'J' => {
            return 3;
        },
        'T' => {
            return 4;
        },
        '9' => {
            return 5;
        },
        '8' => {
            return 6;
        },
        '7' => {
            return 7;
        },
        '6' => {
            return 8;
        },
        '5' => {
            return 9;
        },
        '4' => {
            return 10;
        },
        '3' => {
            return 11;
        },
        '2' => {
            return 12;
        },
        else => {
            return 0xff;
        }, // TODO: maybe make a real error
    }
}

fn get_strength(hand: []const u8) u8 {
    // TODO: not implemented yet
    if (hand.len != 5) {
        std.debug.print("hand {s} length INCORRECT: {d}", .{ hand, hand.len });
    }

    // index, value
    // 0 1 2 3 4 5 6 7 8 9 10 11 12
    // A K Q J 0 9 8 7 6 5 4  3  2
    var count_values = [_]u8{0} ** 13;

    for (hand) |char| {
        count_values[get_index_from_char(char)] += 1;
    }

    //std.debug.print("hand xxxxx values: . 0  1  2  3  4  5  6  7  8  9  10 11 12\n", .{});
    std.debug.print("                     A  K  Q  J  0  9  8  7  6  5  4  3  2\n", .{});
    std.debug.print("hand {s} values: {any}\n", .{ hand, count_values });

    // if 5 exists in count_values, it's 5 of a kind
    // if 4 exists in count_values, it's 4 of a kind
    // if 3 exists in count_values AND 2 exists, it's full house
    // if 3 exists in count_values, it's 3 of a kind
    // if 2 2's exist in count_values, it's 2 pair
    // if 2 exist in count_values, it's 1 pair
    // Else it's nothing (high card)

    // pub fn containsAtLeast(comptime T: type, haystack: []const T, expected_count: usize, needle: []const T) bool
    if (std.mem.containsAtLeast(u8, &count_values, 1, &[_]u8{5})) {
        std.debug.print("5 of a kind\n", .{});
        return 7;
    } else if (std.mem.containsAtLeast(u8, &count_values, 1, &[_]u8{4})) {
        std.debug.print("4 of a kind\n", .{});
        return 6;
    } else if (std.mem.containsAtLeast(u8, &count_values, 1, &[_]u8{3}) and std.mem.containsAtLeast(u8, &count_values, 1, &[_]u8{2})) {
        std.debug.print("full house\n", .{});
        return 5;
    } else if (std.mem.containsAtLeast(u8, &count_values, 1, &[_]u8{3})) {
        std.debug.print("3 of a kind\n", .{});
        return 4;
    } else if (std.mem.containsAtLeast(u8, &count_values, 2, &[_]u8{2})) {
        std.debug.print("2pair\n", .{});
        return 3;
    } else if (std.mem.containsAtLeast(u8, &count_values, 1, &[_]u8{2})) {
        std.debug.print("pair\n", .{});
        return 2;
    } else if (std.mem.containsAtLeast(u8, &count_values, 1, &[_]u8{5})) {
        std.debug.print("nothing\n", .{});
        return 1;
    } else { // TODO: error here
        std.debug.print("ERROR\n", .{});
        return 0;
    }
}

fn phandGreaterThan(poop: void, lhs: phand, rhs: phand) bool {
    _ = poop;
    // The strengths differ
    if (lhs.strength > rhs.strength) {
        return true;
    } else if (lhs.strength < rhs.strength) {
        return false;
    }

    // The strengths are the same. Time to compare
    for (0..5) |index| {
        const lhs_char_index = get_index_from_char(lhs.str[index]);
        const rhs_char_index = get_index_from_char(rhs.str[index]);
        if (lhs_char_index < rhs_char_index) {
            // A greater index means the hand is weaker
            return true;
        } else if (lhs_char_index > rhs_char_index) {
            // A lesser index means the hand is stronger
            return false;
        }
    }

    // The hands are identical.
    return false;
}
fn phandLessThan(poop: void, lhs: phand, rhs: phand) bool {
    return !phandGreaterThan(poop, lhs, rhs);
}

const phand_list = struct {
    items: *[]phand,
    fn swap(self: *phand_list, a: usize, b: usize) void {
        const ctx = self;
        return std.mem.swap(phand, &ctx.items[a], &ctx.items[b]);
        //return std.mem.swap(phand, ctx.items[a], ctx.items[b]);
    }
    fn lessThan(self: *phand_list, lhs_i: usize, rhs_i: usize) bool {
        //pub fn lessThan(ctx: type, lhs_i: phand, rhs_i: phand) bool {
        const ctx = self;
        const lhs: phand = ctx.items[lhs_i];
        const rhs: phand = ctx.items[rhs_i];
        //_ = ctx;
        //const lhs = lhs_i;
        //const rhs = rhs_i;

        // The strengths differ
        if (lhs.strength < rhs.strength) {
            return true;
        } else if (lhs.strength > rhs.strength) {
            return false;
        }

        // The strengths are the same. Time to compare
        for (0..5) |index| {
            const lhs_char_index = get_index_from_char(lhs.hand[index]);
            const rhs_char_index = get_index_from_char(rhs.hand[index]);
            if (lhs_char_index > rhs_char_index) {
                // A greater index means the hand is weaker
                return true;
            } else if (lhs_char_index < rhs_char_index) {
                // A lesser index means the hand is stronger
                return false;
            }
        }

        // The hands are identical.
        return false;
    }
};

// Strengths: 5 of kind(7), 4 of kind(6), full house(5), 3 of kind(4), 2pair(3), 1pair(2), nothing(1)
// example: 32T3K 765
// str: 32T3K
// bet: 765
// strength: pair (2)
fn get_hand(line: []const u8) !phand {
    //var hand = phand{.str=undefined, .bet=undefined};
    //hand.str = line[0..5];
    const hand = line[0..5];

    // Start at index 6 to crop the hand and the space
    //const bet_str = line[6..];
    const bet = try std.fmt.parseInt(u32, line[6..], 0);

    const strength = get_strength(hand);

    //std.debug.print("hand type: {any}", .{@TypeOf(hand)});
    return phand{ .str = hand, .bet = bet, .strength = strength };
}

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
    var list = std.ArrayList(phand).init(allocator);
    defer list.deinit();

    // Color print
    var c = Chameleon.initRuntime(.{ .allocator = allocator });
    defer c.deinit();
    try c.green().bold().printOut("Hello, world!\n", .{});

    while (try in_stream.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
        const hand = try get_hand(line);
        try list.append(hand);
    }
    for (list.items) |hand| {
        try c.yellow().bold().printOut("hand: {s}, bet: {d}, strength: {d}\n", .{ hand.str, hand.bet, hand.strength });
    }

    // Sort the hands based on strength
    try c.cyan().bold().printOut("\n SORTING NOW\n", .{});
    std.mem.sort(phand, list.items, {}, phandLessThan);

    // Print winnings
    var total_winnings: u64 = 0;
    for (list.items, 1..) |hand, index| {
        const winnings = index * hand.bet;
        total_winnings += winnings;
        try c.green().bold().printOut("hand: {s}, bet: {d}, strength: {d}, index: {d}, winnings: {d}\n", .{ hand.str, hand.bet, hand.strength, index, winnings });
    }
    try c.green().bold().printOut("\ntotal winnings: {d}\n", .{total_winnings});

    //var races = std.ArrayList(race).init(allocator);
    //defer races.deinit();
    //try get_races(list.items[0], list.items[1], &races);

    //const bigrace = try get_races_part2(list.items[0], list.items[1]);
    //try c.yellow().bold().printOut("\nbigrace: {any}\n", .{bigrace});

    //var wins_total: u64 = 1; // start with 1 because we multiply
    //for (races.items) |r| {
    //    const num_wins = get_num_wins(r);
    //    try c.cyan().bold().printOut("\nwins: {d}, race: {any}\n", .{ num_wins, r });
    //    wins_total *= num_wins;
    //}
    //try c.green().bold().printOut("\ntotal wins: {d}\n", .{wins_total});

}
