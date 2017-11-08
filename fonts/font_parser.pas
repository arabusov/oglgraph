program font_parser;
uses SysUtils;
var 
  buf : QWord;
  f : file;
  i,j : byte;
  k : integer;

function GetBit(Value: QWord; Index: Byte): byte;
begin
  GetBit := ((Value shr Index) and 1);
end;

begin
	if ParamCount<>1 then
	begin
		writeln('Usage: font_parser font_8x8.psf');
		halt;
	end;
	assign(f, ParamStr(1));
	reset(f,1);
	writeln('TYPE');
	writeln('  TBitMapChar = array[0..7,0..7] of byte;');
	writeln('CONST');
	writeln('   DefaultFontData: Array[#0..#255] of TBitmapChar = (');
	seek(f,4);
	k:=0;
	while not eof(f) and (k<256) do
	begin
		blockread(f,buf,8);
		writeln('(');
		for i:=0 to 7 do
		begin
			write('(');
			write(GetBit(buf,i*8+7));
			for j:=6 downto 0 do
			begin
				write(',',GetBit(buf,i*8+j));
			end;
			if i<7 then
			  writeln('),')
			else
			  writeln(')')
		end;
		inc(k);
		if k<256 then
			writeln('),')
		else
			writeln(')');
	end;
	close(f);
	writeln(');');
end.

  
