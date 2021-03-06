const std = @import("std");
const ssl = @import("ssl");

pub const NetStream = union(enum) {
    File: *const std.fs.File,
    Ssl: *ssl.SslConn,

    pub const Reader = std.io.Reader(*@This(), FnErrorSet(@TypeOf(read)), read);
    pub const Writer = std.io.Writer(*@This(), FnErrorSet(@TypeOf(write)), write);

    pub fn initFile(file: *const std.fs.File) NetStream {
        return .{ .File = file };
    }
    pub fn initSsl(conn: *ssl.SslConn) NetStream {
        return .{ .Ssl = conn };
    }

    pub fn reader(self: *@This()) Reader {
        return .{ .context = self };
    }

    pub fn writer(self: *@This()) Writer {
        return .{ .context = self };
    }

    pub fn read(self: *@This(), dest: []u8) !usize {
        switch (self.*) {
            .File => |s| return s.read(dest),
            .Ssl  => |s| return s.read(dest),
        }
    }

    pub fn write(self: *@This(), bytes: []const u8) !usize {
        switch (self.*) {
            .File => |s| return try s.write(bytes),
            .Ssl  => |s| return try s.write(bytes),
        }
    }
};

/// TODO: move this
/// Returns the error set for the given function type
fn FnErrorSet(comptime FnType: type) type {
    const Return = @typeInfo(FnType).Fn.return_type.?;
    return @typeInfo(Return).ErrorUnion.error_set;
}
