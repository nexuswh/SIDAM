#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3
#pragma ModuleName = SIDAMSyncLayer

#include "SIDAM_Sync"
#include "SIDAM_Utilities_Image"
#include "SIDAM_Utilities_Panel"

#ifndef SIDAMshowProc
#pragma hide = 1
#endif

Static StrConstant SYNCKEY = "sync"

//@
//	Synchronize the layer shown in windows.
//
//	## Parameters
//	syncWinList : string
//		The list of windows to be synchronized. If a window(s) that is
//		not synchronized, it is synchronized with the remaining windows.
//		If all the windows are synchronized, stop synchronization.
//@
Function SIDAMSyncLayer(String syncWinList)

	STRUCT paramStruct s
	s.list = syncWinList
	if (validate(s))
		print s.errMsg
		return 1
	endif

	String fn = "SIDAMSyncLayer#hook"
	String data = "list:" + s.list
	SIDAMSync#set(SYNCKEY, fn, data)

	if (SIDAMSync#calledFromPnl())
		printf "%s%s(\"%s\")\r", PRESTR_CMD, GetRTStackInfo(1), s.list
	endif

	return 0
End

Static Function validate(STRUCT paramStruct &s)
	
	s.errMsg = PRESTR_CAUTION + "SIDAMSyncLayer gave error: "
	
	int i, n = ItemsInList(s.list)
	String grfName
	
	if (n < 2)
		GetWindow $StringFromList(0,s.list), hook($SYNCKEY)
		if(!strlen(S_Value))
			s.errMsg += "the window list must contain 2 windows or more."
			return 1
		endif
	endif
	
	for (i = 0; i < n; i++)
		grfName = StringFromList(i, s.list)
		if (!SIDAMWindowExists(grfName))
			s.errMsg += "the window list contains a window not found."
			return 1
		endif
		Wave/Z w = SIDAMImageWaveRef(grfName)
		if (!WaveExists(w) || WaveDims(w)!=3)
			s.errMsg += "the window list must contain only LayerViewer."
			return 1
		endif
	endfor
	
	return 0
End

Static Structure paramStruct
	String list
	String errMsg
EndStructure

Static Function menuDo()
	pnl(WinName(0,1))
End


Static Function hook(STRUCT WMWinHookStruct &s)
	switch (s.eventCode)
		case 0: 	//	activate
			//	In case a window(s) in the list had been closed before compiling
			SIDAMSync#updateList(s.winName, SYNCKEY)
			break
			
		case 2:		//	kill:
			SIDAMSync#reset(s.winName, SYNCKEY)
			break
			
		case 8:		//	modified
			//	In case a window(s) in the list had been closed before compiling
			SIDAMSync#updateList(s.winName, SYNCKEY)
			
			String win, list = SIDAMSync#getList(s.winName, SYNCKEY), fnName
			int i, n = ItemsInList(list), plane = SIDAMGetLayerIndex(s.winName)
			for (i = 0; i < n; i++)
				win = StringFromList(i, list)
				//	This is necessary to prevent a loop caused by mutual calling
				if (plane == SIDAMGetLayerIndex(win))
					continue
				endif
				fnName = SIDAMSync#pause(win, SYNCKEY)
				SIDAMSetLayerIndex(win, plane)
				SIDAMSync#resume(win, SYNCKEY, fnName)
			endfor
			break
			
		case 13:		//	renamed
			SIDAMSync#updateList(s.winName, SYNCKEY, oldName=s.oldWinName)
			break
	endswitch
	return 0
End


Static Function pnl(String LVName)
	NewPanel/HOST=$LVName/EXT=0/W=(0,0,282,255) as "Syncronize Layers"
	RenameWindow $LVName#$S_name, synclayer
	String pnlName = LVName + "#synclayer"
	
	String dfTmp = SIDAMSync#pnlInit(pnlName, SYNCKEY)
	
	SetWindow $pnlName hook(self)=SIDAMWindowHookClose
	SetWindow $pnlName userData(dfTmp)=dfTmp
	
	ListBox winL pos={5,12}, size={270,150}, frame=2, mode=4, win=$pnlName
	ListBox winL listWave=$(dfTmp+SIDAM_WAVE_LIST), win=$pnlName
	ListBox winL selWave=$(dfTmp+SIDAM_WAVE_SELECTED), win=$pnlName
	ListBox winL colorWave=$(dfTmp+SIDAM_WAVE_COLOR), win=$pnlName
	
	Button selectB title="Select / Deselect all", pos={10,172}, size={130,22}, proc=SIDAMSync#pnlButton, win=$pnlName
	Titlebox selectT title="You can also select a window by clicking it.", pos={10,200}, frame=0, fColor=(21760,21760,21760), win=$pnlName
	Button doB title="Do It", pos={10,228}, win=$pnlName
	Button doB disable=(DimSize($(dfTmp+SIDAM_WAVE_SELECTED),0)==1)*2, win=$pnlName
	Button doB userData(key)=SYNCKEY, userData(fn)="SIDAMSyncLayer", win=$pnlName
	Button cancelB title="Cancel", pos={201,228}, win=$pnlName
	ModifyControlList "doB;cancelB", size={70,22}, proc=SIDAMSync#pnlButton, win=$pnlName
	ModifyControlList ControlNameList(pnlName,";","*") focusRing=0, win=$pnlName
	
	SetActiveSubwindow $LVName
End
