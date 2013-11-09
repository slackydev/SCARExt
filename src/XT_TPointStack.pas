Unit XT_TPointStack;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2013, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
interface

uses
  XT_Types;

const
  STACKMINSIZE = 1024;

type
  TPointStack = record
  private
    _High: Integer;
    _Length: Integer;
  public
    (* Container *)
    _Arr: TPointArray;
    
    (*
     Initalize
    *)
    procedure Init;

    (*
     Initalize with your own TPA
    *)
    procedure InitWith(TPA:TPointArray);

    (*
     Release the array
    *)
    procedure Free;


    (*
     Same as initlaize, tho the pourpose is not the same.
    *)
    procedure Reset; Inline;


    (*
     Check if we can give it a new size.. It's manly used internally, but can be used elsewere..
     Note: NewSize = The highest index. (Not same as the normal SetLength).
    *)
    procedure CheckResize(NewSize:Integer); Inline;


    (*
     Check if it's time to give it a new upper size.. Faster then calling CheckResize.
    *)
    procedure CheckResizeHigh(NewSize:Integer); Inline;


    (*
     Check if it's time to give it a new lower size.. Faster then calling CheckResize.
    *)
    procedure CheckResizeLow(NewSize:Integer); Inline;

    (*
     Returns the TPA/Array.
    *)
    function GetData: TPointArray; Inline;

    
    (*
     Returns a copy of the TPA/Array.
    *)
    function Copy: TPointArray; Inline;
    
    
    (*
     Returns the last item
    *)
    function Peek: TPoint; Inline;
    

    (*
     Remove the last item, and return what it was. It also downsizes the array if
     possible.
    *)
    function Pop: TPoint; Inline;


    (*
     Remove the last item, and return what it was.
    *)
    function FastPop: TPoint; Inline;


    (*
     Insert a item at the given position. It resizes the array if needed.
    *)
    procedure Insert(const Item: TPoint; Index:Integer); Inline;


    (*
     Appends the item to the last position in the array. Resizes if needed.
    *)
    procedure Append(const Item: TPoint); Inline;


    (*
     Appends the item to the last position in the array. Resizes if needed.
    *)
    procedure AppendXY(const X,Y: Integer); Inline;
    
    
    (*
     Extend the current array with the given TPA.
    *)
    procedure Extend(const TPA: TPointArray); Inline;

    (*
     Remove the first item from the stack whose value is `Value`.
    *)
    procedure Remove(const Item: TPoint); Inline;

    (*
     Remove the given index from the array.
    *)
    procedure Delete(const Index: Integer); Inline;
    
    
    (*
     Remove the given indices from the array.
    *)
    procedure DeleteEx(const Indices: TIntArray); Inline;
    
    
    (*
     Move each point in the stack by X,Y.
    *)
    procedure Move(X,Y:Integer); Inline;
    
    
    (*
     Reverse the array...
    *)
    procedure Reverse; Inline;
    
    
    (*
     Get the value of the given Index.
    *)
    function Get(Index:Integer): TPoint; Inline;

    
    (*
     Set the value of the given Index.
    *)
    procedure Put(Index:Integer; const Item: TPoint); Inline;
    
    
    (*
     Swaps to items of specified indexes. 
    *)
    procedure Swap(Index1, Index2: Integer); Inline;
    
    
    (*
     Check if the array is empty or not.
    *)
    function IsEmpty: Boolean; Inline;


    (*
     Check if the array has items or not.
    *)
    function NotEmpty: Boolean; Inline;


    (*
     Returns the length of the array including the overhead.
    *)
    function GetLength: Integer; Inline;


    (*
     Returns the size, in a way it's the same as `Length(Arr)`.
    *)
    function GetSize: Integer; Inline;


    (*
     Returns the highest index, in a way it's the same as `High(Arr)`.
    *)
    function GetHigh: Integer; Inline;


    (*
     It sets the overhead length down to the highest index + 1.
     It's used before a call to an external function, EG before using: GetTPABounds.
    *)
    procedure Fit; Inline;
  end;


//--------------------------------------------------
implementation

uses 
  XT_Math;

procedure TPointStack.Init;
begin
  _High := -1;
  _Length := STACKMINSIZE;
  SetLength(_Arr, _Length);
end;


procedure TPointStack.InitWith(TPA:TPointArray);
begin
  _Arr := TPA;
  _High := High(_Arr);
  _Length := Length(_Arr);
  if _Length < STACKMINSIZE then
  begin
    _Length := STACKMINSIZE;
    SetLength(_Arr, _Length);
  end;
end;


procedure TPointStack.Free;
begin
  _High := -1;
  _Length := STACKMINSIZE;
  SetLength(_Arr, 0);
end;


procedure TPointStack.Reset;
begin
  _High := -1;
  _Length := STACKMINSIZE;
  SetLength(_Arr, _Length);
end;


procedure TPointStack.CheckResize(NewSize:Integer);
begin
  if NewSize < 512 then
  begin
    _Length := STACKMINSIZE;
    _High := NewSize;
    Exit;
  end;
  _High := NewSize;
  case (_High >= _Length) of
   False:
    if ((_Length div 2) > _High) then
    begin
      _Length := _Length div 2;
      SetLength(_Arr, _Length);
    end;
   True:
    begin
      _Length := _Length + _Length;
      SetLength(_Arr, _Length);
    end;
  end;
end;


procedure TPointStack.CheckResizeHigh(NewSize:Integer);
begin
  _High := NewSize;
  if (_High >= _Length) then
  begin
    _Length := _Length + _Length;
    SetLength(_Arr, _Length);
  end;
end;


