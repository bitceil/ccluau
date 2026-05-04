export type FileHandle = {
    readLine: (self: FileHandle, withTrailing: boolean?) -> string?,
    readAll: (self: FileHandle) -> string?,
    read: (self: FileHandle, count: number?) -> (string | number)?,
    close: (self: FileHandle) -> (),
    write: (self: FileHandle, data: string | number) -> (),
    flush: (self: FileHandle) -> (),
    seek: (self: FileHandle, whence: string?, offset: number?) -> number?,
}
export type CCEvent =
    | { name: "file_transfer", data: {any} }
    | { name: "websocket_failure", data: {any} }
    | { name: "mouse_click", data: {any} }
    | { name: "websocket_closed", data: {any} }
    | { name: "char", data: {any} }
    | { name: "timer", data: {any} }
    | { name: "paste", data: {any} }
    | { name: "speaker_audio_empty", data: {any} }
    | { name: "http_success", data: {any} }
    | { name: "peripheral_detach", data: {any} }
    | { name: "http_failure", data: {any} }
    | { name: "key_up", data: {any} }
    | { name: "computer_command", data: {any} }
    | { name: "key", data: {any} }
    | { name: "rednet_message", data: {any} }
    | { name: "disk", data: {any} }
    | { name: "term_resize", data: {any} }
    | { name: "http_check", data: {any} }
    | { name: "mouse_up", data: {any} }
    | { name: "terminate", data: {any} }
    | { name: "mouse_drag", data: {any} }
    | { name: "task_complete", data: {any} }
    | { name: "turtle_inventory", data: {any} }
    | { name: "peripheral", data: {any} }
    | { name: "mouse_scroll", data: {any} }
    | { name: "alarm", data: {any} }
    | { name: "websocket_message", data: {any} }
    | { name: "websocket_success", data: {any} }
    | { name: "disk_eject", data: {any} }
    | { name: "setting_changed", data: {any} }
    | { name: "monitor_resize", data: {any} }
    | { name: "monitor_touch", data: {any} }
    | { name: "modem_message", data: {any} }
    | { name: "redstone", data: {any} }
