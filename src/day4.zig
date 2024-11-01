//--- Day 4: Scratchcards ---
//
//The gondola takes you up. Strangely, though, the ground doesn't seem to be coming with you; you're not climbing a mountain. As the circle of Snow Island recedes below you, an entire new landmass suddenly appears above you! The gondola carries you to the surface of the new island and lurches into the station.
//
//As you exit the gondola, the first thing you notice is that the air here is much warmer than it was on Snow Island. It's also quite humid. Is this where the water source is?
//
//The next thing you notice is an Elf sitting on the floor across the station in what seems to be a pile of colorful square cards.
//
//"Oh! Hello!" The Elf excitedly runs over to you. "How may I be of service?" You ask about water sources.
//
//"I'm not sure; I just operate the gondola lift. That does sound like something we'd have, though - this is Island Island, after all! I bet the gardener would know. He's on a different island, though - er, the small kind surrounded by water, not the floating kind. We really need to come up with a better naming scheme. Tell you what: if you can help me with something quick, I'll let you borrow my boat and you can go visit the gardener. I got all these scratchcards as a gift, but I can't figure out what I've won."
//
//The Elf leads you over to the pile of colorful cards. There, you discover dozens of scratchcards, all with their opaque covering already scratched off. Picking one up, it looks like each card has two lists of numbers separated by a vertical bar (|): a list of winning numbers and then a list of numbers you have. You organize the information into a table (your puzzle input).
//
//As far as the Elf has been able to figure out, you have to figure out which of the numbers you have appear in the list of winning numbers. The first match makes the card worth one point and each match after the first doubles the point value of that card.
//
//For example:
//
//Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
//Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
//Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
//Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
//Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
//Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
//
//In the above example, card 1 has five winning numbers (41, 48, 83, 86, and 17) and eight numbers you have (83, 86, 6, 31, 17, 9, 48, and 53). Of the numbers you have, four of them (48, 83, 17, and 86) are winning numbers! That means card 1 is worth 8 points (1 for the first match, then doubled three times for each of the three matches after the first).
//
//    Card 2 has two winning numbers (32 and 61), so it is worth 2 points.
//    Card 3 has two winning numbers (1 and 21), so it is worth 2 points.
//    Card 4 has one winning number (84), so it is worth 1 point.
//    Card 5 has no winning numbers, so it is worth no points.
//    Card 6 has no winning numbers, so it is worth no points.
//
//So, in this example, the Elf's pile of scratchcards is worth 13 points.
//
//Take a seat in the large pile of colorful cards. How many points are they worth in total?

const std = @import("std");
const expect = std.testing.expect;
const stdout = std.io.getStdOut().writer();
const Chameleon = @import("chameleon.zig");

const card_score = struct { number: u32, score: u32, num_match: u32 };

pub fn score_card(card: []const u8) !card_score {
    // Print in color
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var c = Chameleon.initRuntime(.{ .allocator = allocator });

    try c.yellow().bold().printOut("{s}\n", .{card});

    // Actual logic
    // Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    var split = std.mem.splitAny(u8, card, ":");
    const card_num_str = std.mem.trimLeft(u8, split.first(), "Card ");
    const card_num = try std.fmt.parseInt(u8, card_num_str, 0);

    try c.green().bold().printOut("Card {d}\n", .{card_num});

    var left_vs_right = std.mem.splitAny(u8, split.rest(), "|");

    // left
    var left = std.mem.splitAny(u8, left_vs_right.first(), " ");

    var leftset = std.BufSet.init(allocator);

    while (left.next()) |num| {
        //std.debug.print("num:{s}", .{num});
        if (num.len == 0) {
            continue;
        } else {
            try leftset.insert(num);
        }
    }

    // print leftset
    std.debug.print("left set:", .{});
    var it = leftset.iterator();
    while (it.next()) |leftsetitem| {
        std.debug.print(" {s}", .{leftsetitem.*});
    }

    // Right
    // Just copy-paste from left
    // right
    var right = std.mem.splitAny(u8, left_vs_right.rest(), " ");

    var rightset = std.BufSet.init(allocator);
    while (right.next()) |num| {
        //std.debug.print("num:{s}", .{num});
        if (num.len == 0) {
            continue;
        } else {
            try rightset.insert(num);
        }
    }

    // print rightset
    std.debug.print("\nright set:", .{});
    var itr = rightset.iterator();
    while (itr.next()) |rightsetitem| {
        std.debug.print(" {s}", .{rightsetitem.*});
    }
    std.debug.print("\n", .{});

    // Count winnings
    var winnings: u32 = 0;
    var num_matches: u32 = 0;
    var it2 = leftset.iterator();
    while (it2.next()) |leftsetitem| {
        if (rightset.contains(leftsetitem.*)) {
            winnings = if (winnings == 0) 1 else winnings * 2;
            num_matches += 1;
        }
    }
    std.debug.print("winnings: {d}\n", .{winnings});
    std.debug.print("matches: {d}\n", .{num_matches});

    //const card_score = struct{
    //    number: u32,
    //    score: u32};
    return card_score{ .number = card_num, .score = winnings, .num_match = num_matches };
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

    // I know there are 192 scratchcards. Maybe soon I will just initialize to 0 and add 1 when we actually encounter it
    // The for loop adds 1 to scratchcard's own copy, so we can now initialize to 0
    var scratchcard_copies: [192]u64 = [_]u64{0} ** 192;

    var total_points: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
        try list.append(line);

        const card = try score_card(line);
        total_points += card.score;
        try c.blue().bold().printOut("{any}\n", .{card_score});
        scratchcard_copies[card.number - 1] += 1; // Count the current card once
        const curcard_copies = scratchcard_copies[card.number - 1];
        // card's own number is 1 more than index into scratchcard_copies
        for (card.number..card.number + card.num_match) |index| {
            scratchcard_copies[index] += curcard_copies;
            try c.cyan().bold().printOut(" +{d} to {d} ", .{ curcard_copies, index });
        }
    }

    try c.red().bold().printOut("\n total scratchcard points: {d}\n", .{total_points});
    try c.red().bold().printOut("\n scratchcard array: {any}\n", .{scratchcard_copies});

    var total_scratchcard_copies: u64 = 0;
    for (scratchcard_copies) |numcopies| {
        total_scratchcard_copies += numcopies;
    }
    try c.red().bold().printOut("\n total scratchcard copies: {d}\n", .{total_scratchcard_copies});
}
