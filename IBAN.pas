{*******************************************************}
{                                                       }
{       IBAN                                            }
{                                                       }
{       Copyright (C) 2011 Heiko Adams                  }
{                                                       }
{*******************************************************}

{
     The contents of this file are subject to the Mozilla Public License
     Version 1.1 (the "License"); you may not use this file except in
     compliance with the License. You may obtain a copy of the License at
     http://www.mozilla.org/MPL/

     Software distributed under the License is distributed on an "AS IS"
     basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
     License for the specific language governing rights and limitations
     under the License.

     The Original Code is IBAN.pas.

     The Initial Developer of the Original Code is Heiko Adams <heiko.adams@gmail.com>.

     Contributor(s): ______________________________________.
}

unit IBAN;

interface

uses IBANMetrics;

type
  TIBAN = class
  private
    FKTO: string;
    FBLZ: string;
    FLand: string;
    FIBAN: string;
    // 20130830 Heiko Adams
    FLastError: Integer;

    FMetrics: TIBANMetrics;

    function EncodeCountry(const aLand: string): string;
    function Modulo97PruefZiffer(const aIBAN:string):Integer;
    function CheckIBAN: Boolean;
    function CalcIBAN: string;
    function GetLand: string;
    function GetCountryFromIBAN: string;
    procedure SetLand(const aValue: string);
    procedure SetIBAN(const aValue: string);
    procedure FillM97Tab;
    // 20130830 Heiko Adams
    procedure SetErrorCode(nError: Integer);
  public
    // 20130830 Heiko Adams ...
    // Don't use these properties because they are deprecated and will be
    // removed in future versions of this class!
    property Konto: string read FKTO write FKTO;
    property BLZ: string read FBLZ write FBLZ;
    property Land: string read GetLand write SetLand;
    // ... 20130830 Heiko Adams
    
    // 20130830 Heiko Adams i18n version of german named public properties ...
    property BankAccount: string read FKTO write FKTO;
    property BankCode: string read FBLZ write FBLZ;
    property Country: string read GetLand write SetLand;
    // ... 20130830 Heiko Adams
    
    property IBAN: string read CalcIBAN write SetIBAN;
    property Valid: Boolean read CheckIBAN;
    // 20130830 Heiko Adams
    property ErrorCode: Integer read FLastError;
    
    function checkIban(const sIban: String): boolean; deprecated;
    function IsIBAN(const s:string):boolean;
    
    // 20130830 Heiko Adams ...
    function GetAccountNumberFromIBAN: string;
    function GetBankCodeFromIBAN: string;
    // ... 20130830 Heiko Adams

    constructor Create;
    destructor Destroy; override;
	end;

var
   m97tab:array[0..96,0..9] of byte;

implementation

uses SysUtils, Windows;

destructor TIBAN.Destroy;
begin
  ZeroMemory(@FMetrics, SizeOf(FMetrics));
  inherited;
end;

constructor TIBAN.Create;
begin
  inherited;
  // 20130830 Heiko Adams
  SetErrorCode(0);
  FillM97Tab;
end;

procedure TIBAN.SetErrorCode(nError: Integer);
begin
  FLastError := nError;
end;

function TIBAN.GetAccountNumberFromIBAN: string;
begin
  Result := EmptyStr;
  // 20130830 Heiko Adams
  SetErrorCode(0);

  if Assigned(FMetrics) and (trim(FIBAN) <> EmptyStr) then
    Result := Copy(FIBAN, FMetrics.nStartKTO, FMetrics.nLenKTO)
  // 20130830 Heiko Adams ...
  else
    SetErrorCode(-180);
  // ... 20130830 Heiko Adams
end;

function TIBAN.GetBankCodeFromIBAN: string;
begin
  Result := EmptyStr;
  // 20130830 Heiko Adams
  SetErrorCode(0);

  if Assigned(FMetrics) and (trim(FIBAN) <> EmptyStr) then
    Result := Copy(FIBAN, FMetrics.nStartBLZ, FMetrics.nLenBLZ)
  // 20130830 Heiko Adams ...
  else
    SetErrorCode(-190);
  // ... 20130830 Heiko Adams
end;

procedure TIBAN.SetLand(const aValue: string);
begin
  // 20130830 Heiko Adams
  SetErrorCode(0);
  FLand := Trim(UpperCase(Copy(aValue, 1, 2)));

  if (Length(FLand) < 2) then
    // 20130830 Heiko Adams
    //raise Exception.CreateFmt('Invalid country code: %s', [aValue]);
    SetErrorCode(-100);

  ZeroMemory(@FMetrics, SizeOf(FMetrics));
  FMetrics := GetIBANMetrics(FLand);
