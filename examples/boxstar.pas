program boxstar;

uses oglgraph, crt;

const
    gr_driver: smallint = detect;

var 
    gr_mode: smallint;

procedure stop;
begin
    repeat
        delay(100);
    until graphkeypressed;
end;

procedure star(x, y, r: integer);
var
    r2: integer;
begin
    if r > 1 then
    begin
        r2 := r div 2;
        star(x - r, y + r, r2);
        star(x + r, y + r, r2);
        star(x - r, y - r, r2);
        star(x + r, y - r, r2);
        rectangle(x - r2, y - r2, x + r2, y + r2);
    end;
end;

begin
    initgraph(gr_driver, gr_mode, ' ');
    setcolor(Cyan);
    star(getmaxy div 2, getmaxy div 2, getmaxy div 4);
    stop;
    closegraph
end.
