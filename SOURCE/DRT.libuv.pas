unit DRT.libuv;

interface

uses
  System.Types,
{$IFDEF MSWINDOWS}
  Winapi.Windows, Winapi.Winsock2, Winapi.WinSock,Winapi.IpExport, Winapi.ShellAPI,
{$ELSE}
  POSIX.Base, POSIX.StdDef, POSIX.SysTypes, POSIX.Pthread, POSIX.Stdlib,
  POSIX.SysSocket, POSIX.NetinetIn, POSIX.NetinetIp6,
{$ENDIF}
  DRT.LIBNAME;

type
  _sockaddr_storage = sockaddr_storage;
  uv_process_flags = (UV__PROCESS_SETUID = 1, UV__PROCESS_SETGID = 2,
    UV__PROCESS_WINDOWS_VERBATIM_ARGUMENTS = 4, UV__PROCESS_DETACHED = 8,
    UV__PROCESS_WINDOWS_HIDE = 16, UV__PROCESS_WINDOWS_HIDE_CONSOLE = 32,
    UV__PROCESS_WINDOWS_HIDE_GUI = 64);

  uv_errno_t = (UV__E2BIG = -4093, UV__EACCES = -4092, UV__EADDRINUSE = -4091,
    UV__EADDRNOTAVAIL = -4090, UV__EAFNOSUPPORT = -4089, UV__EAGAIN = -4088,
    UV__EAI_ADDRFAMILY = -3000, UV__EAI_AGAIN = -3001, UV__EAI_BADFLAGS = -3002,
    UV__EAI_BADHINTS = -3013, UV__EAI_CANCELED = -3003, UV__EAI_FAIL = -3004,
    UV__EAI_FAMILY = -3005, UV__EAI_MEMORY = -3006, UV__EAI_NODATA = -3007,
    UV__EAI_NONAME = -3008, UV__EAI_OVERFLOW = -3009, UV__EAI_PROTOCOL = -3014,
    UV__EAI_SERVICE = -3010, UV__EAI_SOCKTYPE = -3011, UV__EALREADY = -4084,
    UV__EBADF = -4083, UV__EBUSY = -4082, UV__ECANCELED = -4081,
    UV__ECHARSET = -4080, UV__ECONNABORTED = -4079, UV__ECONNREFUSED = -4078,
    UV__ECONNRESET = -4077, UV__EDESTADDRREQ = -4076, UV__EEXIST = -4075,
    UV__EFAULT = -4074, UV__EFBIG = -4036, UV__EHOSTUNREACH = -4073,
    UV__EINTR = -4072, UV__EINVAL = -4071, UV__EIO = -4070, UV__EISCONN = -4069,
    UV__EISDIR = -4068, UV__ELOOP = -4067, UV__EMFILE = -4066,
    UV__EMSGSIZE = -4065, UV__ENAMETOOLONG = -4064, UV__ENETDOWN = -4063,
    UV__ENETUNREACH = -4062, UV__ENFILE = -4061, UV__ENOBUFS = -4060,
    UV__ENODEV = -4059, UV__ENOENT = -4058, UV__ENOMEM = -4057,
    UV__ENONET = -4056, UV__ENOPROTOOPT = -4035, UV__ENOSPC = -4055,
    UV__ENOSYS = -4054, UV__ENOTCONN = -4053, UV__ENOTDIR = -4052,
    UV__ENOTEMPTY = -4051, UV__ENOTSOCK = -4050, UV__ENOTSUP = -4049,
    UV__EOVERFLOW = -4026, UV__EPERM = -4048, UV__EPIPE = -4047,
    UV__EPROTO = -4046, UV__EPROTONOSUPPORT = -4045, UV__EPROTOTYPE = -4044,
    UV__ERANGE = -4034, UV__EROFS = -4043, UV__ESHUTDOWN = -4042,
    UV__ESPIPE = -4041, UV__ESRCH = -4040, UV__ETIMEDOUT = -4039,
    UV__ETXTBSY = -4038, UV__EXDEV = -4037, UV__UNKNOWN = -4094,
    UV__EOF = -4095, UV__ENXIO = -4033, UV__EMLINK = -4032,
    UV__EHOSTDOWN = -4031, UV__EREMOTEIO = -4030, UV__ENOTTY = -4029,
    UV__EFTYPE = -4028, UV__EILSEQ = -4027, UV__ESOCKTNOSUPPORT = -4025,
    UV__ERRNO_MAX = -4096);
  Puv_errno_t = ^uv_errno_t;

  uv_handle_type = (UV__UNKNOWN_HANDLE = 0, UV__ASYNC = 1, UV__CHECK = 2,
    UV__FS_EVENT = 3, UV__FS_POLL = 4, UV__HANDLE = 5, UV__IDLE = 6,
    UV__NAMED_PIPE = 7, UV__POLL = 8, UV__PREPARE = 9, UV__PROCESS = 10,
    UV__STREAM = 11, UV__TCP = 12, UV__TIMER = 13, UV__TTY = 14, UV__UDP = 15,
    UV__SIGNAL = 16, UV__FILE = 17, UV__HANDLE_TYPE_MAX = 18);
  Puv_handle_type = ^uv_handle_type;

  uv_req_type = (UV__UNKNOWN_REQ = 0, UV__REQ = 1, UV__CONNECT = 2,
    UV__WRITE = 3, UV__SHUT_DOWN = 4, UV__UDP_SEND = 5, UV__FS = 6,
    UV__WORK = 7, UV__GETADDRINFO = 8, UV__GETNAMEINFO = 9, UV__RANDOM = 10,
{$IFDEF MSWINDOWS}
    UV__ACCEPT = 11, UV__FS_EVENT_REQ = 12, UV__POLL_REQ = 13,
    UV__PROCESS_EXIT = 14, UV__READ = 15, UV__UDP_RECV = 16, UV__WAKEUP = 17,
    UV__SIGNAL_REQ = 18, UV__REQ_TYPE_MAX = 19
{$ELSE}
    UV__REQ_TYPE_MAX = 11
{$ENDIF}
    );

  uv_loop_option = (UV__LOOP_BLOCK_SIGNAL = 0, UV__METRICS_IDLE_TIME = 1);

  uv_run_mode = (UV__RUN_DEFAULT = 0, UV__RUN_ONCE = 1, UV__RUN_NOWAIT = 2);

  uv_malloc_func = function(size: NativeUInt): Pointer; cdecl;
  uv_realloc_func = function(ptr: Pointer; size: NativeUInt): Pointer; cdecl;
  uv_calloc_func = function(count: NativeUInt; size: NativeUInt)
    : Pointer; cdecl;
  uv_free_func = procedure(ptr: Pointer); cdecl;

  Puv_handle_t = ^uv_handle_t;
  Puv_loop_t = ^uv_loop_t;
  Puv_req_t = ^uv_req_t;
  Puv_prepare_t = ^uv_prepare_t;
  Puv_check_t = ^uv_check_t;
  Puv_idle_t = ^uv_idle_t;
  Puv_signal_t = ^uv_signal_t;
  Puv_shutdown_t = ^uv_shutdown_t;
  Puv_stream_t = ^uv_stream_t;
  Puv_connect_t = ^uv_connect_t;
  Puv_buf_t = ^uv_buf_t;

  uv_pid_t = Integer;
  uv_file = Integer;
{$IFDEF MSWINDOWS}
  uv_uid_t = Byte;
  uv_gid_t = Byte;
{$ELSE}
  uv_gid_t = Cardinal;
  uv_uid_t = Cardinal;
{$ENDIF}

  uv_buf_t = record
{$IFDEF MSWINDOWS}
    len: ULONG;
    Base: Pointer;
{$ELSE}
    Base: Pointer;
    len: NativeUInt;
{$ENDIF}
  end;

  uv_handle_t = record
  type
    uv_close_cb = procedure(var handle: uv_handle_t); cdecl;
    uv_walk_cb = procedure(var handle: uv_handle_t; arg: Pointer); cdecl;

  var
    data: Pointer;
    loop: Puv_loop_t;
    &Type: uv_handle_type;
    close_cb: uv_close_cb;
    handle_queue: array [0 .. 1] of Pointer;

    u: record
      case Integer of
        0:
          (fd: Integer);
        1:
          (reserved: array [0 .. 3] of Pointer);
    end;

{$IFDEF MSWINDOWS}endgame_next{$ELSE}next_closing{$ENDIF}: Puv_handle_t;
    flags: Cardinal;
  end;

  uv_req_t = record
    data: Pointer;
    &Type: uv_req_type;
    reserved: array [0 .. 5] of Pointer;
{$IFDEF MSWINDOWS}

    u: record
      case Integer of
        0:
          (io: record OVERLAPPED: OVERLAPPED;
            queued_bytes: NativeUInt;
          end;);
    end;

    next_req: Puv_req_t;
{$ENDIF}
  end;

  uv_shutdown_t = record
  type
    uv_shutdown_cb = procedure(var req: uv_shutdown_t; status: Integer); cdecl;

  var
    uv_req: uv_req_t;
    handle: Puv_stream_t;
    cb: uv_shutdown_cb;
  end;

{$IFDEF MSWINDOWS}

  uv_mutex_t = TRTLCriticalSection;

  uv_rwlock_t = record
    read_write_lock_: SRWLOCK;
{$IFDEF WIN64}
    padding_: array [0 .. 71] of Byte;
{$ELSE}
    padding_: array [0 .. 43] of Byte;
{$ENDIF}
  end;
{$ELSE}

  uv_mutex_t = pthread_mutex_t;
  uv_rwlock_t = pthread_rwlock_t;

{$ENDIF}

  uv_async_t = record
  type
    uv_async_cb = procedure(var handle: uv_async_t); cdecl;

  var
    uv_handle: uv_handle_t;
{$IFDEF MSWINDOWS}
    async_req: uv_req_t;
    async_cb: uv_async_cb;
    async_sent: UTF8Char;
{$ELSE}
    async_cb: uv_async_cb;
    queue: array [0 .. 1] of Pointer;
    pending: Integer;
{$ENDIF}
  end;

  uv_signal_t = record
  type
    uv_signal_cb = procedure(var handle: uv_signal_t; signum: Integer); cdecl;

  var
    uv_handle: uv_handle_t;
    signal_cb: uv_signal_cb;
    signum: Integer;

    tree_entry: record
      rbe_left, rbe_right, rbe_parent: Puv_signal_t;
      rbe_color: Integer;
    end;