export type Vector = {
    x: number,
    y: number,
    z: number,
    add: (self: Vector, other: Vector) -> Vector,
    sub: (self: Vector, other: Vector) -> Vector,
    mul: (self: Vector, m: number) -> Vector,
    div: (self: Vector, m: number) -> Vector,
    unm: (self: Vector) -> Vector,
    dot: (self: Vector, other: Vector) -> number,
    cross: (self: Vector, other: Vector) -> Vector,
    length: (self: Vector) -> number,
    normalize: (self: Vector) -> Vector,
    round: (self: Vector) -> Vector,
    tostring: (self: Vector) -> string,
}
export type Buffer = {
    size: number,
    data: string,
}
declare function sleep(time: number?): ()
declare function write(text: string): number
declare function print(...: any): number
declare function printError(...: any): ()
declare function read(replaceChar: string?, history: {string}?, completeFn: ((string) -> {string})?, default: string?): string
declare function load(ld: string | (() -> string?), source: string?, mode: string?, env: {}?): (any?, string?)
declare function loadfile(filename: string?, mode: string?, env: {}?): (any?, string?)
declare _HOST: string
declare _CC_DEFAULT_SETTINGS: string
declare _CC_DISABLE_LUA51_FEATURES: boolean?
declare function rawlen(v: any): number
declare function unpack(t: {any}, i: number?, j: number?): ...any
declare term: {
    write: (text: string) -> (),
    blit: (text: string, textColor: string, backgroundColor: string) -> (),
    clear: () -> (),
    clearLine: () -> (),
    getCursorPos: () -> (number, number),
    setCursorPos: (x: number, y: number) -> (),
    getCursorBlink: () -> boolean,
    setCursorBlink: (blink: boolean) -> (),
    isColor: () -> boolean,
    isColour: () -> boolean,
    getSize: () -> (number, number),
    scroll: (n: number) -> (),
    setTextColor: (color: number) -> (),
    setTextColour: (color: number) -> (),
    getTextColor: () -> number,
    getTextColour: () -> number,
    setBackgroundColor: (color: number) -> (),
    setBackgroundColour: (color: number) -> (),
    getBackgroundColor: () -> number,
    getBackgroundColour: () -> number,
    setPaletteColor: (color: number, r: number, g: number, b: number) -> (),
    setPaletteColour: (color: number, r: number, g: number, b: number) -> (),
    getPaletteColor: (color: number) -> (number, number, number),
    getPaletteColour: (color: number) -> (number, number, number),
    nativePaletteColor: (color: number) -> (number, number, number),
    nativePaletteColour: (color: number) -> (number, number, number),
    redirect: (target: any) -> any,
    current: () -> any,
    native: () -> any,
}
declare fs: {
    list: (path: string) -> {string},
    exists: (path: string) -> boolean,
    isDir: (path: string) -> boolean,
    isReadOnly: (path: string) -> boolean,
    getName: (path: string) -> string,
    getDir: (path: string) -> string,
    getSize: (path: string) -> number,
    getDrive: (path: string) -> string?,
    getFreeSpace: (path: string) -> number,
    getCapacity: (path: string) -> number?,
    makeDir: (path: string) -> (),
    move: (from: string, to: string) -> (),
    copy: (from: string, to: string) -> (),
    delete: (path: string) -> (),
    combine: (path: string, ...string) -> string,
    open: (path: string, mode: string) -> FileHandle?,
    find: (wildcard: string) -> {string},
    isDriveRoot: (path: string) -> boolean,
    complete: (path: string, location: string, include_files: boolean?, include_dirs: boolean?) -> {string},
    attributes: (path: string) -> {
        size: number,
        isDir: boolean,
        isReadOnly: boolean,
        created: number,
        modified: number,
    },
}
declare os: {
    getComputerID: () -> number,
    getComputerLabel: () -> string?,
    setComputerLabel: (label: string?) -> (),
    run: (env: {}, path: string, ...any) -> boolean,
    version: () -> string,
    sleep: (time: number) -> (),
    startTimer: (timeout: number) -> number,
    setAlarm: (time: number) -> number,
    cancelTimer: (id: number) -> (),
    cancelAlarm: (id: number) -> (),
    epoch: (kind: string?) -> number,
    day: (kind: string?) -> number,
    time: (kind: string?) -> number,
    clock: () -> number,
    loadAPI: (path: string) -> boolean,
    unloadAPI: (name: string) -> (),
    pullEvent: (filter: string?) -> (string, ...any),
    pullEventRaw: (filter: string?) -> (string, ...any),
    queueEvent: (name: string, ...any) -> (),
    time: (t: {year: number, month: number, day: number, hour: number?, min: number?, sec: number?, isdst: boolean?}?) -> number,
    shutdown: () -> (),
    reboot: () -> (),
}
declare turtle: {
    craft: (limit: number?) -> (boolean, string?),
    forward: () -> boolean,
    back: () -> boolean,
    up: () -> boolean,
    down: () -> boolean,
    turnLeft: () -> boolean,
    turnRight: () -> boolean,
    select: (slot: number) -> boolean,
    getSelectedSlot: () -> number,
    getItemCount: (slot: number?) -> number,
    getItemSpace: (slot: number?) -> number,
    getItemDetail: (slot: number?, detailed: boolean?) -> any,
    equipLeft: () -> boolean,
    equipRight: () -> boolean,
    attack: (side: TurtleSide?) -> boolean,
    attackUp: () -> boolean,
    attackDown: () -> boolean,
    dig: (side: TurtleSide?) -> boolean,
    digUp: () -> boolean,
    digDown: () -> boolean,
    place: (text: string?) -> boolean,
    placeUp: (text: string?) -> boolean,
    placeDown: (text: string?) -> boolean,
    detect: () -> boolean,
    detectUp: () -> boolean,
    detectDown: () -> boolean,
    inspect: () -> (boolean, any),
    inspectUp: () -> (boolean, any),
    inspectDown: () -> (boolean, any),
    compare: () -> boolean,
    compareUp: () -> boolean,
    compareDown: () -> boolean,
    compareTo: (slot: number) -> boolean,
    drop: (count: number?) -> boolean,
    dropUp: (count: number?) -> boolean,
    dropDown: (count: number?) -> boolean,
    suck: (count: number?) -> boolean,
    suckUp: () -> boolean,
    suckDown: () -> boolean,
    refuel: (count: number?) -> boolean,
    getFuelLevel: () -> (number | "unlimited"),
    getFuelLimit: () -> (number | "unlimited"),
    transferTo: (slot: number, count: number?) -> boolean,
}
declare redstone: {
    getSides: () -> {Side},
    setInput: (side: Side, value: boolean) -> (),
    getInput: (side: Side) -> boolean,
    setOutput: (side: Side, value: boolean) -> (),
    getOutput: (side: Side) -> boolean,
    setAnalogOutput: (side: Side, value: number) -> (),
    getAnalogOutput: (side: Side) -> number,
    getAnalogInput: (side: Side) -> number,
    setBundledOutput: (side: Side, value: number) -> (),
    getBundledOutput: (side: Side) -> number,
    getBundledInput: (side: Side) -> number,
    testBundledInput: (side: Side, mask: number) -> boolean,
}
declare rs: typeof(redstone)
declare peripheral: {
    getNames: () -> {string},
    isPresent: (name: Side | string) -> boolean,
    getType: (name: Side | string) -> string?,
    hasType: (name: Side | string, type: string) -> boolean?,
    getMethods: (name: Side | string) -> {string}?,
    getName: (peripheral: any) -> string?,
    call: (name: Side | string, method: string, ...any) -> ...any,
    wrap: (name: Side | string) -> any,
    find: (type: string, filter: ((name: string, wrapped: any) -> boolean)?) -> ...any,
}
declare window: {
    create: (parent: any, x: number, y: number, width: number, height: number, visible: boolean?) -> any,
}
declare http: {
    get: (url: string, headers: {[string]: string}?, binary: boolean?) -> any,
    post: (url: string, body: string?, headers: {[string]: string}?, binary: boolean?) -> any,
    request: (url: string, body: string?, headers: {[string]: string}?, binary: boolean?, method: string?) -> (),
    checkURLAsync: (url: string) -> (),
    checkURL: (url: string) -> (boolean, string?),
    websocketAsync: (url: string, headers: {[string]: string}?) -> (),
    websocket: (url: string, headers: {[string]: string}?) -> (any, string?),
}
declare vector: {
    new: (x: number, y: number, z: number) -> Vector,
    create: (x: number, y: number, z: number) -> Vector,
    magnitude: (v: Vector) -> number,
    normalize: (v: Vector) -> Vector,
}
declare keys: {
    getName: (code: number) -> string?,
    [string]: number,
}
declare shell: {
    exit: () -> (),
    dir: () -> string,
    setDir: (path: string) -> (),
    path: () -> string,
    setPath: (path: string) -> (),
    resolve: (path: string) -> string,
    resolveProgram: (name: string) -> string?,
    programs: (include_hidden: boolean?) -> {string},
    aliases: () -> {[string]: string},
    setAlias: (alias: string, program: string) -> (),
    clearAlias: (alias: string) -> (),
    getAlias: (alias: string) -> string?,
    run: (program: string, ...string) -> boolean,
    execute: (program: string, ...string) -> boolean,
    openTab: (program: string, ...string) -> number,
    switchTab: (id: number) -> (),
    complete: (prefix: string) -> {string},
    completeProgram: (prefix: string) -> {string},
    setCompletionFunction: (path: string, func: (shell: {}, index: number, text: string, previous: {string}) -> {string}?) -> (),
    getCompletionFunctions: () -> {[string]: any},
}
declare multishell: {
    getFocus: () -> number,
    setFocus: (id: number) -> (),
    getTitle: (id: number) -> string?,
    setTitle: (id: number, title: string) -> (),
    getCurrent: () -> number,
    launch: (env: {}, path: string, ...string) -> number,
    getCount: () -> number,
    terminate: (id: number) -> (),
}
declare parallel: {
    waitForAny: (...() -> ()) -> number,
    waitForAll: (...() -> ()) -> (),
}
declare textutils: {
    slowWrite: (text: string, rate: number?) -> (),
    slowPrint: (text: string, rate: number?) -> (),
    formatTime: (time: number, twentyFourHour: boolean?) -> string,
    pagedPrint: (text: string, freeLines: number?) -> number,
    tabulate: (...any) -> (),
    pagedTabulate: (...any) -> (),
    serialize: (data: any, options: {compact: boolean?, allow_cycles: boolean?}?) -> string,
    unserialize: (data: string) -> any,
    serializeJSON: (data: any, nBTStyle: boolean?) -> string,
    unserializeJSON: (data: string, options: {parse_null: boolean?, parse_empty_array: boolean?}?) -> any,
    urlEncode: (text: string) -> string,
    complete: (text: string, options: {string}?) -> {string},
}
declare colors: {
    white: number,
    orange: number,
    magenta: number,
    lightBlue: number,
    yellow: number,
    lime: number,
    pink: number,
    gray: number,
    lightGray: number,
    cyan: number,
    purple: number,
    blue: number,
    brown: number,
    green: number,
    red: number,
    black: number,
    combine: (...number) -> number,
    subtract: (colors: number, ...number) -> number,
    test: (colors: number, color: number) -> boolean,
    packRGB: (r: number, g: number, b: number) -> number,
    unpackRGB: (rgb: number) -> (number, number, number),
    rgb8: (r: number, g: number, b: number) -> number,
    toBlit: (color: number) -> string,
    fromBlit: (char: string) -> number,
}
declare colours: typeof(colors)
declare commands: {
    exec: (command: string) -> (boolean, {string}, number?),
    async: (command: string) -> number,
    list: () -> {string},
    getBlockPosition: () -> (number, number, number),
    getBlockInfo: (x: number, y: number, z: number) -> any,
    getBlockInfos: (x1: number, y1: number, z1: number, x2: number, y2: number, z2: number) -> {any},
}
declare help: {
    path: () -> string,
    setPath: (path: string) -> (),
    lookup: (topic: string) -> string?,
    topics: () -> {string},
    complete: (prefix: string) -> {string},
}
declare gps: {
    CHANNEL_GPS: number,
    locate: (timeout: number?, debug: boolean?) -> (number, number, number)?,
}
declare rednet: {
    CHANNEL_BROADCAST: number,
    CHANNEL_REPEAT: number,
    open: (modem: string) -> (),
    close: (modem: string?) -> (),
    isOpen: (modem: string?) -> boolean,
    send: (recipient: number, message: any, protocol: string?) -> (),
    broadcast: (message: any, protocol: string?) -> (),
    receive: (protocol: string?, timeout: number?) -> (number?, any?, string?),
    host: (protocol: string, hostname: string) -> (),
    unhost: (protocol: string, hostname: string?) -> (),
    lookup: (protocol: string, hostname: string?) -> (number | {number}?),
    run: () -> (),
}
declare settings: {
    set: (name: string, value: any) -> (),
    get: (name: string, default: any?) -> any,
    unset: (name: string) -> (),
    clear: () -> (),
    getNames: () -> {string},
    load: (path: string?) -> boolean,
    save: (path: string?) -> boolean,
}
declare paintutils: {
    parseImage: (image: string) -> any,
    loadImage: (path: string) -> any,
    drawPixel: (x: number, y: number, color: number?) -> (),
    drawLine: (startX: number, startY: number, endX: number, endY: number, color: number?) -> (),
    drawBox: (startX: number, startY: number, endX: number, endY: number, color: number?) -> (),
    drawFilledBox: (startX: number, startY: number, endX: number, endY: number, color: number?) -> (),
    drawImage: (image: any, x: number, y: number) -> (),
}
declare buffer: {
    create: (size: number) -> Buffer,
    fromstring: (str: string) -> Buffer,
    size: (b: Buffer) -> number,
    readi8: (b: Buffer, offset: number) -> number,
    readu8: (b: Buffer, offset: number) -> number,
    readi16: (b: Buffer, offset: number) -> number,
    readu16: (b: Buffer, offset: number) -> number,
    readi32: (b: Buffer, offset: number) -> number,
    readu32: (b: Buffer, offset: number) -> number,
    readf32: (b: Buffer, offset: number) -> number,
    readf64: (b: Buffer, offset: number) -> number,
    writei8: (b: Buffer, offset: number, val: number) -> (),
    writeu8: (b: Buffer, offset: number, val: number) -> (),
    writei16: (b: Buffer, offset: number, val: number) -> (),
    writeu16: (b: Buffer, offset: number, val: number) -> (),
    writei32: (b: Buffer, offset: number, val: number) -> (),
    writeu32: (b: Buffer, offset: number, val: number) -> (),
    writef32: (b: Buffer, offset: number, val: number) -> (),
    writef64: (b: Buffer, offset: number, val: number) -> (),
    readstring: (b: Buffer, offset: number, count: number) -> string,
    writestring: (b: Buffer, offset: number, str: string, count: number?) -> (),
    copy: (target: Buffer, targetOffset: number, source: Buffer, sourceOffset: number?, count: number?) -> (),
    fill: (b: Buffer, offset: number, val: number, count: number?) -> (),
}
export type Side = "left" | "right" | "top" | "bottom" | "front" | "back"
export type TurtleSide = "left" | "right"
export type Color = number
declare task: {
    spawn: (f: ((...any) -> ...any) | any, ...any) -> any,
    cancel: (thread: any) -> (),
    wait: (duration: number?) -> (),
    delay: (duration: number, f: (...any) -> ...any, ...any) -> any,
    defer: (f: (...any) -> ...any, ...any) -> any,
}
declare math: {
    abs: (x: number) -> number,
    acos: (x: number) -> number,
    asin: (x: number) -> number,
    atan: (x: number, y: number?) -> number,
    atan2: (y: number, x: number) -> number,
    ceil: (x: number) -> number,
    cos: (x: number) -> number,
    cosh: (x: number) -> number,
    deg: (x: number) -> number,
    exp: (x: number) -> number,
    floor: (x: number) -> number,
    fmod: (x: number, y: number) -> number,
    frexp: (x: number) -> (number, number),
    ldexp: (m: number, e: number) -> number,
    log: (x: number, base: number?) -> number,
    max: (x: number, ...number) -> number,
    min: (x: number, ...number) -> number,
    modf: (x: number) -> (number, number),
    pow: (x: number, y: number) -> number,
    rad: (x: number) -> number,
    random: (m: (number | any)?, n: number?) -> number,
    randomseed: (x: number) -> (),
    sin: (x: number) -> number,
    sinh: (x: number) -> number,
    sqrt: (x: number) -> number,
    tan: (x: number) -> number,
    tanh: (x: number) -> number,
    pi: number,
    huge: number,
    clamp: (n: number, min: number, max: number) -> number,
    round: (n: number) -> number,
    sign: (n: number) -> number,
    noise: (x: number, y: number?, z: number?) -> number,
    log: (x: number, base: number?) -> number,
    atan: (y: number, x: number?) -> number,
}
declare table: {
    concat: (t: {any}, sep: string?, i: number?, j: number?) -> string,
    insert: (t: {any}, pos: (number | any), val: any?) -> (),
    remove: (t: {any}, pos: number?) -> any,
    sort: (t: {any}, comp: ((any, any) -> boolean)?) -> (),
    unpack: (t: {any}, i: number?, j: number?) -> ...any,
    pack: (...any) -> {n: number, [number]: any},
    move: (a1: {any}, f: number, e: number, t: number, a2: {any}?) -> {any},
    find: (t: {any}, val: any, init: number?) -> number?,
    clear: (t: {any}) -> (),
    clone: <T>(t: T) -> T,
    create: (size: number, val: any?) -> {any},
    freeze: <T>(t: T) -> T,
    isfrozen: (t: {any}) -> boolean,
}
declare string: {
    byte: (s: string, i: number?, j: number?) -> ...number,
    char: (...number) -> string,
    dump: (f: (...any) -> ...any) -> string,
    find: (s: string, pattern: string, init: number?, plain: boolean?) -> (number, number, ...any),
    format: (formatstring: string, ...any) -> string,
    gmatch: (s: string, pattern: string) -> () -> ...string,
    gsub: (s: string, pattern: string, repl: (string | {} | ((...string) -> string)), n: number?) -> (string, number),
    len: (s: string) -> number,
    lower: (s: string) -> string,
    match: (s: string, pattern: string, init: number?) -> ...any,
    rep: (s: string, n: number, sep: string?) -> string,
    reverse: (s: string) -> string,
    sub: (s: string, i: number, j: number?) -> string,
    upper: (s: string) -> string,
    pack: (fmt: string, ...any) -> string,
    unpack: (fmt: string, s: string, pos: number?) -> ...any,
    packsize: (fmt: string) -> number,
    split: (s: string, sep: string?) -> {string},
}
declare bit32: {
    band: (...number) -> number,
    bor: (...number) -> number,
    bxor: (...number) -> number,
    bnot: (x: number) -> number,
    lshift: (x: number, disp: number) -> number,
    rshift: (x: number, disp: number) -> number,
    arshift: (x: number, disp: number) -> number,
    lrotate: (x: number, disp: number) -> number,
    rrotate: (x: number, disp: number) -> number,
    extract: (n: number, field: number, width: number?) -> number,
    replace: (n: number, v: number, field: number, width: number?) -> number,
    btest: (...number) -> boolean,
    countlz: (n: number) -> number,
    countrz: (n: number) -> number,
}
declare cc: {
    audio: {
        dfpwm: {
            make_decoder: () -> ((data: string) -> {number}),
            make_encoder: () -> ((data: {number}) -> string),
            encode: (data: {number}) -> string,
            decode: (data: string) -> {number},
        }
    },
    completion: {
        choice: (text: string, choices: {string}) -> {string},
        peripheral: (text: string) -> {string},
        side: (text: string) -> {string},
        setting: (text: string) -> {string},
        command: (text: string) -> {string},
        program: (text: string) -> {string},
        dir: (text: string) -> {string},
        file: (text: string) -> {string},
        dirOrFile: (text: string) -> {string},
    },
    expect: {
        expect: (value: any, index: number, ...string) -> any,
        field: (table: {}, name: string, ...string) -> any,
        range: (value: number, min: number?, max: number?) -> number,
    },
    image: {
        nft: {
            parse: (image: string) -> any,
            load: (path: string) -> any,
        }
    },
    pretty: {
        print: (doc: any, ribbon_width: number?) -> (),
        render: (doc: any, ribbon_width: number?) -> string,
        display: (doc: any, ribbon_width: number?) -> (),
        empty: any,
        space: any,
        line: any,
        text: (text: string, color: number?) -> any,
        group: (doc: any) -> any,
        nest: (indent: number, doc: any) -> any,
        sep: (docs: {any}) -> any,
        concat: (docs: {any}) -> any,
    }
}
declare utf8: {
    char: (...number) -> string,
    charpattern: string,
    codes: (s: string) -> (() -> (number, number)),
    codepoint: (s: string, i: number?, j: number?) -> ...number,
    len: (s: string, i: number?, j: number?) -> (number?, number?),
    offset: (s: string, n: number, i: number?) -> number?,
}
declare package: {
    config: string,
    cpath: string,
    loaded: {[string]: any},
    loaders: {(name: string) -> (any?, string?)},
    path: string,
    preload: {[string]: (name: string) -> any},
    searchpath: (name: string, path: string, sep: string?, rep: string?) -> string?,
    seeall: (module: {}) -> (),
}
declare coroutine: {
    create: (f: (...any) -> ...any) -> any,
    resume: (co: any, ...any) -> (boolean, ...any),
    running: () -> (any, boolean),
    status: (co: any) -> string,
    wrap: (f: (...any) -> ...any) -> (...any) -> ...any,
    yield: (...any) -> ...any,
    isyieldable: () -> boolean,
}
declare debug: {
    getinfo: (thread: any?, f: (any | number), what: string?) -> {
        source: string,
        short_src: string,
        linedefined: number,
        lastlinedefined: number,
        what: string,
        currentline: number,
        name: string,
        namewhat: string,
        nups: number,
        nparams: number,
        isvararg: boolean,
        func: (...any) -> ...any,
    }?,
    getlocal: (thread: any?, level: number, index: number) -> (string, any),
    getupvalue: (f: (...any) -> ...any, up: number) -> (string, any),
    setlocal: (thread: any?, level: number, index: number, value: any) -> string,
    setupvalue: (f: (...any) -> ...any, up: number, value: any) -> string,
    upvalueid: (f: (...any) -> ...any, n: number) -> any,
    upvaluejoin: (f1: (...any) -> ...any, n1: number, f2: (...any) -> ...any, n2: number) -> (),
    traceback: (thread: any?, message: string?, level: number?) -> string,
}
