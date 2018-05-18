#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3
#pragma ModuleName=KMSpectrumViewer

#ifndef KMshowProcedures
#pragma hide = 1
#endif

//******************************************************************************
//	レイヤーデータから1本のスペクトルを抜き出して表示するためのパネルを表示
//******************************************************************************
//-------------------------------------------------------------
//	右クリック用
//-------------------------------------------------------------
Static Function rightclickDo()
	pnl(WinName(0,1))
End

Static Function pnl(String LVName)
	
	//	既に表示されているパネルがあればそれをフォーカスして終了
	String pnlName = GetUserData(LVName,"","KMSpectrumViewerPnl")
	if (strlen(pnlName))
		DoWindow/F $StringFromList(0,pnlName)
		return 0
	endif
	pnlName = UniqueName("Graph",6,0)
	
	Wave srcw =  KMGetImageWaveRef(LVName)
	Variable isMLS = KMisUnevenlySpacedBias(srcw)
	if (isMLS)		//	Nanonis MLSモードでのデータの場合は、横軸用ウエーブを一時データフォルダ内に用意する
		Wave xw = pnlInit(srcw, pnlName)
	endif
	
	//  パネル表示
	if (isMLS)
		Display/K=1 srcw[0][0][] vs xw as NameOfWave(srcw) + "[0][0][]"
	else
		Display/K=1 srcw[0][0][] as NameOfWave(srcw) + "[0][0][]"
	endif
	AutoPositionWindow/E/M=0/R=$LVName $pnlName
	
	//  マウス位置取得ウインドウの設定
	pnlSetRelation(LVname, pnlName)
	
	//  グラフ詳細
	ModifyGraph/W=$pnlName width=180*96/screenresolution, height=180*96/screenresolution, gfSize=10
	ModifyGraph/W=$pnlName margin(top)=8,margin(right)=12,margin(bottom)=36,margin(left)=44
	ModifyGraph/W=$pnlName tick=0,btlen=5,mirror=0,lblMargin=2
	if (isMLS)
		ModifyGraph/W=$pnlName rgb=(KM_CLR_LINE_R, KM_CLR_LINE_G, KM_CLR_LINE_B)
		ModifyGraph/W=$pnlName axRGB=(KM_CLR_LINE_R, KM_CLR_LINE_G, KM_CLR_LINE_B)
		ModifyGraph/W=$pnlName tlblRGB=(KM_CLR_LINE_R, KM_CLR_LINE_G, KM_CLR_LINE_B)
		ModifyGraph/W=$pnlName alblRGB=(KM_CLR_LINE_R, KM_CLR_LINE_G, KM_CLR_LINE_B)
		ModifyGraph/W=$pnlName gbRGB=(KM_CLR_BG_R, KM_CLR_BG_G, KM_CLR_BG_B)
		ModifyGraph/W=$pnlName wbRGB=(KM_CLR_BG_R, KM_CLR_BG_G, KM_CLR_BG_B)
	endif
	
	//	コントロールバー
	ControlBar 48
	SetVariable pV title="p:", pos={5,6}, size={72,15}, proc=KMSpectrumViewer#pnlSetVar, win=$pnlName
	SetVariable pV bodyWidth=60, value=_NUM:0, limits={0,DimSize(srcw,0)-1,1}, win=$pnlName
	SetVariable qV title="q:", pos={85,6}, size={72,15}, proc=KMSpectrumViewer#pnlSetVar, win=$pnlName
	SetVariable qV bodyWidth=60, value=_NUM:0, limits={0,DimSize(srcw,1)-1,1}, win=$pnlName
	TitleBox xyT pos={4,30}, frame=0, win=$pnlName
	
	ModifyControlList ControlNameList(pnlName,";","*") focusRing=0, win=$pnlName
	
	SetWindow $pnlName userData(live)="0"
	
	DoUpdate/W=$pnlName
	ModifyGraph/W=$pnlName width=0, height=0
