unit TestUnit;

interface
uses
  System.SysUtils,
  classes,
  DRT.zstd,
  DRT.xxhash,
  DRT.zlib,
  System.Diagnostics,
  IOProxy;

procedure DoTest; cdecl;

implementation
uses IOUtils;

var data,c,d,cc,dd : TMemoryStream;
    ZC : TZstdCompressStream;
    ZD : TZSTDDecompressStream;
    ZLC : TZCompressionStream;
    ZLD : TZDeCompressionStream;
    W: TStopWatch;
    df : String;

procedure WriteInfo(Op : String; St : TStream);
begin
  st.Position := 0;
  PutS(Op+' in '+W.ElapsedMilliseconds.ToString+'ms   Size: '+St.Size.ToString+
    '   XXHash3: '+THASHXXH3.HashAsString(St));
  W.Reset;
  st.Position := 0;
end;
procedure DoTest; cdecl;
begin
{$IFDEF ANDROID}
  df := TPath.Combine(TPath.GetDocumentsPath,'glibc-2.31.tar');
{$ELSE}
  df := 'glibc-2.31.tar';
{$ENDIF}
  PutS('zstd version: '+ZSTD_VERSION_STRING);
//  readln;
  PutS('');
  try
    { TODO -oUser -cConsole Main : Insert code here }
    W := TStopWatch.Create;
    data := TMemoryStream.Create;
    data.LoadFromFile(df);
    data.Position := 0;
    PutS('Orginal Size: '+data.SIZE.ToString+'  Orginal XXHash3: '+THASHXXH3.HashAsString(data));
    PutS('');
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
    PutS('');
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
    PutS('');
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
    PutS('');
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
    PutS('');
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
    PutS('');
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
    PutS('');
    data.Free;
    c.free;
    d.free;
    cc.free;
    dd.free;
  except
    on E: Exception do
      PutS(E.ClassName+': '+E.Message);
  end;
  PutS('Done! press ENTER to quit');
  GetS;
end;

end.
