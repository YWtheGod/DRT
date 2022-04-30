unit TestUnit;

interface
uses
  System.SysUtils,
  classes,
  DRT.zstd,
  DRT.xxhash,
  DRT.zlib,
  System.Diagnostics  ;

procedure DoTest; cdecl;

implementation

var data,c,d,cc,dd : TMemoryStream;
    ZC : TZstdCompressStream;
    ZD : TZSTDDecompressStream;
    ZLC : TZCompressionStream;
    ZLD : TZDeCompressionStream;
    W: TStopWatch;

procedure WriteInfo(Op : String; St : TStream);
begin
  st.Position := 0;
  write(Op,' in ',W.ElapsedMilliseconds,'ms   ');
  writeln('Size: ',St.Size,'   XXHash3: ',THASHXXH3.HashAsString(St));
  W.Reset;
  st.Position := 0;
end;
procedure DoTest; cdecl;
begin
  writeln('zstd version: ',ZSTD_VERSION_STRING);
//  readln;
  writeln;
  try
    { TODO -oUser -cConsole Main : Insert code here }
    W := TStopWatch.Create;
    data := TMemoryStream.Create;
    data.LoadFromFile('glibc-2.31.tar');
    data.Position := 0;
    writeln('Orginal Size: ',data.SIZE,'  Orginal XXHash3: ',THASHXXH3.HashAsString(data));
    writeln;
    C := TMemoryStream.Create;
    D := TMemoryStream.Create;
    cc := TMemoryStream.Create;
    dd := TMemoryStream.Create;
    data.Position := 0;
    cc.Clear;
    W.Start;
    cc.position:= 0;
    ZLC := TZCompressionStream.Create(clFastest,cc);
    ZLC.CopyFrom(data,data.Size);
    ZLC.Free;
    W.Stop;
    WriteInfo('Zlib Fastest Compress',cc);
    W.Start;
    dd.position := 0;
    ZLD := TZDecompressionStream.Create(CC);
    dd.CopyFrom(ZLD);
    ZLD.Free;
    W.Stop;
    WriteInfo('Zlib Fastest DeCompress',dd);
    writeln;
    data.Position := 0;
    c.Clear;
    W.Start;
    c.position := 0;
    ZC := TZSTDCompressStream.Create(C,1);
    ZC.CopyFrom(data,data.Size);
    ZC.Free;
    W.Stop;
    WriteInfo('ZSTD Fastest Compress',c);
    W.Start;
    d.position := 0;
    ZD := TZSTDDecompressStream.Create(C,false);
    D.CopyFrom(ZD);
    ZD.Free;
    WriteInfo('ZSTD Fastest DeCompress',d);
    writeln;
    cc.Clear;
    data.Position := 0;
    W.Start;
    cc.position:= 0;
    ZLC := TZCompressionStream.Create(clDefault,cc);
    ZLC.CopyFrom(data,data.Size);
    ZLC.Free;
    W.Stop;
    WriteInfo('Zlib Default Compress',cc);
    W.Start;
    dd.position := 0;
    ZLD := TZDecompressionStream.Create(CC);
    DD.CopyFrom(ZLD);
    ZLD.Free;
    W.Stop;
    WriteInfo('Zlib Default DeCompress',dd);
    writeln;
    data.position := 0;
    c.Clear;
    W.Start;
    c.position := 0;
    ZC := TZSTDCompressStream.Create(C);
    ZC.CopyFrom(data,data.Size);
    ZC.Free;
    W.Stop;
    WriteInfo('ZSTD Default Compress',c);
    W.Start;
    d.position := 0;
    ZD := TZSTDDecompressStream.Create(C,false);
    D.CopyFrom(ZD);
    ZD.Free;
    W.Stop;
    WriteInfo('ZSTD Default DeCompress',d);
    writeln;
    data.Position := 0;
    cc.Clear;
    W.Start;
    cc.position:= 0;
    ZLC := TZCompressionStream.Create(clMAX,cc);
    ZLC.CopyFrom(data,data.Size);
    ZLC.Free;
    W.Stop;
    WriteInfo('Zlib MAX Compress',cc);
    W.Start;
    dd.position := 0;
    ZLD := TZDecompressionStream.Create(CC);
    DD.CopyFrom(ZLD);
    ZLD.Free;
    W.Stop;
    WriteInfo('Zlib MAX DeCompress',dd);
    writeln;
    data.position := 0;
    c.Clear;
    W.Start;
    c.position := 0;
    ZC := TZSTDCompressStream.Create(C,9);
    ZC.CopyFrom(data,data.Size);
    ZC.Free;
    W.Stop;
    WriteInfo('ZSTD LV9 Compress',c);
    W.Start;
    d.position := 0;
    ZD := TZSTDDecompressStream.Create(C,false);
    D.CopyFrom(ZD);
    ZD.Free;
    W.Stop;
    WriteInfo('ZSTD LV9 DeCompress',d);
    writeln;
    data.Free;
    c.free;
    d.free;
    cc.free;
    dd.free;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  writeln('Done! press ENTER to quit');
  readln;
end;

end.
