program fill_test;

uses
    oglgraph, crt;

const
    gr_driver:  smallint = detect;
    poly: array[1..5] of pointtype = (
        (X: 10; Y: 10),
        (X: 10; Y: 110),
        (X: 60; Y: 1),
        (X: 110; Y: 110),
        (X: 110; Y:10)
    );

var
    gr_mode:    smallint;
    i: integer = 0;

begin
    initgraph(gr_driver, gr_mode, ' ');
    SetColor(Cyan);
    fillpoly(sizeof(poly) div sizeof(pointtype), poly);
    repeat
        delay(10); until graphKeyPressed();
    closegraph
end.