{$IFDEF MSWINDOWS}

    signal_req: uv_req_t;
    pending_signum: Cardinal;
{$ELSE}
    caught_signals: Cardinal;
    dispatched_signals: Cardinal;
{$ENDIF}
  end;

  uv_loop_t = record
{$IFDEF POSIX}
  type
    uv__io_t = record
    type
      uv__io_cb = procedure(var loop: uv_loop_t; var w: uv__io_t;
        events: Cardinal); cdecl;

    var
      cb: uv__io_cb;
      pending_queue: array [0 .. 1] of Pointer;
      watcher_queue: array [0 .. 1] of Pointer;
      pevents: Cardinal;
      events: Cardinal;
      fd: Integer;
    end;

    Puv__io_t = ^uv__io_t;
    PPuv__io_t = ^Puv__io_t;
{$ENDIF}

  var
    data: Pointer;
    active_handles: Cardinal;
    handle_queue: array [0 .. 1] of Pointer;

    active_reqs: record
      case Integer of
        0:
          (unused: Pointer);
        1:
          (count: Cardinal);
    end;

    internal_fields: Pointer;
    stop_flag: Cardinal;
{$IFDEF MSWINDOWS}
    iocp: THANDLE;
    time: UInt64;
    pending_reqs_tail: Puv_req_t;
    endgame_handles: Puv_handle_t;
    timer_heap: Pointer;
    prepare_handles: Puv_prepare_t;
    check_handles: Puv_check_t;
    idle_handles: Puv_idle_t;
    next_prepare_handle: Puv_prepare_t;
    next_check_handle: Puv_check_t;
    next_idle_handle: Puv_idle_t;
    poll_peer_sockets: array [0 .. 3] of TSocket;
    active_tcp_streams: Cardinal;
    active_udp_streams: Cardinal;
    timer_counter: UInt64;
    wq: array [0 .. 1] of Pointer;
    wq_mutex: uv_mutex_t;
    wq_async: uv_async_t;
{$ELSE}
    flags: Cardinal;
    backend_fd: Integer;
    pending_queue: array [0 .. 1] of Pointer;
    watcher_queue: array [0 .. 1] of Pointer;
    watchers: PPuv__io_t;
    nwatchers: Cardinal;
    nfds: Cardinal;
    wq: array [0 .. 1] of Pointer;
    wq_mutex: uv_mutex_t;
    wq_async: uv_async_t;
    cloexec_lock: uv_rwlock_t;
    closing_handles: Puv_handle_t;
    process_handles: array [0 .. 1] of Pointer;
    prepare_handles: array [0 .. 1] of Pointer;
    check_handles: array [0 .. 1] of Pointer;
    idle_handles: array [0 .. 1] of Pointer;
    async_handles: array [0 .. 1] of Pointer;
    async_unused: procedure(); cdecl;
    async_io_watcher: uv__io_t;
    async_wfd: Integer;

    timer_heap: record
      min: Pointer;
      nelts: Cardinal;
    end;

    timer_counter: UInt64;
    time: UInt64;
    signal_pipefd: array [0 .. 1] of Integer;
    signal_io_watcher: uv__io_t;
    child_watcher: uv_signal_t;
    emfile_fd: Integer;
    inotify_read_watcher: uv__io_t;
    inotify_watchers: Pointer;
    inotify_fd: Integer;
{$ENDIF}
  end;

  uv_stream_t = record
  type
{$IFDEF MSWINDOWS}
    uv_read_t = record
      uv_req: uv_req_t;
      event_handle: THANDLE;
      wait_handle: THANDLE;
    end;
{$ENDIF}

    uv_read_cb = procedure(var stream: uv_stream_t; nread: ssize_t;
      const buf: uv_buf_t); cdecl;
    uv_connection_cb = procedure(var server: uv_stream_t;
      status: Integer); cdecl;
    uv_alloc_cb = procedure(var handle: uv_handle_t; suggested_size: NativeUInt;
      var buf: uv_buf_t); cdecl;

  var
    uv_handle: uv_handle_t;
    write_queue_size: NativeUInt;
    alloc_cb: uv_alloc_cb;
    read_cb: uv_read_cb;
{$IFDEF MSWINDOWS}
    reqs_pending: Cardinal;
    activecnt: Integer;
    read_req: uv_read_t;

    stream: record
      case Integer of
        0:
          (conn: record write_reqs_pending: Cardinal;
            shutdown_req: Puv_shutdown_t;
          end);
        1:
          (serv: record connection_cb: uv_connection_cb;
          end);
    end;
{$ELSE}

    connect_req: Puv_connect_t;
    shutdown_req: Puv_shutdown_t;
    io_watcher: uv_loop_t.uv__io_t;
    write_queue: array [0 .. 1] of Pointer;
    write_completed_queue: array [0 .. 1] of Pointer;
    connection_cb: uv_connection_cb;
    delayed_error: Integer;
    accepted_fd: Integer;
    queued_fds: Pointer;
{$ENDIF}
  end;

  Puv_write_t = ^uv_write_t;

  uv_write_t = record
  type
    uv_write_cb = procedure(var req: uv_write_t; status: Integer); cdecl;

  var
    uv_req: uv_req_t;
    cb: uv_write_cb;
    send_handle: Puv_stream_t;
    handle: Puv_stream_t;
{$IFDEF MSWINDOWS}
    coalesced: Integer;
    write_buffer: uv_buf_t;
    event_handle: THANDLE;
    wait_handle: THANDLE;
{$ELSE}
    queue: array [0 .. 1] of Pointer;
    write_index: Cardinal;
    bufs: Puv_buf_t;
    nbufs: Cardinal;
    error: Integer;
    bufsml: array [0 .. 3] of uv_buf_t;
{$ENDIF}
  end;

  uv_connect_t = record
  type
    uv_connect_cb = procedure(var req: uv_connect_t; status: Integer); cdecl;

  var
    uv_req: uv_req_t;
    cb: uv_connect_cb;
    handle: Puv_stream_t;
{$IFDEF POSIX}
    queue: array [0 .. 1] of Pointer;
{$ENDIF}
  end;

  uv_poll_event = (UV__READABLE = 1, UV__WRITABLE = 2, UV__DISCONNECT = 4,
    UV__PRIORITIZED = 8);

  uv_poll_t = record
  type
{$IFDEF MSWINDOWS}
    AFD_POLL_HANDLE_INFO = record
      handle: THANDLE;
      events: ULONG;
      status: NTSTATUS;
    end;

    AFD_POLL_INFO = record
      Timeout: LARGE_INTEGER;
      NumberOfHandles: ULONG;
      Exclusive: ULONG;
      Handles: array [0 .. 0] of AFD_POLL_HANDLE_INFO;
    end;
{$ENDIF}

    uv_poll_cb = procedure(var handle: uv_poll_t; status: Integer;
      events: Integer); cdecl;

  var
    uv_handle: uv_handle_t;
    poll_cb: uv_poll_cb;
{$IFDEF MSWINDOWS}
    SOCKET: TSocket;
    peer_socket: TSocket;
    afd_poll_info_1: AFD_POLL_INFO;
    afd_poll_info_2: AFD_POLL_INFO;
    poll_req_1: uv_req_t;
    poll_req_2: uv_req_t;
    submitted_events_1: Byte;
    submitted_events_2: Byte;
    mask_events_1: Byte;
    mask_events_2: Byte;
    events: Byte;
{$ELSE}
    io_watcher: uv_loop_t.uv__io_t;
{$ENDIF}
  end;

  Puv_timer_t = ^uv_timer_t;

  uv_timer_t = record
  type
    uv_timer_cb = procedure(var handle: uv_timer_t); cdecl;

  var
    uv_handle: uv_handle_t;
{$IFDEF MSWINDOWS}
    heap_node: array [0 .. 2] of Pointer;
    unused: Integer;
    Timeout: UInt64;
    &repeat: UInt64;
    start_id: UInt64;
{$ENDIF}
    timer_cb: uv_timer_cb;
{$IFDEF POSIX}
    heap_node: array [0 .. 2] of Pointer;
    Timeout: UInt64;
    &repeat: UInt64;
    start_id: UInt64;
{$ENDIF}
  end;

  uv_prepare_t = record
  type
    uv_prepare_cb = procedure(var handle: uv_prepare_t); cdecl;

  var
    uv_handle: uv_handle_t;
{$IFDEF MSWINDOWS}
    prepare_prev: Puv_prepare_t;
    prepare_next: Puv_prepare_t;
{$ENDIF}
    prepare_cb: uv_prepare_cb;
{$IFDEF POSIX}
    queue: array [0 .. 1] of Pointer;
{$ENDIF}
  end;

  uv_check_t = record
  type
    uv_check_cb = procedure(var handle: uv_check_t); cdecl;

  var
    uv_handle: uv_handle_t;
{$IFDEF MSWINDOWS}
    check_prev: Puv_check_t;
    check_next: Puv_check_t;
{$ENDIF}
    check_cb: uv_check_cb;
{$IFDEF POSIX}
    queue: array [0 .. 1] of Pointer;
{$ENDIF}
  end;

  uv_idle_t = record
  type
    uv_idle_cb = procedure(var handle: uv_idle_t); cdecl;

  var
    uv_handle: uv_handle_t;
{$IFDEF MSWINDOWS}
    idle_prev: Puv_idle_t;
    idle_next: Puv_idle_t;
{$ENDIF}
    idle_cb: uv_idle_cb;
{$IFDEF POSIX}
    queue: array [0 .. 1] of Pointer;
{$ENDIF}
  end;

  uv_process_t = record
  type
    uv_exit_cb = procedure(var p1: uv_process_t; exit_status: Int64;
      term_signal: Integer); cdecl;
{$IFDEF MSWINDOWS}
    uv_process_exit_t = uv_req_t;
{$ENDIF}

  var
    uv_handle: uv_handle_t;
    exit_cb: uv_exit_cb;
    pid: Integer;
{$IFDEF MSWINDOWS}
    exit_req: uv_process_exit_t;
    child_stdio_buffer: PByte;
    exit_signal: Integer;
    wait_handle: THANDLE;
    process_handle: THANDLE;
    exit_cb_pending: UTF8Char;
{$ELSE}
    queue: array [0 .. 1] of Pointer;
    status: Integer;
{$ENDIF}
  end;

  PPUTF8Char = ^PUTF8Char;

  uv_stdio_flags = (UV__IGNORE = 0, UV__CREATE_PIPE = 1, UV__INHERIT_FD = 2,
    UV__INHERIT_STREAM = 4, UV__READABLE_PIPE = 16, UV__WRITABLE_PIPE = 32,
    UV__NONBLOCK_PIPE = 64, UV__OVERLAPPED_PIPE = 64);

  Puv_stdio_container_t = ^uv_stdio_container_t;

  uv_stdio_container_t = record
    flags: uv_stdio_flags;

    data: record
      case Integer of
        0:
          (stream: Puv_stream_t);
        1:
          (fd: Integer);
    end;
  end;

  uv_process_options_t = record
    exit_cb: uv_process_t.uv_exit_cb;
    &FILE: PUTF8Char;
    args: PPUTF8Char;
    env: PPUTF8Char;
    cwd: PUTF8Char;
    flags: Cardinal;
    stdio_count: Integer;
    stdio: Puv_stdio_container_t;
    uid: uv_uid_t;
    gid: uv_gid_t;
  end;

  uv_timespec_t = record
    tv_sec: Integer;
    tv_nsec: Integer;
  end;

  Puv_stat_t = ^uv_stat_t;

  uv_stat_t = record
    st_dev: UInt64;
    st_mode: UInt64;
    st_nlink: UInt64;
    st_uid: UInt64;
    st_gid: UInt64;
    st_rdev: UInt64;
    st_ino: UInt64;
    st_size: UInt64;
    st_blksize: UInt64;
    st_blocks: UInt64;
    st_flags: UInt64;
    st_gen: UInt64;
    st_atim: uv_timespec_t;
    st_mtim: uv_timespec_t;
    st_ctim: uv_timespec_t;
    st_birthtim: uv_timespec_t;
  end;

  uv__work_t = record
    work: procedure(var w: uv__work_t); cdecl;
    done: procedure(var w: uv__work_t; status: Integer); cdecl;
    loop: Puv_loop_t;
    wq: array [0 .. 1] of Pointer;
  end;

  uv_fs_event = (UV__RENAME = 1, UV__CHANGE = 2);

  uv_fs_type = (UV__FS_UNKNOWN = -1, UV__FS_CUSTOM = 0, UV__FS_OPEN = 1,
    UV__FS_CLOSE = 2, UV__FS_READ = 3, UV__FS_WRITE = 4, UV__FS_SENDFILE = 5,
    UV__FS_STAT = 6, UV__FS_LSTAT = 7, UV__FS_FSTAT = 8, UV__FS_FTRUNCATE = 9,
    UV__FS_UTIME = 10, UV__FS_FUTIME = 11, UV__FS_ACCESS = 12,
    UV__FS_CHMOD = 13, UV__FS_FCHMOD = 14, UV__FS_FSYNC = 15,
    UV__FS_FDATASYNC = 16, UV__FS_UNLINK = 17, UV__FS_RMDIR = 18,
    UV__FS_MKDIR = 19, UV__FS_MKDTEMP = 20, UV__FS_RENAME = 21,
    UV__FS_SCANDIR = 22, UV__FS_LINK = 23, UV__FS_SYMLINK = 24,
    UV__FS_READLINK = 25, UV__FS_CHOWN = 26, UV__FS_FCHOWN = 27,
    UV__FS_REALPATH = 28, UV__FS_COPYFILE = 29, UV__FS_LCHOWN = 30,
    UV__FS_OPENDIR = 31, UV__FS_READDIR = 32, UV__FS_CLOSEDIR = 33,
    UV__FS_STATFS = 34, UV__FS_MKSTEMP = 35, UV__FS_LUTIME = 36);

  uv_fs_t = record
  type
    uv_fs_cb = procedure(var req: uv_fs_t); cdecl;

  var
    uv_req: uv_req_t;
    fs_type: uv_fs_type;
    loop: Puv_loop_t;
    cb: uv_fs_cb;
    result: ssize_t;
    ptr: Pointer;
    path: PUTF8Char;
    statbuf: uv_stat_t;
{$IFDEF MSWINDOWS}
    work_req: uv__work_t;
    flags: Integer;
    sys_errno_: DWORD;

    &FILE: record
      case Integer of
        0:
          (pathw: PWCHAR);
        1:
          (fd: Integer);
    end;

    fs: record
      case Integer of
        0:
          (info: record mode: Integer;
            new_pathw: PWCHAR;
            file_flags: Integer;
            fd_out: Integer;
            nbufs: Cardinal;
            bufs: Puv_buf_t;
            Offset: Int64;
            bufsml: array [0 .. 3] of uv_buf_t;
          end);
        1:
          (time: record atime: Double;
            mtime: Double;
          end);
    end;
{$ELSE}

    new_path: PUTF8Char;
    &FILE: uv_file;
    flags: Integer;
    mode: mode_t;
    nbufs: Cardinal;
    bufs: Puv_buf_t;
    off: off_t;
    uid: uv_uid_t;
    gid: uv_gid_t;
    atime: Double;
    mtime: Double;
    work_req: uv__work_t;
    bufsml: array [0 .. 3] of uv_buf_t;
{$ENDIF}
  end;

  uv_work_t = record
  type
    uv_work_cb = procedure(var req: uv_work_t); cdecl;
    uv_after_work_cb = procedure(var req: uv_work_t; status: Integer); cdecl;

  var
    uv_req: uv_req_t;
    loop: Puv_loop_t;
    work_cb: uv_work_cb;
    after_work_cb: uv_after_work_cb;
    work_req: uv__work_t;
  end;

  Paddrinfo = Pointer;
  PaddrinfoW = Pointer;

  uv_getaddrinfo_t = record
  type
    uv_getaddrinfo_cb = procedure(var req: uv_getaddrinfo_t; status: Integer;
      res: Paddrinfo); cdecl;

  var
    uv_req: uv_req_t;
    loop: Puv_loop_t;
    work_req: uv__work_t;
    getaddrinfo_cb: uv_getaddrinfo_cb;
{$IFDEF MSWINDOWS}
    alloc: Pointer;
    node: PWideCHAR;
    service: PWideCHAR;
    addrinfow: PaddrinfoW;
    addrinfo: Paddrinfo;
    retcode: Integer;
{$ELSE}
    hints: Paddrinfo;
    hostname: PUTF8Char;
    service: PUTF8Char;
    addrinfo: Paddrinfo;
    retcode: Integer;
{$ENDIF}
  end;

  uv_getnameinfo_t = record
  type
    uv_getnameinfo_cb = procedure(var req: uv_getnameinfo_t; status: Integer;
      const hostname: PUTF8Char; const service: PUTF8Char); cdecl;

  var
    uv_req: uv_req_t;
    loop: Puv_loop_t;
    work_req: uv__work_t;
    getnameinfo_cb: uv_getnameinfo_cb;
    storage: sockaddr_storage;
    flags: Integer;
    host: array [0 .. 1024] of UTF8Char;
    service: array [0 .. 31] of UTF8Char;
    retcode: Integer;
  end;

  uv_random_t = record
  type
    uv_random_cb = procedure(var req: uv_random_t; status: Integer;
      buf: Pointer; buflen: NativeUInt); cdecl;

  var
    uv_req: uv_req_t;
    loop: Puv_loop_t;
    status: Integer;
    buf: Pointer;
    buflen: NativeUInt;
    cb: uv_random_cb;
    work_req: uv__work_t;
  end;

