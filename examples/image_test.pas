Program pr2;

Uses

    oglgraph, Crt;

Const

     grDriver : smallint = Detect;
     size =   40;
     s2   = size div 2;
     s4   = size div 4;
     margin =   40;

Var
   grMode : smallint;
   HalfX, HalfY : Integer;
   x,y,x1,y1, x2, y2, i : Integer;
   Image : pointer;

Begin

     Randomize;
     {}
     InitGraph(grDriver, grMode, ' ');

     {Вывод линий}
 //    ReadKey;
     HalfX := GetMaxX div 2;
     HalfY := GetMaxY div 2;
     x:= HalfX;
     x1:=x;
     y:= HalfY;
     y1:=y;
     For i:=1 to 450 do
     begin
         x2:= round(cos(0.05*i)*HalfY) + HalfX;
         y2:= round(sin(0.02*i)*HalfY) + HalfY;
         If (i mod 10) = 0 then  SetColor(Random(15)+1);
         line(x1, y1, x2, y2);
         line(x , y , x2, y2);
         x1:=x2; y1:=y2;
         delay(5);
     end;

     {Формируем спрайт}
     SetColor(Cyan);
     x:= margin; y:=x;
     circle(x + s2,y + s2, s2);
     SetFillStyle(InterLeaveFill,Green);
     FillEllipse(x + s4, y + s4, s4, s4 div 2);
     FillEllipse(x + 3*s4, y + s4, s4, s4 div 2);
     SetLineStyle(SolidLn, 0, ThickWidth);
     line(x + s2, y + s4, x + s2, y + s2);
     SetColor(Red);
     Arc(x + s2, y + s2, 200, 300, s4);
     Getmem( image, imagesize(x, y, x + size, y + size));
     GetImage(x, y, x + size, y + size, image^);
     PutImage(x, y, Image^, XorPut);

     {Вывод движущегося изображения}
     While x < GetMaxX - margin - size do
     Begin
        PutImage(x, y, Image^, XorPut);
        delay(5);
        PutImage(x, y, Image^, XorPut);
        Inc(x, 150);
     end;
     PutImage(x, y, Image^, XorPut);

     {Вывод текста }

     SetColor(Cyan);
     SetTextStyle(GothicFont, HorizDir, 4);
     OutTextXY(HalfX + margin, HalfY - margin-15,' The end!');
     OutTextXY(HalfX + margin, HalfY - margin+15,'Press any key');
     
     {Ожидание нажатия клавиши}
     repeat delay(10); until graphKeyPressed();
     closeGraph();
End.