end;

function TIBAN.GetCountryFromIBAN: string;
begin
  // 20130830 Heiko Adams
  SetErrorCode(0);
  
  if (Trim(FIBAN) = EmptyStr) then
    // 20130830 Heiko Adams
    //raise Exception.Create('IBAN not set');
    SetErrorCode(-110);

  Result := Copy(FIBAN, 1, 2);
end;

procedure TIBAN.SetIBAN(const aValue: string);
begin
  // 20130830 Heiko Adams
  SetErrorCode(0);
  
  if (Trim(aValue) = EmptyStr) then
    // 20130830 Heiko Adams
    //raise Exception.Create('No IBAN submitted');
    SetErrorCode(-120);

  FIBAN := aValue;
  SetLand(GetCountryFromIBAN);
end;

function TIBAN.GetLand: string;
begin
  // 20130830 Heiko Adams
  SetErrorCode(0);
  Result := EmptyStr;

  if not (FLand = EmptyStr) then
    Result := FLand
  else if not (FIBAN = EmptyStr) then
    Result := GetCountryFromIBAN
  else
    // 20130830 Heiko Adams
    //raise Exception.Create('No country or IBAN set');
    SetErrorCode(-130);
end;

// Original code by shima (http://www.delphipraxis.net/1061658-post6.html)
function TIBAN.Modulo97PruefZiffer(const aIBAN:string):Integer;
const
   m36:string = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
var
   nCounter, nPruef : Integer;
begin
  // 20130830 Heiko Adams
  SetErrorCode(0);
  Result := 0;

  for nCounter := 1 to Length(aIBAN) do
  begin
    nPruef := Pos(aIBAN[nCounter], m36) ;

    if (nPruef = 0) then
      // 20130830 Heiko Adams
      //raise Exception.CreateFmt('Modulo97PruefZiffer(%s): invalid data', [aIBAN]);
      SetErrorCode(-140);

    Dec(nPruef);

    if (nPruef > 9) then
    begin
       Result := Result * 10 + (nPruef div 10);
       nPruef := nPruef mod 10;
    end;

    Result := Result * 10 + nPruef;
    Result := Result mod 97;
  end;
end;

// Code beigesteuert von Amateurprofi (http://www.delphipraxis.net/159320-iban-ueberpruefen.html#post1154665)
procedure TIBAN.FillM97Tab;
var 
  i,j:Integer;
begin
  for i:=0 to 96 do
    for j:=0 to 9 do
      m97tab[i,j]:=(i*10+j) Mod 97;
end;

function TIBAN.EncodeCountry(const aLand: string): string;
var
  sLetter: Char;
begin
  // 20130830 Heiko Adams
  SetErrorCode(0);
  
  if (Length(Trim(aLand)) <> 2) then
    SetErrorCode(-100);
    // 20130830 Heiko Adams
    //raise Exception.CreateFmt('Invalid country code: %s', [aLand]);

  for sLetter in aLand do
    case sLetter of
      'A': Result := Result + '10';
      'B': Result := Result + '11';
      'C': Result := Result + '12';
      'D': Result := Result + '13';
      'E': Result := Result + '14';
      'F': Result := Result + '15';
      'G': Result := Result + '16';
      'H': Result := Result + '17';
      'I': Result := Result + '18';
      'J': Result := Result + '19';
      'K': Result := Result + '20';
      'L': Result := Result + '21';
      'M': Result := Result + '22';
      'N': Result := Result + '23';
      'O': Result := Result + '24';
      'P': Result := Result + '25';
      'Q': Result := Result + '26';
      'R': Result := Result + '27';
      'S': Result := Result + '28';
      'T': Result := Result + '29';
      'U': Result := Result + '30';
      'V': Result := Result + '31';
      'W': Result := Result + '32';
      'X': Result := Result + '33';
      'Y': Result := Result + '34';
      'Z': Result := Result + '35';
    else
      // 20130830 Heiko Adams
      //raise Exception.CreateFmt('Invalid country code: %s', [aLand]);
      SetErrorCode(-100);
    end;
end;

function TIBAN.CheckIBAN(): Boolean;
var
  sBLZ: string;
  sKTO: string;
  sIBAN: string;
  sLand: string;
  sControl: string;
