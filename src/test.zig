const std = @import("std");
test "aaaa" {
const SnakeLocation = struct {
    x: i32,
    y: i32,
};
const allocator = std.heap.raw_c_allocator;
var vectors = std.ArrayList(SnakeLocation).init(allocator);
    defer vectors.deinit();
    

    for (1..10) |i| {
        if(vectors.items.len>0){
        const prev_location = vectors.items[i - 1];
        try vectors.append(SnakeLocation{ .x = prev_location.x + 5, .y = prev_location.y });
    }else{
        try vectors.append(SnakeLocation{ .x = 10, .y = 10 });
    }
    } 
    
     for (vectors.items) |location| {
        std.debug.print("SnakeLocation: x={}, y={}\n", .{location.x, location.y});
    }
    }