End
//-------------------------------------------------------------
//	パネル初期設定
//-------------------------------------------------------------
Static Function/WAVE pnlInit(Wave srcw, String pnlName)
	String dfSav = KMNewTmpDf(pnlName,"KMSpectrumViewerPnl")		//  一時データフォルダ作成
	Duplicate/O KMGetBias(srcw, 1) $(NameOfWave(srcw)+"_b")/WAVE=xw	//	MLS対応横軸ウエーブ
	SetDataFolder $dfSav
	return xw
End
//-------------------------------------------------------------
//	指定されたウインドウについて、マウス位置取得ウインドウとスペクトル表示
//	ウインドウとしての関係を設定する
//-------------------------------------------------------------
Static Function pnlSetRelation(String mouseWin, String specWin)
	String list = GetUserData(mouseWin, "", "KMSpectrumViewerPnl")
	SetWindow $mouseWin userData(KMSpectrumViewerPnl)=AddListItem(specWin, list)
	SetWindow $mouseWin hook(KMSpectrumViewerPnl)=KMSpectrumViewer#pnlHookParent
	
	list = GetUserData(specWin, "", "parent")
	SetWindow $specWin userData(parent)=AddListItem(mouseWin, list)
	SetWindow $specWin hook(self)=KMSpectrumViewer#pnlHook
End
//-------------------------------------------------------------
//	指定されたウインドウについて、マウス位置取得ウインドウとスペクトル表示
//	ウインドウとしての関係を解除する
//-------------------------------------------------------------
Static Function pnlResetRelation(String mouseWin, String specWin)
	
	String newList
	
	//	マウス位置取得ウインドウについての処理
	//	指定されたスペクトル表示ウインドウをリストから削除する
	newList = RemoveFromList(specWin, GetUserData(mouseWin, "", "KMSpectrumViewerPnl"))
	if (ItemsInlist(newList))
		SetWindow $mouseWin userData(KMSpectrumViewerPnl)=newList
	else
		//	リストからスペクトル表示ウインドウを削除した結果としてリストが空になったら
		//	マウス位置取得ウインドウの役割を解除して良い
		SetWindow $mouseWin hook(KMSpectrumViewerPnl)=$""
		SetWindow $mouseWin userData(KMSpectrumViewerPnl)=""
	endif
	
	//	スペクトル表示ウインドウについての処理
	//	指定されたマウス位置取得ウインドウをリストから削除する
	//	リストが空になってもスペクトル表示ウインドウのフック関数は解除しない(メニュー等の表示が必要)
	DoWindow $specWin	//	KM非動作中にウインドウが閉じられた場合の処理からもこの関数が呼ばれることに備えて
	if (V_Flag)
		newList = RemoveFromList(mouseWin, GetUserData(specWin, "", "parent"))
		SetWindow $specWin userData(parent)=newList
	endif
End


//******************************************************************************
//	フック関数
//******************************************************************************
//-------------------------------------------------------------
//	スペクトル表示用グラフのフック関数
//-------------------------------------------------------------
Static Function pnlHook(STRUCT WMWinHookStruct &s)
	switch (s.eventCode)
		case 2:	//	kill
			pnlHookClose(s)
			return 0
		case 3:	//	mousedown
			GetWindow $s.winName, wsizeDC
			if (s.mouseLoc.v > V_top)	//	コントロールバー外なら
				return 0
			elseif (s.eventMod & 16)	//	右クリック
				PopupContextualMenu/N "KMSpectrumViewerMenu"
			endif
			return 1
		case 4:	//	mouse move
			if (!(s.eventMod&0x02))	//	shiftキーが押されていなければ
				KMDisplayCtrlBarUpdatePos(s)		//	マウス位置座標表示
			endif
			return 0
		case 11: 	//	keyboard
			if (s.keycode == 27)		//	esc
				pnlHookClose(s)
				KillWindow $s.winName
			elseif (s.keycode >= 28 && s.keycode <= 31)	//	arrows
				pnlHookArrows(s)
			endif
			return 1
		case 13: //	renamed
			pnlHookRename(s)
			return 0
		default:
			return 0
	endswitch
