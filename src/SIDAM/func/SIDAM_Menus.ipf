#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3
#pragma ModuleName=SIDAMMenus

#include "KM Fourier Peak"
#include "KM InfoBar"
#include "KM LayerViewer"
#include "KM ScaleBar"
#include "KM SyncAxisRange"
#include "KM SyncCursor"
#include "KM SyncLayer"
#include "KM Trace"
#include "SIDAM_Color"
#include "SIDAM_Compatibility_Old_Functions"
#include "SIDAM_Correlation"
#include "SIDAM_Display"
#include "SIDAM_FFT"
#include "SIDAM_Fourier_Filter"
#include "SIDAM_Fourier_Symmetrization"
#include "SIDAM_Histogram"
#include "SIDAM_LayerAnnotation"
#include "SIDAM_LineProfile"
#include "SIDAM_LineSpectra"
#include "SIDAM_LoadData"
#include "SIDAM_Position_Recorder"
#include "SIDAM_Preference"
#include "SIDAM_Range"
#include "SIDAM_Subtraction"
#include "SIDAM_SaveGraphics"
#include "SIDAM_SaveMovie"
#include "SIDAM_ShowParameters"
#include "SIDAM_SpectrumViewer"
#include "SIDAM_StartExit"
#include "SIDAM_Utilities_Help"
#include "SIDAM_Utilities_Image"
#include "SIDAM_Utilities_WaveDf"
#include "SIDAM_Utilities_misc"
#include "SIDAM_Workfunction"

#ifndef SIDAMshowProc
#pragma hide = 1
#endif

//******************************************************************************
//	Definition of main menu in the menu bar
//******************************************************************************
Menu "SIDAM", dynamic
	SubMenu "Load Data..."
		"Load Data...", /Q, SIDAMLoadData("", history=1)
		help = {"Loads data from binary/text files into Igor waves."}

		"Load Data From a Folder...", /Q, SIDAMLoadData("", folder=1, history=1)
		help = {"Loads all data in a folder."}
	End

	Submenu "Display..."
		SIDAMDisplay#menu(0,"/F3"), /Q, SIDAMDisplay#menuDo()
		help = {"Display a wave(s)"}

		SIDAMDisplay#menu(1,""), /Q, SIDAMDisplay($GetBrowserSelection(0),traces=1,history=1)
		help = {"Display a 2D wave as 1d-traces"}

		SIDAMDisplay#menu(2,""), /Q, SIDAMDisplay($GetBrowserSelection(0),traces=2,history=1)
		help = {"Display a 2D wave as xy-traces"}
		
		KMInfoBar#menu()+"/F8", /Q, KMInfoBar("")
		help = {"Show information bar at the top of image graph."}
		
		"-"
		
		"Preview (deprecated)", /Q, KMPreviewPnl()
		help = {"Display a preview panel"}		
	End

	"-"

	"Preference", /Q, SIDAMPrefsPnl()

	Submenu "Help"
		"Cheet sheet of shortcuts", /Q, SIDAMOpenExternalHelp(SIDAM_FILE_SHORTCUTS)
		
		"-"
		
		"About SIDAM...", /Q, SIDAMAbout()
		"Updates for SIDAM...", /Q, SIDAMCheckUpdate()
	End

	Submenu "Extension"
	End

	Submenu "Developer"
		SIDAMUtilMisc#menu(), /Q, SIDAMshowProcedures()
		"List of Deprecated Functions", /Q, print SIDAMDeprecatedFunctions()
		help = {"Show a list of deprecated functions in the history area"}
	End

	"-"

	//	Exit or Restart
	SIDAMMenus#Exitmenu(), /Q, SIDAMMenus#Exit()
End

//-------------------------------------------------------------
//	Exit or restart SIDAM
//-------------------------------------------------------------
Static Function/S Exitmenu()
	//	"Restart" when the shift key is pressed
	return SelectString(GetKeyState(0) && 0x04, "Exit", "Restart") + " SIDAM"
End

Static Function Exit()
	GetLastUserMenuInfo
	int isRestart = !CmpStr(S_value, "Restart SIDAM")

	sidamExit()

	if (isRestart)
		sidam()
	endif
End


