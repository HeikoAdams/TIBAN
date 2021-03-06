{*******************************************************}
{                                                       }
{       IBANMetrics                                     }
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

     The Original Code is IBANMetrics.pas.

     The Initial Developer of the Original Code is Heiko Adams <heiko.adams@gmail.com>.

     Contributor(s): Peter Mauss (Peter.Mauss@Advertum.de).
}

unit IBANMetrics;

interface

type
  TIBANMetrics = packed record
    nLenIBAN: Word;
    nStartBLZ: Word;
    nLenBLZ: Word;
    nStartKTO: Word;
    nLenKTO: Word;
    //20130830 Heiko Adams ..
    nStartChk: Word;
    nLenChk: Word;
    // .. 20130830 Heiko Adams
    
    //20130830 Peter Mauss
    sMask:String[100];
    
    //20130901 Heiko Adams
    nErrorCode: Integer;
  end;

function GetIBANMetrics(const aLand: string): TIBANMetrics;

implementation

uses SysUtils;

function GetIBANMetrics(const aLand: string): TIBANMetrics;
begin
  {
    �bersicht �ber die Struktur der IBAN in verschiedenen L�ndern:
    https://de.wikipedia.org/wiki/International_Bank_Account_Number#IBAN-Struktur_in_verschiedenen_L.C3.A4ndern
  }
  
  //20130901 Heiko Adams
  Result.nErrorCode := 0;

  if (aLand = 'AT') then
  begin
    with Result do
    begin
      nLenIBAN := 20;
      nLenBLZ := 5;
      nLenKTO := 11;
      nStartBLZ := 5;
      nStartKTO := nStartBLZ + nLenBLZ;
      //20130830 Heiko Adams ..
      nStartChk := 0;
      nLenChk := 0;
      // .. 20130830 Heiko Adams
      //20130830 Peter Mauss
      sMask:='>ll99 aaaa aaaa aaaa aaaa;0;_';
    end;
  end
  else if (aLand = 'BE') then
  begin
    with Result do
    begin
      nLenIBAN := 16;
      nLenBLZ := 3;
      // 20130830 Heiko Adams
      //nLenKTO := 5;
      nLenKTO := 7;
      nStartBLZ := 5;
      nStartKTO := nStartBLZ + nLenBLZ;
      //20130830 Heiko Adams ..
      nStartChk := 15;
      nLenChk := 2;
      // .. 20130830 Heiko Adams
      //20130830 Peter Mauss
      sMask:='>ll99 aaaa aaaa aaaa;0;_';
    end;
  end
  else if (aLand = 'CH') then
  begin
    with Result do
    begin
      nLenIBAN := 21;
      nLenBLZ := 5;
      nLenKTO := 12;
      nStartBLZ := 5;
      nStartKTO := nStartBLZ + nLenBLZ;
      //20130830 Heiko Adams ..
      nStartChk := 0;
      nLenChk := 0;
      // .. 20130830 Heiko Adams
      //20130830 Peter Mauss
      sMask:='>ll99 aaaa aaaa aaaa aaaa a;0;_';
    end;
  end
  else if (aLand = 'DE') then
  begin
    with Result do
    begin
      nLenIBAN := 22;
      nLenBLZ := 8;
      nLenKTO := 10;
      nStartBLZ := 5;
      nStartKTO := nStartBLZ + nLenBLZ;
      //20130830 Heiko Adams ..
      nStartChk := 0;
      nLenChk := 0;
      // .. 20130830 Heiko Adams
      //20130830 Peter Mauss
      sMask:='>ll99 9999 9999 9999 9999 99;0;_';
    end;
  end
  else if (aLand = 'DK') then
  begin
    with Result do
    begin
      nLenIBAN := 18;
      nLenBLZ := 4;
      nLenKTO := 10;
      nStartBLZ := 5;
      nStartKTO := nStartBLZ + nLenBLZ;
      //20130830 Heiko Adams ..
      nStartChk := 18;
      nLenChk := 1;
      // .. 20130830 Heiko Adams
      //20130830 Peter Mauss
      sMask:='>ll99 aaaa aaaa aaaa aa;0;_';
    end;
  end
  else if (aLand = 'FR') then
  begin
    with Result do
    begin
      nLenIBAN := 27;
      nLenBLZ := 5;
      nLenKTO := 11;
      nStartBLZ := 5;
      nStartKTO := nStartBLZ + nLenBLZ;
      //20130830 Heiko Adams ..
      nStartChk := 26;
      nLenChk := 2;
      // .. 20130830 Heiko Adams
      //20130830 Peter Mauss
      sMask:='>ll99 aaaa aaaa aaaa aaaa aaaa aaa;0;_';
    end;
  end
  else if (aLand = 'LI') then
  begin
    with Result do
    begin
      nLenIBAN := 21;
      nLenBLZ := 5;
      nLenKTO := 12;
      nStartBLZ := 5;
      nStartKTO := nStartBLZ + nLenBLZ;
      //20130830 Heiko Adams ..
      nStartChk := 0;
      nLenChk := 0;
      // .. 20130830 Heiko Adams
      //20130830 Peter Mauss
      sMask:='>ll99 aaaa aaaa aaaa aaaa a;0;_';
    end;
  end
  else if (aLand = 'LU') then
  begin
    with Result do
    begin
      nLenIBAN := 20;
      nLenBLZ := 3;
      //20130830 Heiko Adams
      //nLenKTO := 17;
      nLenKTO := 13;
      nStartBLZ := 5;
      nStartKTO := nStartBLZ + nLenBLZ;
      //20130830 Heiko Adams ..
      nStartChk := 0;
      nLenChk := 0;
      // .. 20130830 Heiko Adams
      //20130830 Peter Mauss
      sMask:='>ll99 aaaa aaaa aaaa aaaa;0;_';
    end;
  end
  else if (aLand = 'NL') then
  begin
    with Result do
    begin
      nLenIBAN := 18;
      nLenBLZ := 4;
      nLenKTO := 10;
      nStartBLZ := 5;
      nStartKTO := nStartBLZ + nLenBLZ;
      //20130830 Heiko Adams ..
      nStartChk := 0;
      nLenChk := 0;
      // .. 20130830 Heiko Adams
      //20130830 Peter Mauss
      sMask:='>ll99 aaaa aaaa aaaa aa;0;_';
    end;
  end
  else if (aLand = 'CZ') then
  begin
    with Result do
    begin
      nLenIBAN := 24;
      nLenBLZ := 4;
      nLenKTO := 16;
      nStartBLZ := 5;
      nStartKTO := nStartBLZ + nLenBLZ;
      //20130830 Heiko Adams ..
      nStartChk := 0;
      nLenChk := 0;
      // .. 20130830 Heiko Adams
      //20130830 Peter Mauss
      sMask:='>ll99 aaaa aaaa aaaa aaaa aaaa;0;_';
    end;
  end
  else if (aLand = 'PL') then
  begin
    with Result do
    begin
      nLenIBAN := 28;
      //20130830 Heiko Adams
      //nLenBLZ := 7;
      nLenBLZ := 3;
      nLenKTO := 16;
      nStartBLZ := 5;
      nStartKTO := nStartBLZ + nLenBLZ;
      //20130830 Heiko Adams ..
      nStartChk := 11;
      nLenChk := 1;
      // .. 20130830 Heiko Adams
      //20130830 Peter Mauss
      sMask:='>ll99 aaaa aaaa aaaa aaaa aaaa aa;0;_';
    end;
  end
  else
    //20130901 Heiko Adams
    //raise Exception.CreateFmt('Country (%s) not supported yet', [aLand]);
    Result.nError := -190;
end;

end.