{$IFDEF MSWINDOWS}

  Puv_tcp_accept_t = ^uv_tcp_accept_t;

  uv_tcp_accept_t = record
    uv_req: uv_req_t;
    accept_socket: TSocket;
    accept_buffer: array [0 .. 287] of UTF8Char;
    event_handle: THANDLE;
    wait_handle: THANDLE;
    next_pending: Puv_tcp_accept_t;
  end;

  LPFN_ACCEPTEX = function(sListenSocket, sAcceptSocket: TSocket;
    lpOutputBuffer: Pointer; dwReceiveDataLength, dwLocalAddressLength,
    dwRemoteAddressLength: DWORD; var lpdwBytesReceived: DWORD;
    lpOverlapped: POverlapped): BOOL; stdcall;
  LPFN_CONNECTEX = function(const s: TSocket; const name: PSOCKADDR;
    const namelen: Integer; lpSendBuffer: Pointer; dwSendDataLength: DWORD;
    var lpdwBytesSent: DWORD; lpOverlapped: LPWSAOVERLAPPED): BOOL; stdcall;
  LPFN_WSARECVFROM = function(const s: TSocket; lpBuffers: LPWSABUF;
    dwBufferCount: DWORD; var lpNumberOfBytesRecvd: DWORD; var lpFlags: DWORD;
    lpFrom: PSOCKADDR; var Fromlen: Integer; AOverlapped: Pointer;
    lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE): Integer; stdcall;
  LPFN_WSARECV = function(const s: TSocket; lpBuffers: LPWSABUF;
    dwBufferCount: DWORD; var lpNumberOfBytesRecvd: DWORD; var lpFlags: DWORD;
    lpOverlapped: LPWSAOVERLAPPED;
    lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE): Integer; stdcall;
{$ENDIF}
  uv_tcp_flags = (UV__TCP_IPV6ONLY = 1);

  uv_tcp_t = record
    uv_stream: uv_stream_t;
{$IFDEF MSWINDOWS}
    SOCKET: TSocket;
    delayed_error: Integer;

    tcp: record
      case Integer of
        0:
          (serv: record accept_reqs: Puv_tcp_accept_t;
            processed_accepts: Cardinal;
            pending_accepts: Puv_tcp_accept_t;
            func_acceptex: LPFN_ACCEPTEX;
          end);
        1:
          (conn: record read_buffer: uv_buf_t;
            func_connectex: LPFN_CONNECTEX;
          end);
    end;
{$ENDIF}
  end;
  puv_tcp_t = ^uv_tcp_t;

  Puv_udp_t = ^uv_udp_t;

  uv_udp_t = record
  type
    uv_udp_recv_cb = procedure(var handle: uv_udp_t; nread: ssize_t;
      const buf: Puv_buf_t; const addr: PSOCKADDR; flags: Cardinal); cdecl;

  var
    uv_handle: uv_handle_t;
    send_queue_size: NativeUInt;
    send_queue_count: NativeUInt;
{$IFDEF MSWINDOWS}
    SOCKET: TSocket;
    reqs_pending: Cardinal;
    activecnt: Integer;
    recv_req: uv_req_t;
    recv_buffer: uv_buf_t;
    recv_from: sockaddr_storage;
    recv_from_len: Integer;
    recv_cb: uv_udp_recv_cb;
    alloc_cb: uv_stream_t.uv_alloc_cb;
    func_wsarecv: LPFN_WSARECV;
    func_wsarecvfrom: LPFN_WSARECVFROM;
{$ELSE}
    alloc_cb: uv_stream_t.uv_alloc_cb;
    recv_cb: uv_udp_recv_cb;
    io_watcher: uv_loop_t.uv__io_t;
    write_queue: array [0 .. 1] of Pointer;
    write_completed_queue: array [0 .. 1] of Pointer;
{$ENDIF}
  end;

  uv_udp_send_t = record
  type
    uv_udp_send_cb = procedure(var req: uv_udp_send_t; status: Integer); cdecl;

  var
    uv_req: uv_req_t;
    handle: Puv_udp_t;
    cb: uv_udp_send_cb;
{$IFDEF POSIX}
    queue: array [0 .. 1] of Pointer;
    addr: sockaddr_storage;
    nbufs: Cardinal;
    bufs: Puv_buf_t;
    status: ssize_t;
    send_cb: uv_udp_send_cb;
    bufsml: array [0 .. 3] of uv_buf_t;
{$ENDIF}
  end;

  uv_tty_mode_t = (UV_TTY_MODE_NORMAL = 0, UV_TTY_MODE_RAW = 1,
    UV_TTY_MODE_IO = 2);
  uv_tty_vtermstate_t = (UV_TTY_SUPPORTED = 0, UV_TTY_UNSUPPORTED = 1);

  uv_tty_t = record
    uv_stream: uv_stream_t;
{$IFDEF MSWINDOWS}
    handle: THANDLE;

    tty: record
      case Integer of
        0:
          (rd: record unused_: THANDLE;
            read_line_buffer: uv_buf_t;
            read_raw_wait: THANDLE;
            last_key: array [0 .. 7] of UTF8Char;
            last_key_offset: Byte;
            last_key_len: Byte;
            last_utf16_high_surrogate: WCHAR;
            last_input_record: INPUT_RECORD;
          end);
        1:
          (wr: record utf8_codepoint: Cardinal;
            utf8_bytes_left: Byte;
            previous_eol: Byte;
            ansi_parser_state: Word;
            ansi_csi_argc: Byte;
            ansi_csi_argv: array [0 .. 3] of Word;
            saved_position: COORD;
            saved_attributes: &WORD;
          end);
    end;
{$ELSE}

  type
    cc_t = Byte;
    speed_t = Cardinal;
    tcflag_t = Cardinal;

    termios = record
      c_iflag: tcflag_t;
      c_oflag: tcflag_t;
      c_cflag: tcflag_t;
      c_lflag: tcflag_t;
      c_line: cc_t;
      c_cc: array [0 .. 31] of cc_t;
      c_ispeed: speed_t;
      c_ospeed: speed_t;
    end;

  var
    orig_termios: termios;
    mode: Integer;
{$ENDIF}
  end;

  Puv_pipe_accept_t = ^uv_pipe_accept_t;

  uv_pipe_accept_t = record
    uv_req: uv_req_t;
    pipeHandle: THANDLE;
    next_pending: Puv_pipe_accept_t;
  end;

  uv_pipe_t = record
    uv_stream: uv_stream_t;
    ipc: Integer;
{$IFDEF MSWINDOWS}
    handle: THANDLE;
    name: PWideCHAR;

    pipe: record
      case Integer of
        0:
          (serv: record pending_instances: Integer;
            accept_reqs: Puv_pipe_accept_t;
            pending_accepts: Puv_pipe_accept_t;
          end);
        1:
          (conn: record eof_timer: Puv_timer_t;
            dummy: uv_write_t;
            ipc_remote_pid: DWORD;
            ipc_data_frame: record
            case Integer of
              0: (payload_remaining: UINT32);
              1: (dummy: UInt64);
            end;
              ipc_xfer_queue: array [0 .. 1] of Pointer;
              ipc_xfer_queue_length: Integer;
              non_overlapped_writes_tail: Puv_write_t;
              readfile_thread_lock: TRTLCriticalSection;
              readfile_thread_handle: THANDLE;
            end);
    end;
{$ELSE}

    pipe_fname: PUTF8Char;
{$ENDIF}
  end;

  uv_timeval_t = record
    tv_sec: Integer;
    tv_usec: Integer;
  end;

  uv_timeval64_t = record
    tv_sec: Int64;
    tv_usec: INT32;
  end;

  uv_rusage_t = record
    ru_utime: uv_timeval_t;
    ru_stime: uv_timeval_t;
    ru_maxrss: UInt64;
    ru_ixrss: UInt64;
    ru_idrss: UInt64;
    ru_isrss: UInt64;
    ru_minflt: UInt64;
    ru_majflt: UInt64;
    ru_nswap: UInt64;
    ru_inblock: UInt64;
    ru_oublock: UInt64;
    ru_msgsnd: UInt64;
    ru_msgrcv: UInt64;
    ru_nsignals: UInt64;
    ru_nvcsw: UInt64;
    ru_nivcsw: UInt64;
  end;

  uv_passwd_t = record
    username: PUTF8Char;
    uid: Cardinal;
    gid: Cardinal;
    shell: PUTF8Char;
    homedir: PUTF8Char;
  end;

  uv_cpu_times_t = record
    user: UInt64;
    nice: UInt64;
    sys: UInt64;
    idle: UInt64;
    irq: UInt64;
  end;

  Puv_cpu_info_t = ^uv_cpu_info_t;

  uv_cpu_info_t = record
    model: PUTF8Char;
    speed: Integer;
    cpu_times: uv_cpu_times_t;
  end;

  Puv_interface_address_t = ^uv_interface_address_t;

  uv_interface_address_t = record
    name: PUTF8Char;
    phys_addr: array [0 .. 5] of UTF8Char;
    is_internal: Integer;

    address: record
      case Integer of
        0:
          (address4: sockaddr_in);
        1:
          (address6: sockaddr_in6);
    end;

    netmask: record
      case Integer of
        0:
          (netmask4: sockaddr_in);
        1:
          (netmask6: sockaddr_in6);
    end;
  end;

  Puv_env_item_t = ^uv_env_item_t;

  uv_env_item_t = record
    name: PUTF8Char;
    Value: PUTF8Char;
  end;

  uv_utsname_t = record
    sysname: array [0 .. 255] of UTF8Char;
    release: array [0 .. 255] of UTF8Char;
    version: array [0 .. 255] of UTF8Char;
    machine: array [0 .. 255] of UTF8Char;
  end;

  uv_dirent_type_t = (UV__DIRENT_UNKNOWN = 0, UV__DIRENT_FILE = 1,
    UV__DIRENT_DIR = 2, UV__DIRENT_LINK = 3, UV__DIRENT_FIFO = 4,
    UV__DIRENT_SOCKET = 5, UV__DIRENT_CHAR = 6, UV__DIRENT_BLOCK = 7);
  Puv_dirent_type_t = ^uv_dirent_type_t;

  Puv_dirent_t = ^uv_dirent_t;

  uv_dirent_t = record
    name: PUTF8Char;
    &Type: uv_dirent_type_t;
  end;

  uv_dir_t = record
    dirents: Puv_dirent_t;
    nentries: NativeUInt;
    reserved: array [0 .. 3] of Pointer;
{$IFDEF MSWINDOWS}
    dir_handle: THANDLE;
    find_data: WIN32_FIND_DATAW;
    need_find_call: BOOL;
{$ELSE}
    dir: Pointer;
{$ENDIF}
  end;

  uv_fs_poll_t = record
  type
    uv_fs_poll_cb = procedure(var handle: uv_fs_poll_t; status: Integer;
      const prev: uv_stat_t; const curr: uv_stat_t); cdecl;

  var
    uv_handle: uv_handle_t;
    poll_ctx: Pointer;
  end;

  uv_fs_event_req_t = uv_req_t;

  uv_fs_event_t = record
  type
    uv_fs_event_cb = procedure(var handle: uv_fs_event_t;
      const filename: PUTF8Char; events: Integer; status: Integer); cdecl;

  var
    uv_handle: uv_handle_t;
    path: PUTF8Char;
{$IFDEF MSWINDOWS}
    req: uv_fs_event_req_t;
    dir_handle: THANDLE;
    req_pending: Integer;
    cb: uv_fs_event_cb;
    filew: PWCHAR;
    short_filew: PWCHAR;
    dirw: PWCHAR;
    buffer: PUTF8Char;
{$ELSE}
    cb: uv_fs_event_cb;
    watchers: array [0 .. 1] of Pointer;
    wd: Integer;
{$ENDIF}
  end;
  puv_fs_event_t = ^uv_fs_event_t;

  uv_lib_t = record
{$IFDEF MSWINDOWS}
    handle: HMODULE;
{$ELSE}
    handle: Pointer;
{$ENDIF}
    errmsg: PUTF8Char;
  end;

  uv_cond_t = record
{$IFDEF MSWINDOWS}
    case Integer of
      0:
        (cond_var: CONDITION_VARIABLE);
      1:
        (unused_: record waiters_count: Cardinal;
          waiters_count_lock: TRTLCriticalSection;
          signal_event: THANDLE;
          broadcast_event: THANDLE;
        end;);
{$ELSE}

  type
    __atomic_wide_counter = record
      case Integer of
        0:
          (__value64: UInt64);
        1:
          (__value32: record __low: Cardinal;
            __high: Cardinal;
          end;);
    end;

  var
    case Integer of
      0:
        (__data: record __wseq: __atomic_wide_counter;
          __g1_start: __atomic_wide_counter;
          __g_refs: array [0 .. 1] of Cardinal;
          __g_size: array [0 .. 1] of Cardinal;
          __g1_orig_size: Cardinal;
          __wrefs: Cardinal;
          __g_signals: array [0 .. 1] of Cardinal;
        end;);
      1:
        (__size: array [0 .. 47] of UTF8Char);
      2:
        (__align: Int64);
{$ENDIF}
  end;

