unit EnsureData;

interface
uses sysutils,classes,DRT.ZSTD,IOProxy;

const
  DataFile = 'glibc-2.31.tar';

procedure CheckData;

implementation
uses DRT.xxhash,IOUtils;
var df,da : String;
procedure CheckData;
var G : TFileStream;
    D : TZSTDDecompressStream;
    M,F : TMemoryStream;
    buf : array[0..128*1024-1] of byte;
begin
{$IF DEFINED(ANDROID) OR DEFINED(ANDROID64)}
  df := TPath.Combine(TPath.GetDocumentsPath,DataFile);
  da := TPath.Combine(TPath.GetDocumentsPath,'DATA.PART.');
{$ELSE}
  df := DataFile;
  da := 'DATA.PART.';
{$ENDIF}
  if fileexists(df) then Exit;
  PutS('File '+df+' not found. creating....');
  F := TMemoryStream.Create;
  M := TMemoryStream.Create;
  try
    for var I := '1' to '4' do begin
      G := TFileStream.Create(da+i,fmOpenRead);
      try
        var s : Cardinal;
        repeat
          s := G.Read(buf,128*1024);
          M.Write(buf,s);
        until s<128*1024;
      finally
        G.Free;
      end;
    end;
    M.Position := 0;
    D := TZSTDDecompressStream.Create(M,false);
    try
      F.CopyFrom(D,0,128*1024);
    finally
      D.Free;
    end;
    F.Position := 0;
    PutS(F.Size.ToString+' '+THASHXXH3.HashAsString(F));
    F.Position := 0;
    F.SaveToFile(df);
  finally
    M.Free;
    F.Free;
  end;
  PutS('File created.');
  PutS('');
end;
end.
