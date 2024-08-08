// raylib-zig (c) Nikolas Wipper 2023
const std = @import("std");
const r1 = @import("raylib");
const print = @import("std").debug.print;
const GameState = struct { allocator: std.mem.Allocator, time: f32 = 0, radius: f32 = 0, movement: KeyPressed, snake: SnakeLocation, length: i32 };
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
    pub fn create(allocator: *std.mem.Allocator,x:i32,y:i32) !*SnakeLocation{
        const location =  allocator.create(SnakeLocation) catch @panic("Out of memory.");
        location.* = SnakeLocation{.x=x,.y=y,.next=null};
        return location;
    }

    pub fn append(self:*SnakeLocation,allocator:*std.mem.Allocator,x:i32,y:i32) !void{
        var current = self;
        while(current.next) |n| {
            current=n;
        }
         const location =  allocator.create(SnakeLocation) catch @panic("Out of memory.");
        location.* = SnakeLocation{.x=x,.y=y,.next=null};
        current.next=location;
    }

    pub fn deint(self:*SnakeLocation) void {
        if(self.next) |n| {
            n.deint();
        }
        const allocator = std.heap.page_allocator;
        allocator.destroy(self);
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
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        r1.beginDrawing();
        defer r1.endDrawing();
        keyPressed(game_state);
        gameTick(game_state);
        gameDraw(game_state);
        // c.clearBackground(c.Color.white);

        // r1.drawText("Congrats! You created your first window!", 190, 200, 20, r1.Color.light_gray);
        //----------------------------------------------------------------------------------
    }
}

fn gameInit() *GameState {
    var allocator = std.heap.page_allocator;
    const game_state = allocator.create(GameState) catch @panic("Out of memory.");
    const key_pressed = KeyPressed{ .left = false, .right = false, .up = false, .down = false };
    // defer vectors.deinit();
    
   
    
    
    const location = try SnakeLocation.create(&allocator, 10, 10);
    // print("{}",location);
    location.append(&location,&allocator, 10, 10);
    
    game_state.* = GameState{ .allocator = allocator, .radius = 10.0, .movement = key_pressed, .snake = location.*, .length = 10};
    return game_state;
}

fn gameTick(game_state: *GameState) void {
    game_state.time += r1.getFrameTime();
}

fn gameDraw(game_state: *GameState) void {
    r1.clearBackground(r1.Color.white);

    // Create zero terminated string with the time and radius.
    // var buf: [256]u8 = undefined;
    // const slice = std.fmt.bufPrintZ(
    //     &buf,
    //     "time: {d:.02}, radius: {d:.02}",
    //     .{ game_state.time, game_state.radius },
    // ) catch "error";
    // // print("{s}", .{slice});
    // r1.drawText(slice, 10, 10, 20, r1.Color.black);

    // Draw a circle moving across the screen with the config radius.
    // if (game_state.movement.left and game_state.snake.x > 1) {
    //     game_state.snake.x -= 1;
    // }
    // if (game_state.movement.right and game_state.snake.x < screen_w) {
    //     game_state.snake.x += 1;
    // }
    // if (game_state.movement.up and game_state.snake.y > 0) {
    //     game_state.snake.y -= 1;
    // }
    // if (game_state.movement.down and game_state.snake.y < screen_h) {
    //     game_state.snake.y += 1;
    // }
    var current = game_state.snake;
    print("{}", .{@TypeOf(current)});
 while(@TypeOf(current)==SnakeLocation){
        
        r1.drawRectangle(current.x, current.y, 10, 10, r1.Color.blue);
        if(current.next==null){
            break;
        }else{
        current=current.next.?.*;
    }
    }
    // const circle_x: f32 = @mod(game_state.time * 50.0, screen_w);
    
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