{$IFDEF MSWINDOWS}

  uv_os_fd_t = THANDLE;
  uv_os_sock_t = TSocket;
  uv_sem_t = THANDLE;
  uv_thread_t = THANDLE;

  uv_once_t = record
    ran: Byte;
    event: THANDLE;
  end;
{$ELSE}

  uv_os_sock_t = Integer;
  uv_os_fd_t = Integer;
  uv_once_t = Integer;
  uv_thread_t = Cardinal;

  uv_sem_t = record
    case Integer of
      0:
        (__size: array [0 .. 31] of UTF8Char);
      1:
        (__align: Integer);
  end;
{$ENDIF}

  uv_barrier_t = record
{$IFDEF MSWINDOWS}
    n: Cardinal;
    count: Cardinal;
    mutex: uv_mutex_t;
    turnstile1: uv_sem_t;
    turnstile2: uv_sem_t;
{$ELSE}
    case Integer of
      0:
        (__size: array [0 .. 31] of UTF8Char);
      1:
        (__align: Integer);
{$ENDIF}
  end;

  uv_membership = (UV__LEAVE_GROUP = 0, UV__JOIN_GROUP = 1);

function uv_version(): Cardinal; cdecl; external libdrt name _PU + 'uv_version';

function uv_version_string(): PUTF8Char; cdecl;
  external libdrt name _PU + 'uv_version_string';

procedure uv_library_shutdown(); cdecl;
  external libdrt name _PU + 'uv_library_shutdown';

function uv_replace_allocator(malloc_func: uv_malloc_func;
  realloc_func: uv_realloc_func; calloc_func: uv_calloc_func;
  free_func: uv_free_func): Integer; cdecl;
  external libdrt name _PU + 'uv_replace_allocator';

function uv_default_loop(): Puv_loop_t; cdecl;
  external libdrt name _PU + 'uv_default_loop';

function uv_loop_init(var loop: uv_loop_t): Integer; cdecl;
  external libdrt name _PU + 'uv_loop_init';

function uv_loop_close(var loop: uv_loop_t): Integer; cdecl;
  external libdrt name _PU + 'uv_loop_close';

function uv_loop_new(): Puv_loop_t; cdecl;
  external libdrt name _PU + 'uv_loop_new';

procedure uv_loop_delete(p1: Puv_loop_t); cdecl;
  external libdrt name _PU + 'uv_loop_delete';

function uv_loop_size(): NativeUInt; cdecl;
  external libdrt name _PU + 'uv_loop_size';

function uv_loop_alive(const loop: uv_loop_t): Integer; cdecl;
  external libdrt name _PU + 'uv_loop_alive';

function uv_loop_configure(var loop: uv_loop_t; option: uv_loop_option)
  : Integer varargs; cdecl; external libdrt name _PU + 'uv_loop_configure';

function uv_loop_fork(var loop: uv_loop_t): Integer; cdecl;
  external libdrt name _PU + 'uv_loop_fork';

function uv_run(var p1: uv_loop_t; mode: uv_run_mode): Integer; cdecl;
  external libdrt name _PU + 'uv_run';

procedure uv_stop(var p1: uv_loop_t); cdecl;
  external libdrt name _PU + 'uv_stop';

procedure uv_ref(var p1: uv_handle_t); cdecl;
  external libdrt name _PU + 'uv_ref';

procedure uv_unref(var p1: uv_handle_t); cdecl;
  external libdrt name _PU + 'uv_unref';

function uv_has_ref(const p1: uv_handle_t): Integer; cdecl;
  external libdrt name _PU + 'uv_has_ref';

procedure uv_update_time(var p1: uv_loop_t); cdecl;
  external libdrt name _PU + 'uv_update_time';

function uv_now(const p1: uv_loop_t): UInt64; cdecl;
  external libdrt name _PU + 'uv_now';

function uv_backend_fd(const p1: uv_loop_t): Integer; cdecl;
  external libdrt name _PU + 'uv_backend_fd';

function uv_backend_timeout(const p1: uv_loop_t): Integer; cdecl;
  external libdrt name _PU + 'uv_backend_timeout';

function uv_translate_sys_error(sys_errno: Integer): Integer; cdecl;
  external libdrt name _PU + 'uv_translate_sys_error';