End
//-------------------------------------------------------------
//	親ウインドウ用のフック関数
//-------------------------------------------------------------
Static Function pnlHookParent(STRUCT WMWinHookStruct &s)	
	switch (s.eventCode)
		case 2:	//	kill
			String specWinList = GetUserData(s.winName, "", "KMSpectrumViewerPnl")
			Variable i, n = ItemsInList(specWinList)
			for (i = 0; i < n; i += 1)
				pnlResetRelation(s.winName, StringFromList(i, specWinList))
			endfor
			break
		case 3:	//	mouse down
			SetWindow $s.winName userData(mousePressed)="1"
			break
		case 4:	//	mouse moved
			if (s.eventMod&2^1)	//	shiftキーが押されていたら動作しない
				return 0
			endif
			pnlHookMouseMov(s)
			break
		case 5:	//	mouse up
			GetWindow $s.winName, wsizeDC
			if (s.mouseLoc.h < V_left || s.mouseLoc.h > V_right || s.mouseLoc.v > V_bottom || s.mouseLoc.v < V_top)
				return 0
			elseif (!strlen(GetUserData(s.winName,"","mousePressed")))	//	カーソルをドラッグで動かした場合に相当
				return 0
			endif
			//	以下表示領域で有効
			if (s.eventMod&2^3)	//  ctrlキーが押されていたらウエーブを出力
				saveSpectrum(s.winName)
			else
				pnlHookClick(s)
			endif
			SetWindow $s.winName userData(mousePressed)=""
			break
		case 7:	//	cursor moved
			pnlHookCsrMov(s)
			SetWindow $s.winName userData(mousePressed)=""
			break
		case 13:	//	renamed
			pnlHookRename(s)
			break
		default:
	endswitch
	
	return 0
End
//-------------------------------------------------------------
//	スペクトル表示ウインドウが閉じられたときの動作
//	スペクトル表示関係の解除と、一時データフォルダを使用していた場合はその削除
//-------------------------------------------------------------
Static Function pnlHookClose(STRUCT WMWinHookStruct &s)
	//	マウス位置取得ウインドウとの関係を解除する
	String mouseWinList = GetUserData(s.winName, "", "parent")
	Variable i, n = ItemsInList(mouseWinList)
	for (i = 0; i < n; i += 1)
		pnlResetRelation(StringFromList(i, mouseWinList), s.winName)
	endfor
	
	Wave/Z xw = pnlGetSrc(s.winName, 1)
	if (WaveExists(xw))	//	MLSデータの場合
		SetWindow $s.winName userData(dfTmp)=GetWavesDataFolder(xw,1)	//	一時データフォルダを削除するルーチンを使用するため
	endif
	
	//	一時データフォルダの削除(あれば)、ヘルプウインドウを閉じる(あれば)
	KMonClosePnl(s.winName)
End
//-------------------------------------------------------------
//	ウインドウの名前が変更された場合の動作
//	リストに含まれている古い名前を新しい名前に更新する
//-------------------------------------------------------------
Static Function pnlHookRename(STRUCT WMWinHookStruct &s)
	String winListStr	//	名前の変更を伝える相手のウインドウの名前のリスト
	String key
	strswitch (GetRTStackInfo(2))	//	呼び出し元関数名で判別
		case "pnlHook" :		//	スペクトル表示ウインドウの名前が変更された場合
			winListStr = GetUserData(s.winName, "", "parent")
			key = "KMSpectrumViewerPnl"
			break
		case "pnlHookParent":	//	マウス位置取得ウインドウの名前が変更された場合
			winListStr = GetUserData(s.winName, "", "KMSpectrumViewerPnl")
			key = "parent"
			break
		default:
	endswitch
	
	//	リストに含まれている古い名前を新しいものに変更
	int i, n = ItemsInList(winListStr)
	for (i = 0; i < n; i++)
		String win = StringFromList(i, winListStr)
		String list = GetUserData(win, "", key)
		list = AddListItem(s.winName, RemoveFromList(s.oldWinName, list))
		SetWindow $win userData($key)=list
	endfor
	
	//	スペクトル表示ウインドウの名前が変更され、そのウインドウでMLSモードのデータを表示している場合には、
	//	一時データフォルダの名前を変更する必要がある (そうしないと後々名前の競合が起こる可能性がある)
	if (!CmpStr(key, "KMSpectrumViewerPnl"))
		Wave/Z xw = pnlGetSrc(s.winName, 1)
		if (WaveExists(xw))		//	MLS
			RenameDataFolder $GetWavesDataFolder(xw,1), $s.winName
		endif
	endif
