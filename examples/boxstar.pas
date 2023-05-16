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

procedure star(x, y, r, c: integer);
var
    r2, i: integer;
    ph: real;
begin
    ph := 72./180.*pi;
    if r > 1 then
    begin
        r2 := r div 2;
        for i := 0 to 4 do
            star(round(x + cos(i*ph+c*ph/2)*r), round(y + sin(i*ph+c*ph/2)*r), r2, c+1);
        setcolor(c);
        {circle(x, y, r2);}
        rectangle(x - r2, y - r2, x + r2, y + r2);
    end;
end;

begin
    initgraph(gr_driver, gr_mode, ' ');
    star(getmaxy div 2, getmaxy div 2, getmaxy div 4, 1);
    stop;
    closegraph
end.
