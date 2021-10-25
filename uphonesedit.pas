unit uphonesedit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ActnList, LCLType, LazUTF8, uphonespanelframe, IBDatabase,
  Generics.Collections;

type
  //режим вызова модального окна: добавление/редактирование записи
  TEditMode = (emAdd, emEdit);

  TPnlObjList = specialize TObjectList<TfrPhonesPnl>;

  { TfrmPhonesEdit }

  TfrmPhonesEdit = class(TForm)
    ActChbMainContactsStateChg: TAction;
    ActChbMainContactCheck: TAction;
    ActChbMobileStateChg: TAction;
    ActUIRefresh: TAction;
    ActShowHidePnlObjListBtns: TAction;
    ActPnlAdd: TAction;
    ActPnlRemove: TAction;
    ActbtnOK: TAction;
    ActbtnCancel: TAction;
    actlistPhonesEdit: TActionList;
    btnRight: TButton;
    btnLeft: TButton;
    btnPhoneBaseConn: TButton;
    IBDatabase1: TIBDatabase;
    IBTransaction1: TIBTransaction;
    scrboxPhonesPnl: TScrollBox;
    procedure ActChbMainContactCheckExecute(Sender: TObject);
    procedure ActChbMainContactsStateChgExecute(Sender: TObject);
    procedure ActChbMobileStateChgExecute(Sender: TObject);
    procedure ActPnlAddExecute(Sender: TObject);
    procedure ActPnlRemoveExecute(Sender: TObject);
    procedure ActbtnCancelExecute(Sender: TObject);
    procedure ActbtnOKExecute(Sender: TObject);
    procedure ActShowHidePnlObjListBtnsExecute(Sender: TObject);
    procedure ActUIRefreshExecute(Sender: TObject);
    procedure btnPhoneBaseConnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FCountryCode: PtrInt;//поле, содержащее ID кода выбранной страны (по умолчанию -1)
    FFrmEditMode: TEditMode;
    FIsPhoneBaseConn: Boolean;//флаг, подключена ли форма к phones.fdb
    FMaxPnlCount: PtrInt;//макс.количество панелей на форме для добавления телефонов
    FPhoneBase: TIBDataBase;//ссылка на наследник TIBDataBase, передаваемый в форму
    FPhoneTrans: TIBTransaction;//ссылка на наследник TIBTransaction, передаваемый в форму
    FPnlObjList: TPnlObjList;
    FPnlTagCounter: PtrInt;//счетчик тэгов для новых панелей (для внутренних нужд)
    procedure SetPnlObjList(AValue: TPnlObjList);
  public
    property MaxPnlCount: PtrInt read FMaxPnlCount;//макс.кол-во панелей (из настроек)
    property FrmEditMode: TEditMode read FFrmEditMode write FFrmEditMode;
    property PnlObjList: TPnlObjList read FPnlObjList write SetPnlObjList;//список объектов-фреймов
    property IsPhoneBaseConn: Boolean read FIsPhoneBaseConn write FIsPhoneBaseConn;
    property PhoneBase: TIBDataBase read FPhoneBase write FPhoneBase;
    property PhoneTrans: TIBTransaction read FPhoneTrans write FPhoneTrans;
    property CountryCode: PtrInt read FCountryCode;
    procedure TempAct(Sender: TObject);
  end;

var
  frmPhonesEdit: TfrmPhonesEdit;

implementation


{$R *.lfm}

{ TfrmPhonesEdit }

procedure TfrmPhonesEdit.FormCreate(Sender: TObject);
var
  i: PtrInt = -1;
  txtlen: PtrInt = 0;