End
//-------------------------------------------------------------
//	マウス動作時の表示動作
//	マウス位置を取得してスペクトル表示を更新する
//-------------------------------------------------------------
Static Function pnlHookMouseMov(STRUCT WMWinHookStruct &ws)
	STRUCT KMMousePos s
	if (KMGetMousePos(s, grid=1, winhs=ws))
		return 0
	endif
	
	String pnlListStr = GetUserData(s.winhs.winName,"","KMSpectrumViewerPnl")	//	更新対象となるウインドウのリスト
	int i, n = ItemsInList(pnlListStr)
	for (i = 0; i < n; i++)
		String pnlName = StringFromList(i, pnlListStr)
		DoWindow $pnlName
		if (!V_Flag)	//	KM非動作中に当該ウインドウが閉じられた場合に備えて
			pnlResetRelation(s.winhs.winName, pnlName)
		elseif (str2num(GetUserData(pnlName, "", "live")) == 0)
			pnlUpdateSpec(pnlName, s.p, s.q)	//	表示更新
		endif
	endfor
End
//-------------------------------------------------------------
//	カーソル動作時の表示動作
//	カーソル位置を取得してスペクトル表示を更新する
//-------------------------------------------------------------
Static Function pnlHookCsrMov(STRUCT WMWinHookStruct &ws)
	//	カーソルAが表示されていない場合には何もしない
	STRUCT KMCursorPos s
	if (KMGetCursor("A", ws.winName, s))
		return 0
	endif
	
	String pnlListStr = GetUserData(ws.winName,"","KMSpectrumViewerPnl")	//	更新対象となるウインドウのリスト
	int i, n = ItemsInList(pnlListStr)
	for (i = 0; i < n; i++)
		String pnlName = StringFromList(i, pnlListStr)
		if (str2num(GetUserData(pnlName, "", "live")) == 1)
			pnlUpdateSpec(pnlName, s.p, s.q)	//	表示更新
		endif
	endfor
End
//-------------------------------------------------------------
//	矢印キーが押された場合の動作
//	押された方向にスペクトル表示位置を動かす(ctrlが押されていたら10倍)
//-------------------------------------------------------------
Static Function pnlHookArrows(STRUCT WMWinHookStruct &s)
	String mouseWinList = GetUserData(s.winName,"","parent")
	int i, n = ItemsInList(mouseWinList)
	Make/N=10/FREE tw
	
	for (i = 0; i < n; i++)
		int step = (s.eventMod & 2) ? 10 : 1
		ControlInfo/W=$s.winName pV ;	Variable posp = V_Value
		ControlInfo/W=$s.winName qV ;	Variable posq = V_Value
		switch (s.keycode)
			case 28:		//	左
				posp = posp-step
				break
			case 29:		//	右
				posp = posp+step
				break
			case 30:		//	上
				posq = posq+step
				break
			case 31:		//	下
				posq = posq-step
				break
		endswitch
		pnlUpdateSpec(s.winName, posp, posq)	//	表示更新
	endfor
