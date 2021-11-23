unit uselectregioncode;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
  , SysUtils
  , Forms
  , Controls
  , Graphics
  , Dialogs
  , StdCtrls
  , DBGrids
  , ActnList
  , IBQuery
  , DB
  , generics.Collections;

type

  TDepartRec = packed record
    ID: PtrInt;
    Name: String;
  end;

  TDepartList = specialize TList<TDepartRec>;

  { TfrmSelectRegion }

  TfrmSelectRegion = class(TForm)
    ActCbbDepartFill: TAction;
    ActQryDepart: TAction;
    actlistSelectRegion: TActionList;
    btnRight: TButton;
    btnLeft: TButton;
    cbbRegion: TComboBox;
    DSSelectRegion: TDataSource;
    grSelectRegion: TDBGrid;
    edtFilter: TEdit;
    qryDepartCode: TIBQuery;
    qryLocatCode: TIBQuery;
    lblRegion: TLabel;
    lblFilter: TLabel;
    procedure ActCbbDepartFillExecute(Sender: TObject);
    procedure ActQryDepartExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FDepartList: TDepartList;//список регионов страны
    FIDCountry: PtrInt;//ID выбранной страны
    FIDDepart: PtrInt;//ID выбранной области
    FIDRegion: PtrInt;//ID выбранного региона
  public
    property IDCountry: PtrInt read FIDCountry write FIDCountry;
    property IDRegion: PtrInt read FIDRegion write FIDRegion;
    property IDDepart: PtrInt read FIDDepart write FIDDepart;
    property DepartList: TDepartList read FDepartList write FDepartList;
  end;

var
  frmSelectRegion: TfrmSelectRegion;

implementation

{$R *.lfm}

{ TfrmSelectRegion }

procedure TfrmSelectRegion.ActQryDepartExecute(Sender: TObject);
begin
  with qryDepartCode do
  begin
    try
      if Active then Active:= False;
      SQL.Text:= 'SELECT ID, NAME_I18N ' +
                  'FROM TBL_DEPARTMENT ' +
                  'WHERE (ID > 0) AND (FK_COUNTRY = :prmCountry) ' +
                  'ORDER BY 1';
      Prepare;
      ParamByName('prmCountry').Value:= IDCountry;
      Active:= True;
    except
      on e:Exception do
      begin
        Active:= False;
        ShowMessage(e.Message);
      end;
    end;
  end;
end;

procedure TfrmSelectRegion.ActCbbDepartFillExecute(Sender: TObject);
var
  DepartRec: TDepartRec;
  i: PtrInt = -1;
begin
  DepartRec:= Default(TDepartRec);

  if Assigned(DepartList)
    then DepartList.Clear
    else Exit;

  if qryDepartCode.Active and not qryDepartCode.IsEmpty then
  begin
    DepartRec.ID:= -1;
    DepartRec.Name:= '<все>';

    DepartList.Add(DepartRec);

    qryDepartCode.First;
    while not qryDepartCode.EOF do
    begin
      DepartRec.ID:= qryDepartCode.FN('ID').Value;
      DepartRec.Name:= qryDepartCode.FN('NAME_I18N').Value;
      DepartList.Add(DepartRec);
      qryDepartCode.Next;
    end;

    cbbRegion.Clear;

    for i:= 0 to Pred(DepartList.Count) do
    cbbRegion.Items.Add(DepartList.Items[i].Name);

    cbbRegion.ItemIndex:= 0;
  end;
end;

procedure TfrmSelectRegion.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  if Assigned(DepartList) then
  begin
    DepartList.Free;
    DepartList:= nil;
  end;
end;

procedure TfrmSelectRegion.FormCreate(Sender: TObject);
begin
  DepartList:= TDepartList.Create;
  IDCountry:= -1;
  IDRegion:= -1;
end;

procedure TfrmSelectRegion.FormShow(Sender: TObject);
begin
  ActQryDepartExecute(Sender);
  ActCbbDepartFillExecute(Sender);
end;

end.