procedure TPointStack.CheckResizeLow(NewSize:Integer);
begin
  if NewSize < 512 then
  begin
    _Length := STACKMINSIZE;
    _High := NewSize;
    Exit;
  end;
  _High := NewSize;
  if ((_Length div 2) > _High) then
  begin
    _Length := _Length div 2;
    SetLength(_Arr, _Length);
  end;
end;


function TPointStack.GetData: TPointArray;
begin
  Result := _Arr;
end;


function TPointStack.Copy: TPointArray;
var i:Integer;
begin
  SetLength(Result, _High+1);
  //Move(_Arr[0], Result[0], _High * SizeOf(TPoint));
  for i := 0 to _High do   //Hard copy.
    Result[i] := _Arr[i];
end;


function TPointStack.Peek: TPoint;
begin
  Result := _Arr[_High];
end;


function TPointStack.Pop: TPoint;
begin
  Result := _Arr[_High];
  Dec(_High);
  CheckResizeLow(_High);
end;


function TPointStack.FastPop: TPoint;
begin
  Result := _Arr[_High];
  Dec(_High);
end;



procedure TPointStack.Insert(const Item: TPoint; Index:Integer);
var i:Integer;
begin
  CheckResizeHigh(_high+1);
  if Index > _High then //Remove old crap.. and resize
  begin
    SetLength(_Arr, _high); 
    CheckResizeHigh(Index);
  end;
  for i:=_high-1 downto Index do
    _Arr[i+1] := _Arr[i];
  _Arr[Index] := Item;
end;


procedure TPointStack.Append(const Item: TPoint);
begin
  Inc(_High);
  CheckResizeHigh(_High);
  _Arr[_High] := Item;
end;


procedure TPointStack.AppendXY(const X,Y: Integer); 
begin
  Inc(_High);
  CheckResizeHigh(_High);
  _Arr[_High].x := X;
  _Arr[_High].y := Y;
end;


procedure TPointStack.Extend(const TPA: TPointArray);
var
 i,_h,h:Integer;
begin
  H := Length(TPA);
  if (H = 0) then Exit;
  _h := _High + 1;
  CheckResizeHigh(H + _h);
  for i := 0 to H-1 do
    _Arr[i+_h] := TPA[i];
end;


procedure TPointStack.Remove(const Item: TPoint);
var
 i,j:Integer;
 hit:Boolean;
begin
  if (_High = -1) then Exit;

  hit := False;
  j := 0;
  for i := 0 to _High do
  begin
    if Not(hit) and (_Arr[i].X = Item.X) and (_Arr[i].Y = Item.Y) then
    begin
      hit := True;
      j := i;
    end else if (hit) then
    begin
      _Arr[j] := _Arr[i];
      Inc(j);
    end;
  end;

  if (hit) then
    CheckResizeLow(_High - 1);
end;


procedure TPointStack.Delete(const Index: Integer);
var
 i,j:Integer;
begin
  if (_High = -1) then Exit;
  if (Index > _High) or (Index < 0) then Exit;
  j := 0;
  
  for i:=Index to _High do
  begin
    if (i=Index) then
    begin
      j := i;
    end else
    begin
      _Arr[j] := _Arr[i];
      Inc(j);
    end;
  end; 

  CheckResizeLow(_High - 1);
end;


procedure TPointStack.DeleteEx(const Indices: TIntArray);
var
 i,len,lo:Integer;
 Del:TBoolArray;
begin
  if (_High = -1) then Exit;
  Lo := _High;
  SetLength(Del, _High+1);
  for i := 0 to High(Indices) do
    if ((Indices[i] > -1) and (Indices[i] <= _High)) then
    begin
      Del[Indices[i]] := True;
      if (Indices[i] < Lo) then Lo := Indices[i];
    end;

  len := 0;
  for i:=Lo to _high do
    if not(Del[i]) then
    begin
      _Arr[len] := _Arr[i];
      Inc(len);
    end;

  SetLength(Del, 0);
  CheckResizeLow(_High - (High(Indices)-len));
end;


procedure TPointStack.Move(X, Y:Integer);
var i: Integer;
begin
  if (_High = -1) then Exit;
  for i:=0 to _High do begin
    _Arr[i].x := _Arr[i].x + X;
    _Arr[i].y := _Arr[i].y + Y;
  end;
end;


procedure TPointStack.Reverse;
var 
  i, Mid: Integer;
  Tmp:TPoint;
begin
  if (_High <= 0) then Exit;
  Mid := _High div 2;
  for i := 0 to Mid do begin
    Tmp := _Arr[_High-i];
    _Arr[_High-i] := _Arr[i];
    _Arr[i] := tmp;
  end;
end;


function TPointStack.Get(Index:Integer): TPoint;
begin
  Result := _Arr[Index];
end;


procedure TPointStack.Put(Index:Integer; const Item: TPoint);
begin
  _Arr[Index] := Item;
end;


procedure TPointStack.Swap(Index1, Index2: Integer);
var Tmp:TPoint;
begin
  Tmp := _Arr[Index1];
  _Arr[Index1] := _Arr[Index2];
  _Arr[Index2] := Tmp;
end;


function TPointStack.IsEmpty: Boolean;
begin
  Result := _High < 0;
end;


function TPointStack.NotEmpty: Boolean;
begin
  Result := _High > -1;
end;


function TPointStack.GetLength: Integer;
begin
  Result := _Length;
end;


function TPointStack.GetHigh: Integer;
begin
  Result := _High;
end;


function TPointStack.GetSize: Integer;
begin
  Result := _High + 1;
end;


procedure TPointStack.Fit;
begin
  _Length := _High + 1;
  SetLength(_Arr, _Length);
end;


end.