End
//-------------------------------------------------------------
//	クリックの場合の動作
//	クリック位置でのスペクトル表示を追加する
//-------------------------------------------------------------
Static Function pnlHookClick(STRUCT WMWinHookStruct &s)
	String specWinList = GetUserData(s.winName, "", "KMSpectrumViewerPnl")
	int i, n = ItemsInList(specWinList)
	
	for (i = 0; i < n; i++)
		String specWin = StringFromList(i, specWinList)
		String trcList = TraceNameList(specWin,";",1), trcName
		Wave srcw = pnlGetSrc(specWin, 0)
		Wave/Z xw = pnlGetSrc(specWin, 1)
		ControlInfo/W=$specWin pV ;	Variable posp = V_Value			//	クリック位置(現在位置)取得
		ControlInfo/W=$specWin qV ;	Variable posq = V_Value			//	同上
		sprintf trcName, "%s[%d][%d][]", NameOfWave(srcw), posp, posq		//	追加されるトレースの名前
		//	追加表示されたスペクトルがあればそれを削除する
		if (ItemsInList(trcList) > 1)
			RemoveFromGraph/W=$specWin $StringFromList(0, trcList)	//	表示順が変更されているので、0番目のトレースを削除する
		endif
		//	スペクトル追加
		if (WaveExists(xw))		//	MLS
			AppendToGraph/W=$specWin srcw[posp][posq][]/TN=$trcName vs xw
		else
			AppendToGraph/W=$specWin srcw[posp][posq][]/TN=$trcName
		endif
		//	色変更
		Variable tr, tg, tb
		if (WaveExists(xw))		//	MLS
			//	一時データフォルダを使用しているので、黒背景の色セットを使う
			tr = KM_CLR_LINE2_R;	tg = KM_CLR_LINE2_G;	tb = KM_CLR_LINE2_B
		else
			//	元からあるスペクトルの表示色(ユーザー設定値が使用される)の反転色を使用
			sscanf StringByKey("rgb(x)", TraceInfo(specWin, NameOfWave(srcw), 0), "="), "(%d,%d,%d)", tr, tg, tb
			tr = 65535 - tr ;	tg = 65535 - tg ;	tb = 65535 - tb
		endif
		ModifyGraph/W=$specWin rgb($trcName)=(tr, tg, tb)
		//	表示順変更
		ReorderTraces/W=$specWin $NameOfWave(srcw), {$trcName}
	endfor
End

//******************************************************************************
//	パネルコントロール
//******************************************************************************
//-------------------------------------------------------------
//	値設定
//-------------------------------------------------------------
Static Function pnlSetVar(STRUCT WMSetVariableAction &s)
	if (s.eventCode == -1)
		return 1
	endif
	ControlInfo/W=$s.win pV ;	Variable posp = V_Value
	ControlInfo/W=$s.win qV ;	Variable posq = V_Value
	pnlUpdateSpec(s.win, posp, posq)	//	表示更新
End


//******************************************************************************
//	補助関数
//******************************************************************************
//-------------------------------------------------------------
//	表示されているスペクトルのソースウエーブを返す
//-------------------------------------------------------------
Static Function/WAVE pnlGetSrc(String pnlName, int axis)	//	axis 0: y, 1: x
	
	String trcList = TraceNameList(pnlName,";",1)
	Wave/Z srcw = TraceNameToWaveRef(pnlName, StringFromList(0, trcList))	//	表示されているスペクトルは全て同じウエーブに由来するので、何番目のトレースでも構わない
	
	if (!WaveExists(srcw))
		return $""
	elseif (axis)
		return XWaveRefFromTrace(pnlName, NameOfWave(srcw))
	else
		return srcw
	endif
End
//-------------------------------------------------------------
//	スペクトル等表示更新
//-------------------------------------------------------------
Static Function pnlUpdateSpec(String pnlName, Variable posp, Variable posq)
	//	この関数を呼び出した関数のスタック
	String callingStack = RemoveListItem(ItemsInList(GetRTStackInfo(0))-1, GetRTStackInfo(0))
	//	そのスタックに自分自身が含まれている場合には true
	Variable recursive = WhichListItem(GetRTStackInfo(1), callingStack) != -1
	if (recursive)
		return 0
	endif
	
	//	スペクトル表示の更新
	Wave srcw = pnlGetSrc(pnlName, 0)
	posp = limit(posp, 0, DimSize(srcw,0)-1)
	posq = limit(posq, 0, DimSize(srcw,1)-1)
	ReplaceWave/W=$pnlName trace=$NameOfWave(srcw), srcw[posp][posq][]
	
	//	パネル表示の更新
	String titleStr
	sprintf titleStr "%s [%d][%d][]", NameOfWave(srcw), posp, posq
	DoWindow/T $pnlName, titleStr
	SetVariable pV value=_NUM:posp, win=$pnlName
	SetVariable qV value=_NUM:posq, win=$pnlName
	
	DoUpdate/W=$pnlName
	
	//	カーソル位置を使用している場合、かつ、カーソル位置変化に伴う呼び出しでない場合
	//	(SetVariableの値変化やスペクトル表示ウインドウでの矢印キー)には、カーソルを移動する
	if (str2num(GetUserData(pnlName,"","live"))==1 && CmpStr(GetRTStackInfo(2), "pnlHookCsrMov"))
		STRUCT KMCursorPos s ;	s.isImg = 1;	s.p = posp ;	s.q = posq
		String win, mouseWinList = GetUserData(pnlName,"","parent")
		Variable i, n = ItemsInList(mouseWinList)
		for (i = 0; i < n; i += 1)
			win = StringFromList(i, mouseWinList)
			KMSetCursor("A", win, 0, s)
		endfor
	endif
