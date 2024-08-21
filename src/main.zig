// raylib-zig (c) Nikolas Wipper 2023
const std = @import("std");
const r1 = @import("raylib");
const print = @import("std").debug.print;
const GameState = struct { allocator: std.mem.Allocator, time: f32 = 0, radius: f32 = 0, movement: KeyPressed, snake: *SnakeLocation, length: i32 };
const KeyPressed = struct {
    left: bool,
    right: bool,
    up: bool,
    down: bool,
};
const SnakeLocation = struct {
    x: i32,
    y: i32,
    next: ?*SnakeLocation,
    pub fn create(allocator: *std.mem.Allocator, x: i32, y: i32) !*SnakeLocation {
        const location = allocator.create(SnakeLocation) catch @panic("Out of memory.");
        location.* = SnakeLocation{ .x = x, .y = y, .next = null };
        return location;
    }

    pub fn append(self: *SnakeLocation, allocator: *std.mem.Allocator, x: i32, y: i32) !void {
        var current = self;
        while (current.next) |n| {
            current = n;
        }
        const location = allocator.create(SnakeLocation) catch @panic("Out of memory.");
        location.* = SnakeLocation{ .x = x, .y = y, .next = null };
        current.next = location;
    }

    pub fn deint(self: *SnakeLocation) void {
        if (self.next) |n| {
            n.deint();
        }
        const allocator = std.heap.page_allocator;
        allocator.destroy(self);
    }

    pub fn getTail(head: *SnakeLocation) *SnakeLocation {
        var current = head;
        var prev = current;
        print("................................\n", .{});
        while (current.next) |n| {
            // print("a", .{});
            current = n;
            prev = n;
            print("{?}\n", .{prev});
            std.time.sleep(1000000000);
        }
        prev.next = null;
        print("{?}\n", .{prev});
        print("{?}\n", .{current});
        return current;
    }
};
const SnakeLocationVector = []@Vector(2, i32);
const screen_w = 800;
const screen_h = 450;
pub fn main() anyerror!void {
    const game_state = gameInit();
    // Initialization
    //--------------------------------------------------------------------------------------

    r1.initWindow(screen_w, screen_h, "Snake");
    defer r1.closeWindow(); // Close window and OpenGL context

    r1.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------
    // Main game loop
    while (!r1.windowShouldClose()) { // Detect window close button or ESC key
        // std.time.sleep(0.5 * 1000000000);
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        r1.beginDrawing();
        defer r1.endDrawing();

        gameTick(game_state);
        gameDraw(game_state);
    }
}

fn gameInit() *GameState {
    var allocator = std.heap.page_allocator;
    const game_state = allocator.create(GameState) catch @panic("Out of memory.");
    const key_pressed = KeyPressed{ .left = false, .right = false, .up = false, .down = false };

    const location = try SnakeLocation.create(&allocator, 150, 10);
    for (1..10) |i| {
        const a: i32 = @intCast(i);
        try location.append(&allocator, @intCast(location.x - (11 * a)), 10);
    }

    game_state.* = GameState{ .allocator = allocator, .radius = 10.0, .movement = key_pressed, .snake = location, .length = 10 };
    return game_state;
}

fn gameTick(game_state: *GameState) void {
    game_state.time += r1.getFrameTime();
}

fn gameDraw(game_state: *GameState) void {
    r1.clearBackground(r1.Color.white);
    var current = game_state.snake;
    var prev: *SnakeLocation = game_state.snake;
    while (current.next != null) {
        r1.drawRectangle(current.x, current.y, 10, 10, r1.Color.blue);
        if (current.next == null) {
            break;
        } else {
            prev = current;
            current = current.next.?;
        }
    }
    keyPressed(game_state);
    const head = game_state.snake;
    if (game_state.movement.right) {
        current.x = head.x + 11;
        current.y = head.y;
    }
    if (game_state.movement.left) {
        current.x = head.x - 11;
        current.y = head.y;
    }
    if (game_state.movement.up) {
        current.y = head.y - 11;
        current.x = head.x;
    }

    if (game_state.movement.down) {
        current.y = head.y + 11;
        current.x = head.x;
    }
    current.next = head;
    prev.next = null;
    game_state.snake = current;
}

fn keyPressed(game_state: *GameState) void {
    game_state.movement.down = false;
    game_state.movement.up = false;
    game_state.movement.left = false;
    game_state.movement.right = false;
    if (r1.isKeyDown(r1.KeyboardKey.key_down)) {
        game_state.movement.down = true;
    } else if (r1.isKeyDown(r1.KeyboardKey.key_left)) {
        game_state.movement.left = true;
    } else if (r1.isKeyDown(r1.KeyboardKey.key_up)) {
        game_state.movement.up = true;
    } else if (r1.isKeyDown(r1.KeyboardKey.key_right)) {
        game_state.movement.right = true;
    }
}