begin
  FMaxPnlCount:= 5;//по умолчанию, если не задано
  FPnlTagCounter:= 0;//инициализируем счетчик
  scrboxPhonesPnl.BorderStyle:= bsNone;
  FrmEditMode:= emAdd;//по умолчанию
  FIsPhoneBaseConn:= False;//по умолчанию
  FPhoneBase:= nil;//инициируем
  FPhoneTrans:= nil;//инициируем
  FCountryCode:= -1;

  PnlObjList:= TPnlObjList.Create(True);

  {$IFDEF MSWINDOWS}
    btnLeft.Caption:= 'Сохранить';
    btnRight.Caption:= 'Отмена';
    btnLeft.OnClick:= @ActbtnOKExecute;
    btnRight.OnClick:= @ActbtnCancelExecute;
  {$ELSE}
    btnLeft.Caption:= 'Отмена';
    btnRight.Caption:= 'Сохранить';
    btnLeft.OnClick:= @ActbtnCancelExecute;
    btnRight.OnClick:= @ActbtnOKExecute;
  {$ENDIF}

  for i:= 0 to Pred(Self.ControlCount) do
    if TObject(Self.Controls[i]).InheritsFrom(TButton) then
    begin
      TButton(Self.Controls[i]).AutoSize:= True;
      if not TButton(Self.Controls[i]).Equals(btnPhoneBaseConn) then
        if (txtlen < Self.Canvas.TextWidth(TButton(Self.Controls[i]).Caption)) then
          txtlen:= Self.Canvas.TextWidth(TButton(Self.Controls[i]).Caption);
    end;

  for i:= 0 to Pred(Self.ControlCount) do
    if TObject(Self.Controls[i]).InheritsFrom(TButton) then
    begin
      TButton(Self.Controls[i]).AutoSize:= False;

      if TButton(Self.Controls[i]).Equals(btnPhoneBaseConn)
      then
        TButton(Self.Controls[i]).Width:= Self.Canvas.TextWidth(btnPhoneBaseConn.Caption)
                                                          + Self.Canvas.TextWidth('W') * 2
      else
        TButton(Self.Controls[i]).Width:= txtlen + Self.Canvas.TextWidth('W') * 2;
    end;

  //задаем инимальную ширину, чтобы кнопки не наезжали друг на друга
  Self.Constraints.MinWidth:= 0;

  for i:= 0 to Pred(Self.ControlCount) do
    if TObject(Self.Controls[i]).InheritsFrom(TButton) then
      Self.Constraints.MinWidth:= Self.Constraints.MinWidth
                                    + TButton(Self.Controls[i]).Width
                                      + TButton(Self.Controls[i]).BorderSpacing.Around;

  { #todo : реализовать подключение к таблицам с кодами регионов }
end;

procedure TfrmPhonesEdit.FormShow(Sender: TObject);
begin
  ActPnlAddExecute(Sender);
end;

procedure TfrmPhonesEdit.SetPnlObjList(AValue: TPnlObjList);
begin
  if FPnlObjList = AValue then Exit;
  FPnlObjList:= AValue;
end;

procedure TfrmPhonesEdit.TempAct(Sender: TObject);
begin
  ActChbMobileStateChgExecute(PnlObjList.Items[PnlObjList.IndexOf(TfrPhonesPnl(Sender))]);
end;

procedure TfrmPhonesEdit.ActPnlAddExecute(Sender: TObject);
var
  frPhonesPnl: TfrPhonesPnl = Nil;
  i: PtrInt = -1;
  frIndex: PtrInt = -1; //индекс вставленного элемента
begin
  if not Assigned(PnlObjList) then Exit;

  if (PnlObjList.Count > Pred(MaxPnlCount)) then Exit; //если превысили лимит
  if (PnlObjList.Count > 1) and (FrmEditMode = emEdit) then Exit;

  Self.BeginFormUpdate;
  try
    try
      frPhonesPnl:= TfrPhonesPnl.Create(Self);
      frIndex:= PnlObjList.Add(frPhonesPnl);

      with frPhonesPnl do
      begin
        Inc(FPnlTagCounter);
        Name:= 'frPhonesPnl_' + IntToStr(FPnlTagCounter);
        Tag:= frIndex;
        Parent:= scrboxPhonesPnl;
        AnchorSideLeft.Control:= Parent;
        AnchorSideRight.Control:= Parent;
        AnchorSideLeft.Side:= asrLeft;
        AnchorSideRight.Side:= asrRight;
        chbMainContact.Checked:= (frIndex = 0);//чекаем только на верхней панели
        chbMainContact.OnChange:= @ActChbMainContactCheckExecute;
        chbMobile.OnChange:= @ActChbMobileStateChgExecute;
        frPhonesPnl.OnDblClick:= @TempAct;

        if (frIndex = 0) //первый элемент списка (т.е. самый верхний фрэйм на форме)
        then
          begin
            AnchorSideTop.Side:= asrTop;
            AnchorSideTop.Control:= Parent;
          end
        else
          begin
            AnchorSideTop.Side:= asrBottom;
            AnchorSideTop.Control:= PnlObjList.Items[Pred(frIndex)];
          end;

        //рисуем красивые кнопки
        for i:= 0 to Pred(ControlCount) do
          if TObject(Controls[i]).InheritsFrom(TButton) then
          begin
            TButton(Controls[i]).AutoSize:= False;
            {$IFDEF MSWINDOWS}
              TButton(Controls[i]).Width:= edtCountryCode.Height;
            {$ELSE}
              {$IFDEF LINUX}
                TButton(Controls[i]).Width:=
                  Canvas.TextWidth(TButton(Controls[i]).Caption) + 2 * Canvas.TextWidth('H');
              {$ELSE}
                TButton(Controls[i]).Width:=
                  Canvas.TextWidth(TButton(Controls[i]).Caption) + 2 * Canvas.TextWidth('0');
              {$ENDIF}
            {$ENDIF}
          end;

        {$IFDEF MSWINDOWS}
          btnPnlLeft.Caption:= '+';
          btnPnlRight.Caption:= '-';
          btnPnlLeft.OnClick:= @ActPnlAddExecute;
          btnPnlRight.OnClick:= @ActPnlRemoveExecute;
        {$ELSE}
          btnPnlLeft.Caption:= '-';
          btnPnlRight.Caption:= '+';
          btnPnlLeft.OnClick:= @ActPnlRemoveExecute;
          btnPnlRight.OnClick:= @ActPnlAddExecute;
        {$ENDIF}

        Anchors:= [akLeft, akTop, akRight];
        Visible:= True;
        ActShowHidePnlObjListBtnsExecute(PnlObjList.Items[frIndex]);//отображаем/скрываем кнопки
        AutoSize:= True;

        edtCountryCode.Clear;
        edtRegionCode.Clear;
        edtNumber.Clear;
        memoNote.Clear;

        if edtCountryCode.CanSetFocus then edtCountryCode.SetFocus;
        ActUIRefreshExecute(Sender);//обновляем UI  соответственно настройкам и флагам
      end;
    except
      on E:Exception do
      begin
        if Assigned(frPhonesPnl) then FreeAndNil(frPhonesPnl);
        ShowMessage(Format('Ой, что-то пошло не так... %s' +
        'На форме "%s" произошла ошибка: "%s"',[sLineBreak,Self.Name, E.Message]));
        Exit;
      end;
    end;
  finally
    Self.EndFormUpdate;
  end;
end;

procedure TfrmPhonesEdit.ActChbMainContactsStateChgExecute(Sender: TObject);
var
  i: PtrInt = -1;
begin
  if not TObject(Sender).InheritsFrom(TfrPhonesPnl) then Exit;

  for i:= 0 to Pred(PnlObjList.Count) do
    PnlObjList.Items[i].chbMainContact.State:= cbUnchecked;

  TfrPhonesPnl(Sender).chbMainContact.State:= cbChecked;
end;

procedure TfrmPhonesEdit.ActChbMobileStateChgExecute(Sender: TObject);
var
  ParentCtrl: TfrPhonesPnl = nil;
begin
  if TObject(Sender).InheritsFrom(TfrPhonesPnl)
    then ParentCtrl:= TfrPhonesPnl(Sender)
    else
      if TObject(Sender).InheritsFrom(TCheckBox)
        then ParentCtrl:= TfrPhonesPnl(TCheckBox(Sender).Parent)
        else Exit;

  { #todo : Реализовать подбор маски edtRegionCode в зависимости от выбранной страны }
end;

procedure TfrmPhonesEdit.ActChbMainContactCheckExecute(Sender: TObject);
begin
  if not TObject(Sender).InheritsFrom(TCheckBox) then Exit;
  ActChbMainContactsStateChgExecute(TfrPhonesPnl(TCheckBox(Sender).Parent));
end;

procedure TfrmPhonesEdit.ActPnlRemoveExecute(Sender: TObject);
var
  CurIndex: PtrInt = -1;//индекс текущей (удаляемой) панели
  SenderPrt: TfrPhonesPnl = nil;//родитель кнопки-сендера
begin
  if not TObject(Sender).InheritsFrom(TButton) then Exit;

  Self.BeginFormUpdate;
  try
    try
      SenderPrt:= TfrPhonesPnl(TButton(Sender).Parent);
      if SenderPrt.Equals(PnlObjList.First)
      then
        Exit //верхняя панель не удаляемая
      else
        begin
          CurIndex:= PnlObjList.IndexOf(SenderPrt);//получаем индекс удаляемой панели
          if not SenderPrt.Equals(PnlObjList.Last) //панель посередине
          then
            begin
              //привязываем (относительно текущей панели) верхний край ниже лежащей панели к выше лежащей
              PnlObjList.Items[Succ(CurIndex)].AnchorSideTop.Control:= PnlObjList.Items[Pred(CurIndex)];

              //помечаем chbMainContact на следующем (от удаляемого) фрейме, если он был помечен
              if SenderPrt.chbMainContact.Checked then
                ActChbMainContactsStateChgExecute(PnlObjList.Items[Succ(CurIndex)]);
            end
          else // это PnlObjList.Last
            //помечаем chbMainContact на предыдущем (от удаляемого) фрейме, если он был помечен
            if SenderPrt.chbMainContact.Checked then
              ActChbMainContactsStateChgExecute(PnlObjList.Items[Pred(CurIndex)]);

          PnlObjList.Delete(CurIndex);
          PnlObjList.TrimExcess;//приводим емкость в соответствии с кол-вом элементов
        end;
    except
      on E:Exception do
      begin
        ShowMessage(Format('Ой, что-то пошло не так... %s' +
        'На форме "%s" произошла ошибка: "%s"',[sLineBreak,Self.Name, E.Message]));
        Exit;
      end;
    end;
  finally
    Self.EndFormUpdate;
  end;
end;

procedure TfrmPhonesEdit.ActbtnCancelExecute(Sender: TObject);
begin
  Self.ModalResult:= mrCancel;
end;

procedure TfrmPhonesEdit.ActbtnOKExecute(Sender: TObject);
var
  i: PtrInt = -1;
  function IsItemEmpty(const aIndex: PtrInt): Boolean;
  begin
    Result:= (UTF8Trim(PnlObjList.Items[aIndex].edtCountryCode.Text) = '')
              and (UTF8Trim(PnlObjList.Items[aIndex].edtRegionCode.Text) = '')
              and (UTF8Trim(PnlObjList.Items[aIndex].edtNumber.Text) = '');
  end;
begin
  for i:= Pred(PnlObjList.Count) downto 0 do
    if IsItemEmpty(i)
    then
      begin
        PnlObjList.Delete(i);
        PnlObjList.TrimExcess;
      end
    else
      if (UTF8Trim(PnlObjList.Items[i].edtNumber.Text) = '') then
      begin
        scrboxPhonesPnl.ScrollInView(PnlObjList.Items[i].edtNumber);
        if PnlObjList.Items[i].edtNumber.CanSetFocus
          then PnlObjList.Items[i].edtNumber.SetFocus;

        Application.MessageBox(PChar('Не указан телефонный номер'),
                                PChar('Неполные данные'),
                                MB_ICONINFORMATION);
        Exit;
      end;

  Self.ModalResult:= mrOK;
end;

procedure TfrmPhonesEdit.ActShowHidePnlObjListBtnsExecute(Sender: TObject);
var
  i: PtrInt = -1;
begin
  if not TObject(Sender).InheritsFrom(TfrPhonesPnl) then Exit;
  if (PnlObjList.Count = 0) then Exit;

  if (Self.FrmEditMode = emEdit) then
  begin
    PnlObjList.Items[i].btnPnlLeft.Visible:= False;
    PnlObjList.Items[i].btnPnlRight.Visible:= False;
    Exit;
  end;

  Self.BeginFormUpdate;
  try
    for i := 0 to Pred(PnlObjList.Count) do
    begin
      {$IFDEF MSWINDOWS}
      PnlObjList.Items[i].btnPnlLeft.Visible:= (i < Pred(MaxPnlCount));
      PnlObjList.Items[i].btnPnlRight.Visible:= (i > 0);
      {$ELSE}
      PnlObjList.Items[i].btnPnlLeft.Visible:= (i > 0);
      PnlObjList.Items[i].btnPnlRight.Visible:= (i < Pred(MaxPnlCount));
      {$ENDIF}
    end;
  finally
    Self.EndFormUpdate;
  end;

end;

procedure TfrmPhonesEdit.ActUIRefreshExecute(Sender: TObject);
var
  i: PtrInt = -1;
begin
  btnPhoneBaseConn.Enabled:= not IsPhoneBaseConn;

  if (PnlObjList.Count > 0) then
    for i:= 0 to Pred(PnlObjList.Count) do
    begin
      PnlObjList.Items[i].btnSelectCountryCode.Enabled:= IsPhoneBaseConn;
      PnlObjList.Items[i].btnSelectRegionCode.Enabled:= IsPhoneBaseConn;
    end;
end;

procedure TfrmPhonesEdit.btnPhoneBaseConnClick(Sender: TObject);
begin
  //времянка для отладки
  FPhoneBase:= IBDatabase1;
  FPhoneTrans:= IBTransaction1;

  if not Assigned(PhoneBase) or not Assigned(PhoneTrans) then Exit;


  if FPhoneBase.Connected then Exit;

  try
    FPhoneBase.Connected:= True;

  except
    on E: Exception do
    ShowMessage(e.Message);
  end;

  IsPhoneBaseConn:= Assigned(FPhoneBase) and FPhoneBase.Connected;
  ActUIRefreshExecute(Sender);
end;

procedure TfrmPhonesEdit.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if Assigned(PnlObjList) then PnlObjList.Free;
end;

end.

