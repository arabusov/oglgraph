program cube;

uses oglgraph, crt;

const
    gr_driver: smallint = detect;

var
    gr_mode: smallint;

procedure stop;
begin
    repeat
        delay(100)
    until graphKeyPressed;
end;

type
    vector = array [0..2] of real;

function projx(x, z: real): real;
begin
    projx := x/z
end;

procedure proj(coord: vector; var a, b: real);
begin
    a := projx(coord[0], coord[2]);
    b := projx(coord[1], coord[2])
end;

const
    vsign: array [0..7,0..2] of integer = (
    (-1, -1, -1),
    (1, -1, -1),
    (1, 1, -1),
    (-1, 1, -1),
    (-1, -1, 1),
    (1, -1, 1),
    (1, 1, 1),
    (-1, 1, 1));

procedure basecube(center: vector; a: real);
var
    i, j: integer;
    px, py: real;
    buf: array [0..7, 0..1] of integer;
    arg: vector;
begin
    for i := 0 to 7 do begin
        for j := 0 to 2 do begin
            arg [j] := center[j] + vsign[i][j]*a/2.;
        end;
        for j := 0 to 2 do begin
            proj(arg, px, py);
            buf [i][0] := round((px + 1.0)/2.0*getmaxx);
            buf [i][1] := round((py + 1.0)/2.0*getmaxy)
        end
    end;
    j := 1;
    for i := 0 to 2 do begin
        line(buf[i][0], buf[i][1], buf[i+1][0], buf[i+1][1]);
        line(buf[i+4][0], buf[i+4][1], buf[i+5][0], buf[i+5][1]);
    end;
    line(buf[3][0], buf[3][1], buf[0][0], buf[0][1]);
    line(buf[4+3][0], buf[4+3][1], buf[4][0], buf[4][1]);
    for i := 0 to 3 do begin
        line(buf[i][0], buf[i][1], buf[i+4][0], buf[i+4][1]);
    end
end;

var
    x, y: integer;
    center: vector = (-0.9, 0, 6.0);
begin
    initgraph(gr_driver, gr_mode, ' ');
    setcolor(Cyan);
    rectangle(1, 1, GetMaxX, GetMaxY);
    repeat
        setcolor(Magenta);
        basecube(center, 1.0);
        delay(10);
        setcolor(Black);
        basecube(center, 1.0);
        center[2] := center[2] - 0.01;
        if center[2] < 2.1 then
            center[2] := 6.0
    until graphkeypressed;
    closegraph
end.
