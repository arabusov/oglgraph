program fill_test;

uses
    oglgraph, crt;

const
    gr_driver:  smallint = detect;
    poly: array[1..5] of pointtype = (
        (X: 10; Y: 10),
        (X: 10; Y: 110),
        (X: 60; Y: 100),
        (X: 110; Y: 110),
        (X: 110; Y:10)
    );

var
    gr_mode:    smallint;
    i: integer = 0;

begin
    initgraph(gr_driver, gr_mode, ' ');
    SetColor(Cyan);
    circle(10, 300, 150);
    fillpoly(sizeof(poly) div sizeof(pointtype), poly);
    //SetColor(Cyan);
    //SetTextStyle(GothicFont, HorizDir, 4);
    //OutTextXY(getmaxx div 2 , getmaxy div 2,' press key');
    putpixel(1,1, 0);
    repeat
    putpixel(1,1, 0);
        delay(10); until graphKeyPressed();
    closegraph
end.