End
//-------------------------------------------------------------
//	SpectrumViewerの右クリックメニュー
//-------------------------------------------------------------
Menu "KMSpectrumViewerMenu", dynamic, contextualmenu
	SubMenu "Live Update"
		KMSpectrumViewer#rightclickMenuLive(), KMSpectrumViewer#rightclickDoLive()
	End
	SubMenu "Target window"
		KMSpectrumViewer#rightclickMenuTarget(WinName(0,1)), KMSpectrumViewer#rightclickDoTarget()
	End
	SubMenu "Complex"
		KMSpectrumViewer#rightclickMenuComplex(), KMSpectrumViewer#rightclickDoComplex()
	End
	"Save", KMSpectrumViewer#saveSpectrum(WinName(0,1))
	"-"
	"Help", KMOpenHelpNote("spectrumviewer",pnlName=WinName(0,1),title="Spectrum Viewer")
End
//-------------------------------------------------------------
//	複素数表示を変更する
//-------------------------------------------------------------
Static Function rightclickDoComplex()
	GetLastUserMenuInfo
	ModifyGraph/W=$WinName(0,1) cmplxMode=V_Value
End

Static Function/S rightclickMenuComplex()
	String win = WinName(0,1)
	int isComplex = WaveType(pnlGetSrc(win,0)) & 0x01
	if (isComplex)
		int mode = NumberByKey("cmplxMode(x)",TraceInfo(win, "", 0),"=")
		//	他次元ウエーブを表示している場合には real & imaginary は無効なので、返ってくるmodeは1以上
		return KMAddCheckmark(mode-1, "real only;imaginary only;magnitude;phase in radian")
	else
		return ""
	endif
End
//-------------------------------------------------------------
//	座標取得元を変更する
//-------------------------------------------------------------
Static Function rightclickDoLive()
	GetLastUserMenuInfo
	SetWindow $WinName(0,1) userData(live)=num2str(V_Value-1)
End

Static Function/S rightclickMenuLive()
	String win = WinName(0,1)
	int num = strlen(win) ? str2num(GetUserData(win,"","live")) : 0
	return KMAddCheckmark(num, "Mouse;Cursor A;None;")
End
//-------------------------------------------------------------
//	マウス座標を取得するウインドウを変更する
//-------------------------------------------------------------
Static Function rightclickDoTarget()
	String specWin = WinName(0,1)
	GetLastUserMenuInfo
	String mouseWin = StringFromList(V_value-1,GetUserData(specWin,"","target"))
	if (WhichListItem(mouseWin, GetUserData(specWin, "", "parent")) == -1)
		pnlSetRelation(mouseWin, specWin)
	else
		pnlResetRelation(mouseWin, specWin)
	endif