function uv_strerror(err: Integer): PUTF8Char; cdecl;
  external libdrt name _PU + 'uv_strerror';

function uv_strerror_r(err: Integer; buf: PUTF8Char; buflen: NativeUInt)
  : PUTF8Char; cdecl; external libdrt name _PU + 'uv_strerror_r';

function uv_err_name(err: Integer): PUTF8Char; cdecl;
  external libdrt name _PU + 'uv_err_name';

function uv_err_name_r(err: Integer; buf: PUTF8Char; buflen: NativeUInt)
  : PUTF8Char; cdecl; external libdrt name _PU + 'uv_err_name_r';

function uv_shutdown(var req: uv_shutdown_t; handle: Puv_stream_t;
  cb: uv_shutdown_t.uv_shutdown_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_shutdown';

function uv_handle_size(&Type: uv_handle_type): NativeUInt; cdecl;
  external libdrt name _PU + 'uv_handle_size';

function uv_handle_get_type(const handle: uv_handle_t): uv_handle_type; cdecl;
  external libdrt name _PU + 'uv_handle_get_type';

function uv_handle_type_name(&Type: uv_handle_type): PUTF8Char; cdecl;
  external libdrt name _PU + 'uv_handle_type_name';

function uv_handle_get_data(const handle: uv_handle_t): Pointer; cdecl;
  external libdrt name _PU + 'uv_handle_get_data';

function uv_handle_get_loop(const handle: uv_handle_t): Puv_loop_t; cdecl;
  external libdrt name _PU + 'uv_handle_get_loop';

procedure uv_handle_set_data(var handle: uv_handle_t; data: Pointer); cdecl;
  external libdrt name _PU + 'uv_handle_set_data';

function uv_req_size(&Type: uv_req_type): NativeUInt; cdecl;
  external libdrt name _PU + 'uv_req_size';

function uv_req_get_data(const req: uv_req_t): Pointer; cdecl;
  external libdrt name _PU + 'uv_req_get_data';

procedure uv_req_set_data(var req: uv_req_t; data: Pointer); cdecl;
  external libdrt name _PU + 'uv_req_set_data';

function uv_req_get_type(const req: uv_req_t): uv_req_type; cdecl;
  external libdrt name _PU + 'uv_req_get_type';

function uv_req_type_name(&Type: uv_req_type): PUTF8Char; cdecl;
  external libdrt name _PU + 'uv_req_type_name';

function uv_is_active(const handle: uv_handle_t): Integer; cdecl;
  external libdrt name _PU + 'uv_is_active';

procedure uv_walk(var loop: uv_loop_t; walk_cb: uv_handle_t.uv_walk_cb;
  arg: Pointer); cdecl; external libdrt name _PU + 'uv_walk';

procedure uv_print_all_handles(var loop: uv_loop_t; stream: PPointer); cdecl;
  external libdrt name _PU + 'uv_print_all_handles';

procedure uv_print_active_handles(var loop: uv_loop_t; stream: PPointer); cdecl;
  external libdrt name _PU + 'uv_print_active_handles';

procedure uv_close(var handle: uv_handle_t; close_cb: uv_handle_t.uv_close_cb);
  cdecl; external libdrt name _PU + 'uv_close';

function uv_send_buffer_size(var handle: uv_handle_t; var Value: Integer): Integer;
  cdecl; external libdrt name _PU + 'uv_send_buffer_size';

function uv_recv_buffer_size(var handle: uv_handle_t; var Value: Integer): Integer;
  cdecl; external libdrt name _PU + 'uv_recv_buffer_size';

function uv_fileno(const handle: uv_handle_t; var fd: uv_os_fd_t): Integer;
  cdecl; external libdrt name _PU + 'uv_fileno';

function uv_buf_init(Base: PUTF8Char; len: Cardinal): uv_buf_t; cdecl;
  external libdrt name _PU + 'uv_buf_init';

function uv_pipe(var fds: uv_file; read_flags: Integer; write_flags: Integer)
  : Integer; cdecl; external libdrt name _PU + 'uv_pipe';

function uv_socketpair(&Type: Integer; protocol: Integer;
  var socket_vector: uv_os_sock_t; flags0: Integer; flags1: Integer): Integer;
  cdecl; external libdrt name _PU + 'uv_socketpair';

function uv_stream_get_write_queue_size(const stream: uv_stream_t): NativeUInt;
  cdecl; external libdrt name _PU + 'uv_stream_get_write_queue_size';

function uv_listen(var stream: uv_stream_t; backlog: Integer;
  cb: uv_stream_t.uv_connection_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_listen';

function uv_accept(var server: uv_stream_t; var client: uv_stream_t): Integer;
  cdecl; external libdrt name _PU + 'uv_accept';

function uv_read_start(var p1: uv_stream_t; alloc_cb: uv_stream_t.uv_alloc_cb;
  read_cb: uv_stream_t.uv_read_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_read_start';

function uv_read_stop(var p1: uv_stream_t): Integer; cdecl;
  external libdrt name _PU + 'uv_read_stop';

function uv_write(var req: uv_write_t; var handle: uv_stream_t; bufs: Puv_buf_t;
  nbufs: Cardinal; cb: uv_write_t.uv_write_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_write';

function uv_write2(var req: uv_write_t; var handle: uv_stream_t;
  bufs: Puv_buf_t; nbufs: Cardinal; var send_handle: uv_stream_t;
  cb: uv_write_t.uv_write_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_write2';

function uv_try_write(var handle: uv_stream_t; bufs: Puv_buf_t; nbufs: Cardinal)
  : Integer; cdecl; external libdrt name _PU + 'uv_try_write';

function uv_try_write2(var handle: uv_stream_t; bufs: Puv_buf_t;
  nbufs: Cardinal; var send_handle: uv_stream_t): Integer; cdecl;
  external libdrt name _PU + 'uv_try_write2';

function uv_is_readable(const handle: uv_stream_t): Integer; cdecl;
  external libdrt name _PU + 'uv_is_readable';

function uv_is_writable(const handle: uv_stream_t): Integer; cdecl;
  external libdrt name _PU + 'uv_is_writable';

function uv_stream_set_blocking(var handle: uv_stream_t; blocking: Integer)
  : Integer; cdecl; external libdrt name _PU + 'uv_stream_set_blocking';

function uv_is_closing(const handle: uv_handle_t): Integer; cdecl;
  external libdrt name _PU + 'uv_is_closing';

function uv_tcp_init(var p1: uv_loop_t; handle: Pointer): Integer; cdecl;
  external libdrt name _PU + 'uv_tcp_init';

function uv_tcp_init_ex(var p1: uv_loop_t; var handle: uv_tcp_t;
  flags: Cardinal): Integer; cdecl; external libdrt name _PU + 'uv_tcp_init_ex';

function uv_tcp_open(var handle: uv_tcp_t; sock: uv_os_sock_t): Integer; cdecl;
  external libdrt name _PU + 'uv_tcp_open';

function uv_tcp_nodelay(var handle: uv_tcp_t; enable: Integer): Integer; cdecl;
  external libdrt name _PU + 'uv_tcp_nodelay';

function uv_tcp_keepalive(var handle: uv_tcp_t; enable: Integer;
  delay: Cardinal): Integer; cdecl;
  external libdrt name _PU + 'uv_tcp_keepalive';

function uv_tcp_simultaneous_accepts(var handle: uv_tcp_t; enable: Integer)
  : Integer; cdecl; external libdrt name _PU + 'uv_tcp_simultaneous_accepts';

function uv_tcp_bind(var handle: uv_tcp_t; const addr: PSOCKADDR;
  flags: Cardinal): Integer; cdecl; external libdrt name _PU + 'uv_tcp_bind';

function uv_tcp_getsockname(const handle: uv_tcp_t; name: PSOCKADDR;
  var namelen: Integer): Integer; cdecl;
  external libdrt name _PU + 'uv_tcp_getsockname';

function uv_tcp_getpeername(const handle: uv_tcp_t; name: PSOCKADDR;
  var namelen: Integer): Integer; cdecl;
  external libdrt name _PU + 'uv_tcp_getpeername';

function uv_tcp_close_reset(var handle: uv_tcp_t;
  close_cb: uv_handle_t.uv_close_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_tcp_close_reset';

function uv_tcp_connect(var req: uv_connect_t; var handle: uv_tcp_t;
  const addr: PSOCKADDR; cb: uv_connect_t.uv_connect_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_tcp_connect';

function uv_udp_init(var p1: uv_loop_t; handle: Pointer): Integer; cdecl;
  external libdrt name _PU + 'uv_udp_init';

function uv_udp_init_ex(var p1: uv_loop_t; var handle: uv_udp_t;
  flags: Cardinal): Integer; cdecl; external libdrt name _PU + 'uv_udp_init_ex';

function uv_udp_open(var handle: uv_udp_t; sock: uv_os_sock_t): Integer; cdecl;
  external libdrt name _PU + 'uv_udp_open';

function uv_udp_bind(var handle: uv_udp_t; const addr: PSOCKADDR;
  flags: Cardinal): Integer; cdecl; external libdrt name _PU + 'uv_udp_bind';

function uv_udp_connect(var handle: uv_udp_t; const addr: PSOCKADDR): Integer;
  cdecl; external libdrt name _PU + 'uv_udp_connect';

function uv_udp_getpeername(const handle: uv_udp_t; name: PSOCKADDR;
  var namelen: Integer): Integer; cdecl;
  external libdrt name _PU + 'uv_udp_getpeername';

function uv_udp_getsockname(const handle: uv_udp_t; name: PSOCKADDR;
  var namelen: Integer): Integer; cdecl;
  external libdrt name _PU + 'uv_udp_getsockname';

function uv_udp_set_membership(var handle: uv_udp_t;
  const multicast_addr: PUTF8Char; const interface_addr: PUTF8Char;
  membership: uv_membership): Integer; cdecl;
  external libdrt name _PU + 'uv_udp_set_membership';

function uv_udp_set_source_membership(var handle: uv_udp_t;
  const multicast_addr: PUTF8Char; const interface_addr: PUTF8Char;
  const source_addr: PUTF8Char; membership: uv_membership): Integer; cdecl;
  external libdrt name _PU + 'uv_udp_set_source_membership';

function uv_udp_set_multicast_loop(var handle: uv_udp_t; &on: Integer): Integer;
  cdecl; external libdrt name _PU + 'uv_udp_set_multicast_loop';

function uv_udp_set_multicast_ttl(var handle: uv_udp_t; ttl: Integer): Integer;
  cdecl; external libdrt name _PU + 'uv_udp_set_multicast_ttl';

function uv_udp_set_multicast_interface(var handle: uv_udp_t;
  const interface_addr: PUTF8Char): Integer; cdecl;
  external libdrt name _PU + 'uv_udp_set_multicast_interface';

function uv_udp_set_broadcast(var handle: uv_udp_t; &on: Integer): Integer;
  cdecl; external libdrt name _PU + 'uv_udp_set_broadcast';

function uv_udp_set_ttl(var handle: uv_udp_t; ttl: Integer): Integer; cdecl;
  external libdrt name _PU + 'uv_udp_set_ttl';

function uv_udp_send(var req: uv_udp_send_t; var handle: uv_udp_t;
  bufs: Puv_buf_t; nbufs: Cardinal; const addr: PSOCKADDR;
  send_cb: uv_udp_send_t.uv_udp_send_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_udp_send';

function uv_udp_try_send(var handle: uv_udp_t; bufs: Puv_buf_t; nbufs: Cardinal;
  const addr: PSOCKADDR): Integer; cdecl;
  external libdrt name _PU + 'uv_udp_try_send';

function uv_udp_recv_start(var handle: uv_udp_t;
  alloc_cb: uv_stream_t.uv_alloc_cb; recv_cb: uv_udp_t.uv_udp_recv_cb): Integer;
  cdecl; external libdrt name _PU + 'uv_udp_recv_start';

function uv_udp_using_recvmmsg(const handle: uv_udp_t): Integer; cdecl;
  external libdrt name _PU + 'uv_udp_using_recvmmsg';

function uv_udp_recv_stop(var handle: uv_udp_t): Integer; cdecl;
  external libdrt name _PU + 'uv_udp_recv_stop';

function uv_udp_get_send_queue_size(const handle: uv_udp_t): NativeUInt; cdecl;
  external libdrt name _PU + 'uv_udp_get_send_queue_size';

function uv_udp_get_send_queue_count(const handle: uv_udp_t): NativeUInt; cdecl;
  external libdrt name _PU + 'uv_udp_get_send_queue_count';

function uv_tty_init(var p1: uv_loop_t; var p2: uv_tty_t; fd: uv_file;
  readable: Integer): Integer; cdecl; external libdrt name _PU + 'uv_tty_init';

function uv_tty_set_mode(var p1: uv_tty_t; mode: uv_tty_mode_t): Integer; cdecl;
  external libdrt name _PU + 'uv_tty_set_mode';

function uv_tty_reset_mode(): Integer; cdecl;
  external libdrt name _PU + 'uv_tty_reset_mode';

function uv_tty_get_winsize(var p1: uv_tty_t; var width, height: Integer)
  : Integer; cdecl; external libdrt name _PU + 'uv_tty_get_winsize';

procedure uv_tty_set_vterm_state(state: uv_tty_vtermstate_t); cdecl;
  external libdrt name _PU + 'uv_tty_set_vterm_state';

function uv_tty_get_vterm_state(var state: uv_tty_vtermstate_t): Integer; cdecl;
  external libdrt name _PU + 'uv_tty_get_vterm_state';

function uv_guess_handle(&FILE: uv_file): uv_handle_type; cdecl;
  external libdrt name _PU + 'uv_guess_handle';

function uv_pipe_init(var p1: uv_loop_t; var handle: uv_pipe_t; ipc: Integer)
  : Integer; cdecl; external libdrt name _PU + 'uv_pipe_init';

function uv_pipe_open(var p1: uv_pipe_t; &FILE: uv_file): Integer; cdecl;
  external libdrt name _PU + 'uv_pipe_open';

function uv_pipe_bind(var handle: uv_pipe_t; const name: PUTF8Char): Integer;
  cdecl; external libdrt name _PU + 'uv_pipe_bind';

procedure uv_pipe_connect(var req: uv_connect_t; var handle: uv_pipe_t;
  const name: PUTF8Char; cb: uv_connect_t.uv_connect_cb); cdecl;
  external libdrt name _PU + 'uv_pipe_connect';

function uv_pipe_getsockname(const handle: uv_pipe_t; buffer: PUTF8Char;
  var size: NativeUInt): Integer; cdecl;
  external libdrt name _PU + 'uv_pipe_getsockname';

function uv_pipe_getpeername(const handle: uv_pipe_t; buffer: PUTF8Char;
  var size: NativeUInt): Integer; cdecl;
  external libdrt name _PU + 'uv_pipe_getpeername';

procedure uv_pipe_pending_instances(var handle: uv_pipe_t; count: Integer);
  cdecl; external libdrt name _PU + 'uv_pipe_pending_instances';

function uv_pipe_pending_count(var handle: uv_pipe_t): Integer; cdecl;
  external libdrt name _PU + 'uv_pipe_pending_count';

function uv_pipe_pending_type(var handle: uv_pipe_t): uv_handle_type; cdecl;
  external libdrt name _PU + 'uv_pipe_pending_type';

function uv_pipe_chmod(var handle: uv_pipe_t; flags: Integer): Integer; cdecl;
  external libdrt name _PU + 'uv_pipe_chmod';

function uv_poll_init(var loop: uv_loop_t; var handle: uv_poll_t; fd: Integer)
  : Integer; cdecl; external libdrt name _PU + 'uv_poll_init';

function uv_poll_init_socket(var loop: uv_loop_t; var handle: uv_poll_t;
  SOCKET: uv_os_sock_t): Integer; cdecl;
  external libdrt name _PU + 'uv_poll_init_socket';

function uv_poll_start(var handle: uv_poll_t; events: Integer;
  cb: uv_poll_t.uv_poll_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_poll_start';

function uv_poll_stop(var handle: uv_poll_t): Integer; cdecl;
  external libdrt name _PU + 'uv_poll_stop';

function uv_prepare_init(var p1: uv_loop_t; prepare: Pointer): Integer;
  cdecl; external libdrt name _PU + 'uv_prepare_init';

function uv_prepare_start(var prepare: uv_prepare_t;
  cb: uv_prepare_t.uv_prepare_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_prepare_start';

function uv_prepare_stop(var prepare: uv_prepare_t): Integer; cdecl;
  external libdrt name _PU + 'uv_prepare_stop';

function uv_check_init(var p1: uv_loop_t; check: Pointer): Integer;
  cdecl; external libdrt name _PU + 'uv_check_init';

function uv_check_start(var check: uv_check_t; cb: uv_check_t.uv_check_cb)
  : Integer; cdecl; external libdrt name _PU + 'uv_check_start';

function uv_check_stop(var check: uv_check_t): Integer; cdecl;
  external libdrt name _PU + 'uv_check_stop';

function uv_idle_init(var p1: uv_loop_t; idle: Pointer): Integer; cdecl;
  external libdrt name _PU + 'uv_idle_init';

function uv_idle_start(var idle: uv_idle_t; cb: uv_idle_t.uv_idle_cb): Integer;
  cdecl; external libdrt name _PU + 'uv_idle_start';

function uv_idle_stop(var idle: uv_idle_t): Integer; cdecl;
  external libdrt name _PU + 'uv_idle_stop';

function uv_async_init(var p1: uv_loop_t; var async: uv_async_t;
  async_cb: uv_async_t.uv_async_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_async_init';

function uv_async_send(var async: uv_async_t): Integer; cdecl;
  external libdrt name _PU + 'uv_async_send';

function uv_timer_init(var p1: uv_loop_t; handle: Pointer): Integer;
  cdecl; external libdrt name _PU + 'uv_timer_init';

function uv_timer_start(var handle: uv_timer_t; cb: uv_timer_t.uv_timer_cb;
  Timeout: UInt64; &repeat: UInt64): Integer; cdecl;
  external libdrt name _PU + 'uv_timer_start';

function uv_timer_stop(var handle: uv_timer_t): Integer; cdecl;
  external libdrt name _PU + 'uv_timer_stop';

function uv_timer_again(var handle: uv_timer_t): Integer; cdecl;
  external libdrt name _PU + 'uv_timer_again';

procedure uv_timer_set_repeat(var handle: uv_timer_t; &repeat: UInt64); cdecl;
  external libdrt name _PU + 'uv_timer_set_repeat';

function uv_timer_get_repeat(const handle: uv_timer_t): UInt64; cdecl;
  external libdrt name _PU + 'uv_timer_get_repeat';

function uv_timer_get_due_in(const handle: uv_timer_t): UInt64; cdecl;
  external libdrt name _PU + 'uv_timer_get_due_in';

function uv_getaddrinfo(var loop: uv_loop_t; var req: uv_getaddrinfo_t;
  getaddrinfo_cb: uv_getaddrinfo_t.uv_getaddrinfo_cb; const node: PUTF8Char;
  const service: PUTF8Char; const hints: Paddrinfo): Integer; cdecl;
  external libdrt name _PU + 'uv_getaddrinfo';

procedure uv_freeaddrinfo(ai: Paddrinfo); cdecl;
  external libdrt name _PU + 'uv_freeaddrinfo';

function uv_getnameinfo(var loop: uv_loop_t; var req: uv_getnameinfo_t;
  getnameinfo_cb: uv_getnameinfo_t.uv_getnameinfo_cb; const addr: PSOCKADDR;
  flags: Integer): Integer; cdecl; external libdrt name _PU + 'uv_getnameinfo';

function uv_spawn(var loop: uv_loop_t; var handle: uv_process_t;
  const options: uv_process_options_t): Integer; cdecl;
  external libdrt name _PU + 'uv_spawn';

function uv_process_kill(var p1: uv_process_t; signum: Integer): Integer; cdecl;
  external libdrt name _PU + 'uv_process_kill';

function uv_kill(pid: Integer; signum: Integer): Integer; cdecl;
  external libdrt name _PU + 'uv_kill';

function uv_process_get_pid(const p1: uv_process_t): uv_pid_t; cdecl;
  external libdrt name _PU + 'uv_process_get_pid';

function uv_queue_work(var loop: uv_loop_t; var req: uv_work_t;
  work_cb: uv_work_t.uv_work_cb; after_work_cb: uv_work_t.uv_after_work_cb)
  : Integer; cdecl; external libdrt name _PU + 'uv_queue_work';

function uv_cancel(var req: uv_req_t): Integer; cdecl;
  external libdrt name _PU + 'uv_cancel';

function uv_setup_args(argc: Integer; argv: PPUTF8Char): PPUTF8Char; cdecl;
  external libdrt name _PU + 'uv_setup_args';

function uv_get_process_title(buffer: PUTF8Char; size: NativeUInt): Integer;
  cdecl; external libdrt name _PU + 'uv_get_process_title';

function uv_set_process_title(const title: PUTF8Char): Integer; cdecl;
  external libdrt name _PU + 'uv_set_process_title';

function uv_resident_set_memory(var rss: NativeUInt): Integer; cdecl;
  external libdrt name _PU + 'uv_resident_set_memory';

function uv_uptime(var uptime: Double): Integer; cdecl;
  external libdrt name _PU + 'uv_uptime';

function uv_get_osfhandle(fd: Integer): uv_os_fd_t; cdecl;
  external libdrt name _PU + 'uv_get_osfhandle';

function uv_open_osfhandle(os_fd: uv_os_fd_t): Integer; cdecl;
  external libdrt name _PU + 'uv_open_osfhandle';

function uv_getrusage(var rusage: uv_rusage_t): Integer; cdecl;
  external libdrt name _PU + 'uv_getrusage';

function uv_os_homedir(buffer: PUTF8Char; var size: NativeUInt): Integer; cdecl;
  external libdrt name _PU + 'uv_os_homedir';

function uv_os_tmpdir(buffer: PUTF8Char; var size: NativeUInt): Integer; cdecl;
  external libdrt name _PU + 'uv_os_tmpdir';

function uv_os_get_passwd(var pwd: uv_passwd_t): Integer; cdecl;
  external libdrt name _PU + 'uv_os_get_passwd';

procedure uv_os_free_passwd(var pwd: uv_passwd_t); cdecl;
  external libdrt name _PU + 'uv_os_free_passwd';

function uv_os_getpid(): uv_pid_t; cdecl;
  external libdrt name _PU + 'uv_os_getpid';

function uv_os_getppid(): uv_pid_t; cdecl;
  external libdrt name _PU + 'uv_os_getppid';

function uv_os_getpriority(pid: uv_pid_t; var priority: Integer): Integer;
  cdecl; external libdrt name _PU + 'uv_os_getpriority';

function uv_os_setpriority(pid: uv_pid_t; priority: Integer): Integer; cdecl;
  external libdrt name _PU + 'uv_os_setpriority';

function uv_available_parallelism(): Cardinal; cdecl;
  external libdrt name _PU + 'uv_available_parallelism';

function uv_cpu_info(var cpu_infos: Puv_cpu_info_t; var count: Integer): Integer;
  cdecl; external libdrt name _PU + 'uv_cpu_info';

procedure uv_free_cpu_info(cpu_infos: Puv_cpu_info_t; count: Integer); cdecl;
  external libdrt name _PU + 'uv_free_cpu_info';

function uv_interface_addresses(var addresses: Puv_interface_address_t;
  var count: Integer): Integer; cdecl;
  external libdrt name _PU + 'uv_interface_addresses';

procedure uv_free_interface_addresses(addresses: Puv_interface_address_t;
  count: Integer); cdecl;
  external libdrt name _PU + 'uv_free_interface_addresses';

function uv_os_environ(var envitems: Puv_env_item_t; var count: Integer)
  : Integer; cdecl; external libdrt name _PU + 'uv_os_environ';

procedure uv_os_free_environ(envitems: Puv_env_item_t; count: Integer); cdecl;
  external libdrt name _PU + 'uv_os_free_environ';

function uv_os_getenv(const name: PUTF8Char; buffer: PUTF8Char;
  var size: NativeUInt): Integer; cdecl;
  external libdrt name _PU + 'uv_os_getenv';

function uv_os_setenv(const name: PUTF8Char; const Value: PUTF8Char): Integer;
  cdecl; external libdrt name _PU + 'uv_os_setenv';

function uv_os_unsetenv(const name: PUTF8Char): Integer; cdecl;
  external libdrt name _PU + 'uv_os_unsetenv';

function uv_os_gethostname(buffer: PUTF8Char; var size: NativeUInt): Integer;
  cdecl; external libdrt name _PU + 'uv_os_gethostname';

function uv_os_uname(var buffer: uv_utsname_t): Integer; cdecl;
  external libdrt name _PU + 'uv_os_uname';

function uv_metrics_idle_time(var loop: uv_loop_t): UInt64; cdecl;
  external libdrt name _PU + 'uv_metrics_idle_time';

function uv_fs_get_type(const p1: uv_fs_t): uv_fs_type; cdecl;
  external libdrt name _PU + 'uv_fs_get_type';

function uv_fs_get_result(const p1: uv_fs_t): ssize_t; cdecl;
  external libdrt name _PU + 'uv_fs_get_result';

function uv_fs_get_system_error(const p1: uv_fs_t): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_get_system_error';

function uv_fs_get_ptr(const p1: uv_fs_t): Pointer; cdecl;
  external libdrt name _PU + 'uv_fs_get_ptr';

function uv_fs_get_path(const p1: uv_fs_t): PUTF8Char; cdecl;
  external libdrt name _PU + 'uv_fs_get_path';

function uv_fs_get_statbuf(var p1: uv_fs_t): Puv_stat_t; cdecl;
  external libdrt name _PU + 'uv_fs_get_statbuf';

procedure uv_fs_req_cleanup(var req: uv_fs_t); cdecl;
  external libdrt name _PU + 'uv_fs_req_cleanup';

function uv_fs_close(var loop: uv_loop_t; var req: uv_fs_t; &FILE: uv_file;
  cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_close';

function uv_fs_open(var loop: uv_loop_t; var req: uv_fs_t;
  const path: PUTF8Char; flags: Integer; mode: Integer; cb: uv_fs_t.uv_fs_cb)
  : Integer; cdecl; external libdrt name _PU + 'uv_fs_open';

function uv_fs_read(var loop: uv_loop_t; var req: uv_fs_t; &FILE: uv_file;
  bufs: Puv_buf_t; nbufs: Cardinal; Offset: Int64; cb: uv_fs_t.uv_fs_cb)
  : Integer; cdecl; external libdrt name _PU + 'uv_fs_read';

function uv_fs_unlink(var loop: uv_loop_t; var req: uv_fs_t;
  const path: PUTF8Char; cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_unlink';

function uv_fs_write(var loop: uv_loop_t; var req: uv_fs_t; &FILE: uv_file;
  bufs: Puv_buf_t; nbufs: Cardinal; Offset: Int64; cb: uv_fs_t.uv_fs_cb)
  : Integer; cdecl; external libdrt name _PU + 'uv_fs_write';

function uv_fs_copyfile(var loop: uv_loop_t; var req: uv_fs_t;
  const path: PUTF8Char; const new_path: PUTF8Char; flags: Integer;
  cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_copyfile';

function uv_fs_mkdir(var loop: uv_loop_t; var req: uv_fs_t;
  const path: PUTF8Char; mode: Integer; cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_mkdir';

function uv_fs_mkdtemp(var loop: uv_loop_t; var req: uv_fs_t;
  const tpl: PUTF8Char; cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_mkdtemp';

function uv_fs_mkstemp(var loop: uv_loop_t; var req: uv_fs_t;
  const tpl: PUTF8Char; cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_mkstemp';

function uv_fs_rmdir(var loop: uv_loop_t; var req: uv_fs_t;
  const path: PUTF8Char; cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_rmdir';

function uv_fs_scandir(var loop: uv_loop_t; var req: uv_fs_t;
  const path: PUTF8Char; flags: Integer; cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_scandir';

function uv_fs_scandir_next(var req: uv_fs_t; var ent: uv_dirent_t): Integer;
  cdecl; external libdrt name _PU + 'uv_fs_scandir_next';

function uv_fs_opendir(var loop: uv_loop_t; var req: uv_fs_t;
  const path: PUTF8Char; cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_opendir';

function uv_fs_readdir(var loop: uv_loop_t; var req: uv_fs_t; var dir: uv_dir_t;
  cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_readdir';

function uv_fs_closedir(var loop: uv_loop_t; var req: uv_fs_t;
  var dir: uv_dir_t; cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_closedir';

function uv_fs_stat(var loop: uv_loop_t; var req: uv_fs_t;
  const path: PUTF8Char; cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_stat';

function uv_fs_fstat(var loop: uv_loop_t; var req: uv_fs_t; &FILE: uv_file;
  cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_fstat';

function uv_fs_rename(var loop: uv_loop_t; var req: uv_fs_t;
  const path: PUTF8Char; const new_path: PUTF8Char; cb: uv_fs_t.uv_fs_cb)
  : Integer; cdecl; external libdrt name _PU + 'uv_fs_rename';

function uv_fs_fsync(var loop: uv_loop_t; var req: uv_fs_t; &FILE: uv_file;
  cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_fsync';

function uv_fs_fdatasync(var loop: uv_loop_t; var req: uv_fs_t; &FILE: uv_file;
  cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_fdatasync';

function uv_fs_ftruncate(var loop: uv_loop_t; var req: uv_fs_t; &FILE: uv_file;
  Offset: Int64; cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_ftruncate';

function uv_fs_sendfile(var loop: uv_loop_t; var req: uv_fs_t; out_fd: uv_file;
  in_fd: uv_file; in_offset: Int64; length: NativeUInt; cb: uv_fs_t.uv_fs_cb)
  : Integer; cdecl; external libdrt name _PU + 'uv_fs_sendfile';

function uv_fs_access(var loop: Puv_loop_t; var req: uv_fs_t;
  const path: PUTF8Char; mode: Integer; cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_access';

function uv_fs_chmod(var loop: uv_loop_t; var req: uv_fs_t;
  const path: PUTF8Char; mode: Integer; cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_chmod';

function uv_fs_utime(var loop: uv_loop_t; var req: uv_fs_t;
  const path: PUTF8Char; atime: Double; mtime: Double; cb: uv_fs_t.uv_fs_cb)
  : Integer; cdecl; external libdrt name _PU + 'uv_fs_utime';

function uv_fs_futime(var loop: uv_loop_t; var req: uv_fs_t; &FILE: uv_file;
  atime: Double; mtime: Double; cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_futime';

function uv_fs_lutime(var loop: uv_loop_t; var req: uv_fs_t;
  const path: PUTF8Char; atime: Double; mtime: Double; cb: uv_fs_t.uv_fs_cb)
  : Integer; cdecl; external libdrt name _PU + 'uv_fs_lutime';

function uv_fs_lstat(var loop: uv_loop_t; var req: uv_fs_t;
  const path: PUTF8Char; cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_lstat';

function uv_fs_link(var loop: uv_loop_t; var req: uv_fs_t;
  const path: PUTF8Char; const new_path: PUTF8Char; cb: uv_fs_t.uv_fs_cb)
  : Integer; cdecl; external libdrt name _PU + 'uv_fs_link';

function uv_fs_symlink(var loop: uv_loop_t; var req: uv_fs_t;
  const path: PUTF8Char; const new_path: PUTF8Char; flags: Integer;
  cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_symlink';

function uv_fs_readlink(var loop: uv_loop_t; var req: uv_fs_t;
  const path: PUTF8Char; cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_readlink';

function uv_fs_realpath(var loop: uv_loop_t; var req: uv_fs_t;
  const path: PUTF8Char; cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_realpath';

function uv_fs_fchmod(var loop: uv_loop_t; var req: uv_fs_t; &FILE: uv_file;
  mode: Integer; cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_fchmod';

function uv_fs_chown(var loop: uv_loop_t; var req: uv_fs_t;
  const path: PUTF8Char; uid: uv_uid_t; gid: uv_gid_t; cb: uv_fs_t.uv_fs_cb)
  : Integer; cdecl; external libdrt name _PU + 'uv_fs_chown';

function uv_fs_fchown(var loop: uv_loop_t; var req: uv_fs_t; &FILE: uv_file;
  uid: uv_uid_t; gid: uv_gid_t; cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_fchown';

function uv_fs_lchown(var loop: uv_loop_t; var req: uv_fs_t;
  const path: PUTF8Char; uid: uv_uid_t; gid: uv_gid_t; cb: uv_fs_t.uv_fs_cb)
  : Integer; cdecl; external libdrt name _PU + 'uv_fs_lchown';

function uv_fs_statfs(var loop: uv_loop_t; var req: uv_fs_t;
  const path: PUTF8Char; cb: uv_fs_t.uv_fs_cb): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_statfs';

function uv_fs_poll_init(var loop: uv_loop_t; var handle: uv_fs_poll_t)
  : Integer; cdecl; external libdrt name _PU + 'uv_fs_poll_init';

function uv_fs_poll_start(var handle: uv_fs_poll_t;
  poll_cb: uv_fs_poll_t.uv_fs_poll_cb; const path: PUTF8Char;
  interval: Cardinal): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_poll_start';

function uv_fs_poll_stop(var handle: uv_fs_poll_t): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_poll_stop';

function uv_fs_poll_getpath(var handle: uv_fs_poll_t; buffer: PUTF8Char;
  var size: NativeUInt): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_poll_getpath';

function uv_signal_init(var loop: uv_loop_t; handle: Pointer): Integer;
  cdecl; external libdrt name _PU + 'uv_signal_init';

function uv_signal_start(var handle: uv_signal_t;
  signal_cb: uv_signal_t.uv_signal_cb; signum: Integer): Integer; cdecl;
  external libdrt name _PU + 'uv_signal_start';

function uv_signal_start_oneshot(var handle: uv_signal_t;
  signal_cb: uv_signal_t.uv_signal_cb; signum: Integer): Integer; cdecl;
  external libdrt name _PU + 'uv_signal_start_oneshot';

function uv_signal_stop(var handle: uv_signal_t): Integer; cdecl;
  external libdrt name _PU + 'uv_signal_stop';

procedure uv_loadavg(var avg: Double); cdecl;
  external libdrt name _PU + 'uv_loadavg';

function uv_fs_event_init(var loop: uv_loop_t; handle: Pointer)
  : Integer; cdecl; external libdrt name _PU + 'uv_fs_event_init';

function uv_fs_event_start(var handle: uv_fs_event_t;
  cb: uv_fs_event_t.uv_fs_event_cb; const path: PUTF8Char; flags: Cardinal)
  : Integer; cdecl; external libdrt name _PU + 'uv_fs_event_start';

function uv_fs_event_stop(var handle: uv_fs_event_t): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_event_stop';

function uv_fs_event_getpath(var handle: uv_fs_event_t; buffer: PUTF8Char;
  var size: NativeUInt): Integer; cdecl;
  external libdrt name _PU + 'uv_fs_event_getpath';

function uv_ip4_addr(const ip: PUTF8Char; port: Integer; var addr: sockaddr_in)
  : Integer; cdecl; external libdrt name _PU + 'uv_ip4_addr';

function uv_ip6_addr(const ip: PUTF8Char; port: Integer; var addr: sockaddr_in6)
  : Integer; cdecl; external libdrt name _PU + 'uv_ip6_addr';

function uv_ip4_name(const src: sockaddr_in; dst: PUTF8Char; size: NativeUInt)
  : Integer; cdecl; external libdrt name _PU + 'uv_ip4_name';

function uv_ip6_name(const src: sockaddr_in6; dst: PUTF8Char; size: NativeUInt)
  : Integer; cdecl; external libdrt name _PU + 'uv_ip6_name';

function uv_ip_name(const src: SOCKADDR; dst: PUTF8Char; size: NativeUInt)
  : Integer; cdecl; external libdrt name _PU + 'uv_ip_name';

function uv_inet_ntop(af: Integer; const src: Pointer; dst: PUTF8Char;
  size: NativeUInt): Integer; cdecl; external libdrt name _PU + 'uv_inet_ntop';

function uv_inet_pton(af: Integer; const src: PUTF8Char; dst: Pointer): Integer;
  cdecl; external libdrt name _PU + 'uv_inet_pton';

function uv_random(var loop: uv_loop_t; var req: uv_random_t; buf: Pointer;
  buflen: NativeUInt; flags: Cardinal; cb: uv_random_t.uv_random_cb): Integer;
  cdecl; external libdrt name _PU + 'uv_random';

function uv_if_indextoname(ifindex: Cardinal; buffer: PUTF8Char;
  var size: NativeUInt): Integer; cdecl;
  external libdrt name _PU + 'uv_if_indextoname';

function uv_if_indextoiid(ifindex: Cardinal; buffer: PUTF8Char;
  var size: NativeUInt): Integer; cdecl;
  external libdrt name _PU + 'uv_if_indextoiid';

function uv_exepath(buffer: PUTF8Char; var size: NativeUInt): Integer; cdecl;
  external libdrt name _PU + 'uv_exepath';

function uv_cwd(buffer: PUTF8Char; var size: NativeUInt): Integer; cdecl;
  external libdrt name _PU + 'uv_cwd';

function uv_chdir(const dir: PUTF8Char): Integer; cdecl;
  external libdrt name _PU + 'uv_chdir';

function uv_get_free_memory(): UInt64; cdecl;
  external libdrt name _PU + 'uv_get_free_memory';

function uv_get_total_memory(): UInt64; cdecl;
  external libdrt name _PU + 'uv_get_total_memory';

function uv_get_constrained_memory(): UInt64; cdecl;
  external libdrt name _PU + 'uv_get_constrained_memory';

function uv_hrtime(): UInt64; cdecl; external libdrt name _PU + 'uv_hrtime';

procedure uv_sleep(msec: Cardinal); cdecl;
  external libdrt name _PU + 'uv_sleep';

procedure uv_disable_stdio_inheritance(); cdecl;
  external libdrt name _PU + 'uv_disable_stdio_inheritance';

function uv_dlopen(const filename: PUTF8Char; var lib: uv_lib_t): Integer;
  cdecl; external libdrt name _PU + 'uv_dlopen';

procedure uv_dlclose(var lib: uv_lib_t); cdecl;
  external libdrt name _PU + 'uv_dlclose';

function uv_dlsym(var lib: uv_lib_t; const name: PUTF8Char; ptr: PPointer)
  : Integer; cdecl; external libdrt name _PU + 'uv_dlsym';

function uv_dlerror(const lib: uv_lib_t): PUTF8Char; cdecl;
  external libdrt name _PU + 'uv_dlerror';

function uv_mutex_init(var handle: uv_mutex_t): Integer; cdecl;
  external libdrt name _PU + 'uv_mutex_init';

function uv_mutex_init_recursive(var handle: uv_mutex_t): Integer; cdecl;
  external libdrt name _PU + 'uv_mutex_init_recursive';

procedure uv_mutex_destroy(var handle: uv_mutex_t); cdecl;
  external libdrt name _PU + 'uv_mutex_destroy';

procedure uv_mutex_lock(var handle: uv_mutex_t); cdecl;
  external libdrt name _PU + 'uv_mutex_lock';

function uv_mutex_trylock(var handle: uv_mutex_t): Integer; cdecl;
  external libdrt name _PU + 'uv_mutex_trylock';

procedure uv_mutex_unlock(var handle: uv_mutex_t); cdecl;
  external libdrt name _PU + 'uv_mutex_unlock';

function uv_rwlock_init(var rwlock: uv_rwlock_t): Integer; cdecl;
  external libdrt name _PU + 'uv_rwlock_init';

procedure uv_rwlock_destroy(var rwlock: uv_rwlock_t); cdecl;
  external libdrt name _PU + 'uv_rwlock_destroy';

procedure uv_rwlock_rdlock(var rwlock: uv_rwlock_t); cdecl;
  external libdrt name _PU + 'uv_rwlock_rdlock';

function uv_rwlock_tryrdlock(var rwlock: uv_rwlock_t): Integer; cdecl;
  external libdrt name _PU + 'uv_rwlock_tryrdlock';

procedure uv_rwlock_rdunlock(var rwlock: uv_rwlock_t); cdecl;
  external libdrt name _PU + 'uv_rwlock_rdunlock';

procedure uv_rwlock_wrlock(var rwlock: uv_rwlock_t); cdecl;
  external libdrt name _PU + 'uv_rwlock_wrlock';

function uv_rwlock_trywrlock(var rwlock: uv_rwlock_t): Integer; cdecl;
  external libdrt name _PU + 'uv_rwlock_trywrlock';

procedure uv_rwlock_wrunlock(var rwlock: uv_rwlock_t); cdecl;
  external libdrt name _PU + 'uv_rwlock_wrunlock';

function uv_sem_init(var sem: uv_sem_t; Value: Cardinal): Integer; cdecl;
  external libdrt name _PU + 'uv_sem_init';

procedure uv_sem_destroy(var sem: uv_sem_t); cdecl;
  external libdrt name _PU + 'uv_sem_destroy';

procedure uv_sem_post(var sem: uv_sem_t); cdecl;
  external libdrt name _PU + 'uv_sem_post';

procedure uv_sem_wait(var sem: uv_sem_t); cdecl;
  external libdrt name _PU + 'uv_sem_wait';

function uv_sem_trywait(var sem: uv_sem_t): Integer; cdecl;
  external libdrt name _PU + 'uv_sem_trywait';

function uv_cond_init(var cond: uv_cond_t): Integer; cdecl;
  external libdrt name _PU + 'uv_cond_init';

procedure uv_cond_destroy(var cond: uv_cond_t); cdecl;
  external libdrt name _PU + 'uv_cond_destroy';

procedure uv_cond_signal(var cond: uv_cond_t); cdecl;
  external libdrt name _PU + 'uv_cond_signal';

procedure uv_cond_broadcast(var cond: uv_cond_t); cdecl;
  external libdrt name _PU + 'uv_cond_broadcast';

function uv_barrier_init(var barrier: uv_barrier_t; count: Cardinal): Integer;
  cdecl; external libdrt name _PU + 'uv_barrier_init';

procedure uv_barrier_destroy(var barrier: uv_barrier_t); cdecl;
  external libdrt name _PU + 'uv_barrier_destroy';

function uv_barrier_wait(var barrier: uv_barrier_t): Integer; cdecl;
  external libdrt name _PU + 'uv_barrier_wait';

procedure uv_cond_wait(var cond: uv_cond_t; var mutex: uv_mutex_t); cdecl;
  external libdrt name _PU + 'uv_cond_wait';

function uv_cond_timedwait(var cond: uv_cond_t; var mutex: uv_mutex_t;
  Timeout: UInt64): Integer; cdecl;
  external libdrt name _PU + 'uv_cond_timedwait';

type
  uv_once_callback = procedure(); cdecl;
  uv_key_t = Cardinal;
  uv_thread_cb = procedure(arg: Pointer); cdecl;

  uv_thread_options_t = record
    flags: Cardinal;
    stack_size: NativeUInt;
  end;

procedure uv_once(var guard: uv_once_t; callback: uv_once_callback); cdecl;
  external libdrt name _PU + 'uv_once';

function uv_key_create(var key: uv_key_t): Integer; cdecl;
  external libdrt name _PU + 'uv_key_create';

procedure uv_key_delete(var key: uv_key_t); cdecl;
  external libdrt name _PU + 'uv_key_delete';

function uv_key_get(var key: uv_key_t): Pointer; cdecl;
  external libdrt name _PU + 'uv_key_get';

procedure uv_key_set(var key: uv_key_t; Value: Pointer); cdecl;
  external libdrt name _PU + 'uv_key_set';

function uv_gettimeofday(var tv: uv_timeval64_t): Integer; cdecl;
  external libdrt name _PU + 'uv_gettimeofday';

function uv_thread_create(var tid: uv_thread_t; entry: uv_thread_cb;
  arg: Pointer): Integer; cdecl; external libdrt name _PU + 'uv_thread_create';

function uv_thread_create_ex(var tid: uv_thread_t;
  const params: uv_thread_options_t; entry: uv_thread_cb; arg: Pointer)
  : Integer; cdecl; external libdrt name _PU + 'uv_thread_create_ex';

function uv_thread_self(): uv_thread_t; cdecl;
  external libdrt name _PU + 'uv_thread_self';

function uv_thread_join(var tid: uv_thread_t): Integer; cdecl;
  external libdrt name _PU + 'uv_thread_join';

function uv_thread_equal(const t1: uv_thread_t; const t2: uv_thread_t): Integer;
  cdecl; external libdrt name _PU + 'uv_thread_equal';

function uv_loop_get_data(const p1: uv_loop_t): Pointer; cdecl;
  external libdrt name _PU + 'uv_loop_get_data';

procedure uv_loop_set_data(var p1: uv_loop_t; data: Pointer); cdecl;
  external libdrt name _PU + 'uv_loop_set_data';

implementation

end.