begin
  // 20130830 Heiko Adams
  SetErrorCode(0);
  Result := (Length(FIBAN) = FMetrics.nLenIBAN);

  if Result then
  begin
    sControl := Copy(FIBAN, 3, 2);
    sBLZ := Copy(FIBAN, FMetrics.nStartBLZ, FMetrics.nLenBLZ);
    sKTO := Copy(FIBAN, FMetrics.nStartKTO, FMetrics.nLenKTO);
    sLand := EncodeCountry(GetCountryFromIBAN);
    sIBAN := sBLZ + sKTO + sLand + sControl;
    Result := (Modulo97PruefZiffer(sIBAN) = 1);
  end
  // 20130830 Heiko Adams ...
  else
    SetErrorCode(-150);
  // ... 20130830 Heiko Adams
end;

function TIBAN.CalcIBAN(): string;
var
  sKTO: string;
  sIBAN: string;
  nControl: Integer;
  sControl: string;
const
  sSuffix = '00';
  nControlBase = 98;
begin
  sKTO := StringOfChar('0', FMetrics.nLenKTO - Length(FKTO)) + FKTO;
  sIBAN := FBLZ + sKTO + EncodeCountry(FLand)+  sSuffix;
  nControl := Modulo97PruefZiffer(sIBAN);
  nControl := nControlBase - nControl;
  
  // 20120224 Heiko Adams
  // make shure controlnumber has allways two characters
  // thanks to Henry van der Mark for this hint
  //FIBAN := FLand + IntToStr(nControl) + FBLZ + sKTO;
  sControl := IntToStr(nControl);
  
  if (nControl < 10) then
    sControl := '0' + sControl;

  FIBAN := FLand + sControl + FBLZ + sKTO;

  Result := FIBAN;
end;

// Prüfung einer IBAN auf formale Korrektheit (ohne Prüfung der Gültigkeit des Länderkürzels)
// Autor: Dr. Michael Schramm, Bordesholm
function TIBAN.checkIban(const sIban: String): boolean;
var k,i,n,len: integer; c: char;
    buff: array[0..67] of char;
begin
  result:= false;
  n:= length(sIban);
  
  if (n < 5) or (n > 34) then 
    exit;
  
  len:= 0; 
  k:= 5;
  
  repeat // IBAN als Ziffernfolge in geänderter Reihenfolge in buff schreiben
    c:= sIban[k];
    
    if (c >= '0') and (c <= '9') then 
    begin
      buff[len]:= c; 
      inc(len)
    end
    else if (c >= 'A') and (c <= 'Z') then 
    begin
      i:= ord(c)-55;
      buff[len]:= char(i div 10 + 48); 
      inc(len);
      buff[len]:= char(i mod 10 + 48); 
      inc(len);
    end
    else 
      exit;

    inc(k);
    
    if (k > n) then 
      k:= 1
  until k = 5;
  
  i:= 0; // aktueller Rest für Modulo-Berechnung
  
  for k:= 0 to len-1 do 
  begin // modulo 97 berechnen
    i:= (i * 10 + ord(buff[k]) - 48) mod 97;
  end;
  
  result:= (i = 1)
end;

// Code beigesteuert von Amateurprofi (http://www.delphipraxis.net/159320-iban-ueberpruefen.html#post1154665)
function TIBAN.IsIBAN(const s:string):boolean;
var 
  len: integer;
  cs: byte;
  function GetCheckSum(first,last:integer):boolean;
  var 
    i: integer; 
    c: integer;
  begin
    for i:=first to last do 
    begin
    c:=Ord(s[i])-48;
  
    case c of
      0..9     :  cs:=m97tab[cs,c];
      17..42   :  cs:=m97tab[m97tab[cs,(c-7) Div 10],(c-7) Mod 10];
      else Exit(False);
    end;
  end;
  result:=true;
end;
begin
  // 20130830 Heiko Adams
  SetErrorCode(0);
  len:=Length(s);
  
  if (len<5) or (len>34) then
  begin
    // 20130830 Heiko Adams
    SetErrorCode(-160);
    Exit(false);
  end;
  
  cs:=0;
  
  if not GetCheckSum(5,len) then 
  begin
    // 20130830 Heiko Adams
    SetErrorCode(-170);
    Exit(false);
  end;
  
  if not GetCheckSum(1,4) then 
  begin
    // 20130830 Heiko Adams
    SetErrorCode(-170);
    Exit(false);
  end;
  
  Result := (cs=1);
end;

end.