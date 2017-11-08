program pr1;

{$mode objfpc}{$H+}

uses
  oglgraph, crt;
const ESCKey = {$IFDEF WIN32}27{$ELSE}9{$ENDIF};
      SpaceKey = {$IFDEF WIN32}32{$ELSE}65{$ENDIF};
      EnterKey = {$IFDEF WIN32}13{$ELSE}36{$ENDIF};
var gd, gm : smallint;
    i,dx,dy : integer;
    key : word;


procedure putlines(i1,i2,dx,dy : integer);
const sh=5;
var i,n : integer;
	s : string;
begin
   n:=0;
   for i:=i1 to i2 do
   begin
	 inc(n);
     setcolor(i);
     line(dx+30,n*sh+dy,dx+200,n*sh+dy);
	 if (i=i1) or (i=i2) or (n mod 24 =0) then
		begin
			str(i,s);
			setcolor(15);
			outtextxy(dx,n*sh+dy,s);
			str(n,s);
			setcolor(15);
			outtextxy(dx+210,n*sh+dy,s);
		end;
   end;
end;

procedure DrawLines;
  begin
   putlines(0,15,0,15);
   putlines(16,31,0,110);
   putlines(32,103,0,210);
   putlines(104,175,300,210);
   putlines(176,247,600,210);
   putlines(248,255,450,35);
  end;

procedure DrawPatternLines;
  var lt : integer;
  begin
    SetLineStyle(SolidLn, 0, NormWidth);
    Line(10,30,100,30);
    SetLineStyle(SolidLn, 0, ThickWidth);
    Line(110,30,200,30);

    SetLineStyle(DottedLn, 0, NormWidth);    //$cccc
    Line(10,40,100,40);
    SetLineStyle(DottedLn, 0, ThickWidth);
    Line(110,40,200,40);

    SetLineStyle(CenterLn, 0, NormWidth);   // $fe38
    Line(10,50,100,50);
    SetLineStyle(CenterLn, 0, ThickWidth);
    Line(110,50,200,50);


    SetLineStyle(DashedLn, 0, NormWidth);  // $f8f8
    Line(10,60,100,60);
    SetLineStyle(DashedLn, 0, ThickWidth);
    Line(110,60,200,60);

    SetLineStyle(UserBitLn, $f8f8, NormWidth);
    Line(10,70,100,70);
    SetLineStyle(UserBitLn, $f8f8, ThickWidth);
    Line(110,70,200,70);

  end;

procedure DrawFill;
  begin
     setcolor(white);
     circle(400,50,50);
     SetFillStyle(EmptyFill,1);
     bar(0,0,100,50);
     bar3d(0,60,100,110,4,true);
     FillEllipse(550,50,50,50);

     SetFillStyle(SolidFill,2);
     bar(100,0,200,50);
     bar3d(100,60,200,110,4,true);
     FillEllipse(650,50,50,50);

     SetFillStyle(LineFill,3);
     bar(200,0,300,50);
     bar3d(200,60,300,110,4,true);
     FillEllipse(750,50,50,50);

     SetFillStyle(LtSlashFill,4);
     bar(0,150,100,200);
     bar3d(0,210,100,260,4,true);
     FillEllipse(550, 200, 50,50);

     SetFillStyle(SlashFill,5);
     bar(100,150,200,200);
     bar3d(100,210,200,260,4,true);
     FillEllipse(650, 200, 50,50);

     SetFillStyle(BkSlashFill,6);
     bar(200,150,300,200);
     bar3d(200,210,300,260,4,true);
     FillEllipse(750, 200, 50,50);

     SetFillStyle(LtBkSlashFill,7);
     bar(300,150,400,200);
     bar3d(300,210,400,260,4,true);
     FillEllipse(850, 200, 50,50);

     SetFillStyle(HatchFill,8);
     bar(0,300,100,350);
     bar3d(0,360,100,410,4,true);
     FillEllipse(550, 300, 50,50);

     SetFillStyle(XHatchFill,9);
     bar(100,300,200,350);
     bar3d(100,360,200,410,4,true);
     FillEllipse(650, 300, 50,50);

     SetFillStyle(InterleaveFill,10);
     bar(200,300,300,350);
     bar3d(200,360,300,410,4,true);
     FillEllipse(750, 300, 50,50);

     SetFillStyle(WideDotFill,11);
     bar(300,300,400,350);
     bar3d(300,360,400,410,4,true);
     FillEllipse(850, 300, 50,50);

     SetFillStyle(CloseDotFill,12);
     bar(400,300,500,350);
     bar3d(400,360,500,410,4,true);
     FillEllipse(950, 300, 50,50);


     SetTextStyle(0,0,8);
     setcolor(Magenta);
     OutTextXY(100,500,'Hello world!');
     SetTextStyle(0,0,2);
     OutTextXY(100,600,'Press Enter or Space or ESC');

  end;