//******************************************************************************
//	Definition of right-click menu for 2D/3D waves
//******************************************************************************
Menu "SIDAMMenu2D3D", dynamic, contextualmenu
	//	Range
	SubMenu "Range"
		help = {"Adjust of z range of images in the active graph."}
		"Manual.../F4",/Q, SIDAMRange()
		"-"
		SIDAMRange#menu(2), /Q, SIDAMRange#menuDo(2)
		SIDAMRange#menu(3), /Q, SIDAMRange#menuDo(3)
	End

	"Color Table.../F5",/Q, SIDAMColor()
	help = {"Change the color table used to display the top image in the active graph."}

	SubMenu "Sync"
		//	Sync Layers
		SIDAMMenus#menu("Sync Layers...",dim=3), /Q, KMSyncLayer#rightclickDo()
		help = {"Syncronize layer index of LayerViewers"}
		//	Sync Axis Range
		SIDAMMenus#menu("Sync Axis Range..."), /Q, KMSyncAxisRange#rightclickDo()
		help = {"Syncronize axis range"}
		//	Sync Cursors
		KMSyncCursor#rightclickMenu(), /Q, KMSyncCursor#rightclickDo()
		help = {"Synchronize cursor positions in graphs showing images"}
	End

	SubMenu "Window"
		SubMenu "Coordinates"
			KMInfoBar#rightclickMenu(0), /Q,  KMInfoBar#rightclickDo(0)
		End
		SubMenu "Title"
			KMInfoBar#rightclickMenu(1), /Q,  KMInfoBar#rightclickDo(1)
		End
		SubMenu "Complex"
			KMInfoBar#rightclickMenu(3), /Q,  KMInfoBar#rightclickDo(3)
		End
		"Scale Bar...", /Q, KMScaleBar#rightclickDo()
		"Layer Annotation...", /Q, SIDAMLayerAnnotation#rightclickDo()
		//	Show/Hide Axis
		KMInfoBar#rightclickMenu(2), /Q, KMInfoBar#rightclickDo(2)
		help = {"Show/Hide axes of the graph."}
	End

	SubMenu "\\M0Save/Export Graphics"
		"Save Graphics...", DoIgorMenu "File", "Save Graphics"
		SIDAMSaveGraphics#rightclickMenu(), /Q, SIDAMSaveGraphics#rightclickDo()
		SIDAMSaveMovie#rightclickMenu(), /Q, SIDAMSaveMovie#rightclickDo()

		"-"

		"\\M0Export Graphics (Transparent)", /Q, SIDAMExportGraphicsTransparent()
	End

	"-"

	//	View spectra of LayerViewer
	SIDAMMenus#menu("Point Spectrum...", dim=3), /Q, SIDAMSpectrumViewer#menuDo()
	SIDAMMenus#menu("Line Spectra...", dim=3), /Q, SIDAMLineSpectra#menuDo()
	//	Line Profile
	SIDAMMenus#menu("Line Profile..."),/Q, SIDAMLineProfile#menuDo()
	help = {"Make a line profile wave of the image in the active graph."}


	"-"

	//	Subtraction
	SIDAMMenus#menu("Subtract...")+"/F6", /Q, SIDAMSubtraction#menuDo()
	help = {"Subtract n-th plane or line from a 2D wave or each layer of a 3D wave"}
	//	Histogram
	SIDAMMenus#menu("Histogram..."),/Q, SIDAMHistogram#menuDo()
	help = {"Compute the histogram of a source wave."}
	SubMenu "Fourier"
		//	Fourier Transform
		SIDAMMenus#menu("Fourier Transform...", forfft=1)+"/F7", /Q, SIDAMFFT#menuDo()
		help = {"Compute a Fourier transform of a source wave."}
		//	Fourier filter
		SIDAMMenus#menu("Fourier Filter...", forfft=1), /Q, SIDAMFourierFilter#menuDo()
		help = {"Apply a Fourier filter to a source wave"}
		//	Fourier Symmetrization
		SIDAMMenus#menu("Fourier Symmetrization...", noComplex=1), /Q, SIDAMFourierSym#menuDo()
		help = {"Symmetrize a FFT image"}
	End

	//	Correlation
	SIDAMMenus#menu("Correlation...", forfft=1), /Q, SIDAMCorrelation#menuDo()
	help = {"Compute a correlation function of a source wave(s)."}
	//	Work Function
	SIDAMMenus#menu("Work Function...", dim=3), /Q, SIDAMWorkfunction#menuDo()
	help = {"Compute work function."}

	"-"

	"Position Recorder", /Q, SIDAMPositionRecorder("")
	//	Extract Layers of LayerViewer
	KMLayerViewer#rightclickMenu(0), /Q, KMLayerViewer#rightclickDo(0)
	//	"Data Parameters"
	SIDAMShowParameters#rightclickMenu(), /Q, SIDAMShowParameters()


	"-"

	SubMenu "Extension"
	End

	"-"

	"Close Infobar", /Q, KMInfoBar(WinName(0,1))