End
//-------------------------------------------------------------
//	マウス座標を取得するウインドウのリストを作成する
//		KM LineSpectra.ipfからも使用されている
//-------------------------------------------------------------
Static Function/S rightclickMenuTarget(String pnlName)
	//	現在使われているウインドウの判別に使う文字列を得る
	//	呼び出し元関数が含まれているファイル名で判別する
	//	(呼び出し元関数はいずれにせよ pnlHook)
	String chdPnl
	if (strsearch(GetRTStackInfo(3),"KM SpectrumViewer.ipf",0) >= 0)
		chdPnl = "KMSpectrumViewerPnl"
		Wave/Z srcw = pnlGetSrc(pnlName, 0)		
	elseif (strsearch(GetRTStackInfo(3),"KM LineSpectra.ipf",0) >= 0)
		chdPnl = "KMLineSpectraPnl"
		Wave/Z srcw = $GetUserData(pnlName, "", "src")
	else
		return ""	//	呼び出し元に関する制限、かつ、ウインドウが表示されていない場合
	endif
	
	if (!WaveExists(srcw))
		return ""
	endif
	
	String allList = WinList("*",";","WIN:1,VISIBLE:1"), win
	String rtnList = ""	//	メニュー表示用文字列
	String grfList = ""		//	メニュー選択時に使用されるグラフリスト
	int i, n
	
	for (i = 0, n = ItemsInList(allList); i < n; i += 1)
		win = StringFromList(i, allList)
		Wave/Z imgw = KMGetImageWaveRef(win)
		if (WaveExists(imgw) && DimSize(srcw,0) == DimSize(imgw,0) && DimSize(srcw,1) == DimSize(imgw,1))
			if (WhichListItem(pnlName, GetUserData(win, "", chdPnl)) != -1)
				rtnList += "\\M0:!" + num2char(18) + ":"+NameOfWave(imgw) + " (" + win + ");"	//	チェックがつき、選択不可
			else
				rtnList += "\\M0" + NameOfWave(imgw) + " (" + win + ");"
			endif
			grfList += win + ";"
		endif
	endfor
	SetWindow $pnlName userData(target)=grfList
	
	return rtnList
End
//-------------------------------------------------------------
//	指定点におけるウエーブを抜き出す
//-------------------------------------------------------------
Static Function/WAVE saveSpectrum(String pnlName)
	String pnlListStr = GetUserData(pnlName,"","KMSpectrumViewerPnl")
	int n = ItemsInList(pnlListStr)
	if (n)	//	親ウインドウで ctrl + click された場合
		Make/N=(n)/WAVE/FREE rtnw = extractSpectrumEach(p, pnlListStr)
		return rtnw
	else		//	スペクトル表示ウインドウの右クリックメニューから呼ばれた場合
		return extractSpectrumEach(0, pnlName)
	endif
End

Static Function/WAVE extractSpectrumEach(int index, String list)
	String pnlName =StringFromList(index, list)
	Wave srcw = pnlGetSrc(pnlName, 0)
	ControlInfo/W=$pnlName pV ;	Variable posp = V_Value
	ControlInfo/W=$pnlName qV ;	Variable posq = V_Value	
	String result = NameOfWave(srcw)+"_p"+num2str(posp)+"q"+num2str(posq)
	result = CleanupName(result,1)
	
	DFREF dfrSav = GetDataFolderDFR()
	SetDataFolder GetWavesDataFolderDFR(srcw)
	
	MatrixOP/O $result/WAVE=extw = beam(srcw, posp, posq)
	if (KMisUnevenlySpacedBias(srcw))
		Duplicate/O KMGetBias(srcw, 1) $(NameOfWave(srcw)+"_b")
	else
		SetScale/P x DimOffset(srcw,2), DimDelta(srcw,2), WaveUnits(srcw,2), extw
	endif
	SetScale d 0, 0, StringByKey("DUNITS", WaveInfo(srcw,0)), extw
	
	SetDataFolder dfrSav
	return extw
End


//******************************************************************************
//	後方互換性
//******************************************************************************
Function KMSpectrumViewerPnlHook2(STRUCT WMWinHookStruct &s)
	SetWindow $s.winName hook(self)=KMSpectrumViewer#pnlHook
End
Function KMSpectrumViewerPnlHookParent(STRUCT WMWinHookStruct &s)
	SetWindow $s.winName hook(self)=KMSpectrumViewer#pnlHookParent
End
//	rev. 748以前
Function KMSpectrumViewerPnlHook(STRUCT WMWinHookStruct &s)
	KillControl/W=$s.winName liveC
	SetWindow $s.winName userData(live)="0"
	SetWindow $s.winName hook(self)=KMSpectrumViewer#pnlHook
	printf "**%s was updated.\r", s.winName
End
Function KMSpectrumViewerPnl2HookParent(STRUCT WMWinHookStruct &s)
	SetWindow $s.winName hook(KMSpectrumViewerPnl)=KMSpectrumViewer#pnlHookParent
End