procedure DrawFillSector;
  begin
     setcolor(white);
     circle(400,50,50);
     SetFillStyle(EmptyFill,1);
     bar(0,0,100,50);
     bar3d(0,60,100,110,4,true);
     sector(550,50,90,360,50,50);

     SetFillStyle(SolidFill,2);
     bar(100,0,200,50);
     bar3d(100,60,200,110,4,true);
     sector(650,50,90,360,50,50);

     SetFillStyle(LineFill,3);
     bar(200,0,300,50);
     bar3d(200,60,300,110,4,true);
     Sector(750,52,10,70,50,50);

     SetFillStyle(LtSlashFill,4);
     bar(0,150,100,200);
     bar3d(0,210,100,260,4,true);
     Sector(550, 200, 30,150,50,50);

     SetFillStyle(SlashFill,5);
     bar(100,150,200,200);
     bar3d(100,210,200,260,4,true);
     Sector(650, 200,100,170, 50,50);

     SetFillStyle(BkSlashFill,6);
     bar(200,150,300,200);
     bar3d(200,210,300,260,4,true);
     Sector(750, 200,100,240, 50,50);

     SetFillStyle(LtBkSlashFill,7);
     bar(300,150,400,200);
     bar3d(300,210,400,260,4,true);
     Sector(850, 200,200,350, 50,50);

     SetFillStyle(HatchFill,8);
     bar(0,300,100,350);
     bar3d(0,360,100,410,4,true);
     Sector(550, 300,190,260, 50,50);

     SetFillStyle(XHatchFill,9);
     bar(100,300,200,350);
     bar3d(100,360,200,410,4,true);
     Sector(650, 300,5,273, 50,50);

     SetFillStyle(InterleaveFill,10);
     bar(200,300,300,350);
     bar3d(200,360,300,410,4,true);
     Sector(750, 300,260,340, 50,50);

     SetFillStyle(WideDotFill,11);
     bar(300,300,400,350);
     bar3d(300,360,400,410,4,true);
     Sector(850, 300,30,280, 50,50);

     SetFillStyle(CloseDotFill,12);
     bar(400,300,500,350);
     bar3d(400,360,500,410,4,true);
     Sector(950, 300,30,350, 50,50);


     SetTextStyle(0,0,8);
     setcolor(Magenta);
     OutTextXY(100,500,'Hello world!');
     SetTextStyle(0,0,2);
     OutTextXY(100,600,'Press Enter or Space or ESC');
     OutTextXY(100,700,'АБВГДЕЁЖЗИКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ');
     OutTextXY(100,800,'абвгдеёжзиклмнопрстуфхцчшщъыьэюя');

  end;


begin
// gd:=VESA;
// gm:=VGAHi;
  gd:=detect;
  gm:=detectmode;
 initgraph(gd,gm,'');
 writeln('GraphResult = ',graphresult);
// setbkcolor(white);
// clearviewport;
{
     SetFillStyle(SlashFill,5);
     Sector(550, 300,30,230, 50,50);
     Sector(650, 200,230,30, 50,50);
     repeat      
     SetFillStyle(random(8)+1,random(14)+1);
     bar(0,0,600,650);
     delay(100); until graphKeyPressed();
     closeGraph();
     exit;
}

// DrawFill;
 DrawFillSector;
// DrawLines;
// DrawPatternLines;



 key:=graphReadKey;
 writeln(key);
 while key<>ESCKey do // ESC Key
   begin
     if graphKeyPressed then
       key:=graphReadKey;
     if key=EnterKey then  // Enter Key
       begin
         key:=0;
         SetDoubleBuffer(true);
         dx:=0;
         dy:=600;
         while (dx<GetMaxX) and (key<>ESCKey) do
           begin
             clearviewport;
             DrawFillSector;
             setcolor(red);
             SetFillStyle(XHatchFill,green);
             FillEllipse(dx,dy,50,50);
             graphSwapBuffers;
             dx:=dx+1;
             if graphKeyPressed then
               key:=graphReadKey;
           end;
         key:=0;
         SetDoubleBuffer(false);
         clearviewport;
         DrawFill;
       end
     else
       if key=SpaceKey then  // Space Key
         begin
           key:=0;
           clearviewport;
           DrawFillSector;

           dx:=0;
           dy:=600;
           while (dx<GetMaxX) and (key<>ESCKey) do
             begin
               setcolor(red);
               SetFillStyle(XHatchFill,green);
               FillEllipse(dx,dy,50,50);
               delay(5);

               setcolor(0);
               SetFillStyle(SolidFill,0);
               bar(dx-51,dy-51,dx+51,dy+51);

               dx:=dx+1;
               if graphKeyPressed then
                 key:=graphReadKey;
             end;
           key:=0;
           clearviewport;
           DrawFill;
         end;
     delay(20);
   end;

 closegraph;
end.