End
//-------------------------------------------------------------
//	conditional menu
//-------------------------------------------------------------
Static Function/S menu(String str, [int noComplex, int dim, int forfft])
	noComplex = ParamIsDefault(noComplex) ? 0 : noComplex

	String grfName = WinName(0,1)
	if (!strlen(grfName))
		return "(" + str
	endif
	Wave/Z w = SIDAMImageWaveRef(grfName)
	if (!WaveExists(w))
		return "(" + str
	endif

	//	return empty for 2D waves
	if (!ParamIsDefault(dim) && dim==3 && WaveDims(w)!=3)
		return ""
	endif

	//	gray out for complex waves
	if (noComplex)
		return SelectString((WaveType(w) & 0x01), "", "(") + str
	endif

	//	gray out for waves which are not for FFT
	if (!ParamIsDefault(forfft) && forfft)
		//	When a big wave is contained an experiment file, SIDAMValidateWaveforFFT may
		// make the menu responce slow. Therefore, use SIDAMValidateWaveforFFT only if
		//	the wave in a window has been modified since the last menu call.
		Variable grfTime = str2num(GetUserData(grfName, "", "modtime"))
		Variable wTime = NumberByKey("MODTIME", WaveInfo(w, 0))
		Variable fftavailable = str2num(GetUserData(grfName, "", "fftavailable"))
		int noRecord = numtype(grfTime) || numtype(fftavailable)
		int isModified = wTime > grfTime
		if (isModified || noRecord)
			fftavailable = !SIDAMValidateWaveforFFT(w)
			SetWindow $grfName userData(modtime)=num2istr(wTime)
			SetWindow $grfName userData(fftavailable)=num2istr(fftavailable)
		endif
		return SelectString(fftavailable, "(", "") + str
	endif

	return str
End


//******************************************************************************
//	Definition of right-click menu for 1D waves
//******************************************************************************
Menu "SIDAMMenu1D", dynamic, contextualmenu
	//	Trace
	"Offset and Color...", /Q, KMTrace#rightclickDo()
	help = {"Set offset of traces in the top graph."}

	SubMenu "Sync"
		//	Sync Axis Range
		"Sync Axis Range...", /Q, KMSyncAxisRangeR()
		help = {"Syncronize axis range"}
	End

	SubMenu "Window"
		SubMenu "Coordinates"
			 KMInfoBar#rightclickMenu(0), /Q,  KMInfoBar#rightclickDo(0)
		End
		SubMenu "Complex"
			KMInfoBar#rightclickMenu(4), /Q,  KMInfoBar#rightclickDo(4)
		End
	End

	SubMenu "\\M0Save/Export Graphics"
		"Save Graphics...", DoIgorMenu "File", "Save Graphics"

		"-"

		"\\M0Export Graphics (Transparent)", /Q, SIDAMExportGraphicsTransparent()
	End

	"-"

	//	Work Function
	"Work Function...", /Q, SIDAMWorkfunction#menuDo()
	help = {"Compute work function."}

	"-"

	//	"Data Parameters"
	SIDAMShowParameters#rightclickMenu(), /Q, SIDAMShowParameters()

	"-"

	SubMenu "Extension"
	End

	"-"

	"Close Infobar", /Q, KMInfoBar(WinName(0,1))
End


//******************************************************************************
//	Definition of graph marquee menu
//******************************************************************************
Menu "GraphMarquee", dynamic
	SIDAMSubtraction#marqueeMenu(),/Q, SIDAMSubtraction#marqueeDo()
	SIDAMFourierSym#marqueeMenu(),/Q, SIDAMFourierSym#marqueeDo()
	Submenu "Get peak"
		KMFourierPeak#marqueeMenu(0), /Q, KMFourierPeak#marqueeDo(0)
		KMFourierPeak#marqueeMenu(1), /Q, KMFourierPeak#marqueeDo(1)
	End
End

