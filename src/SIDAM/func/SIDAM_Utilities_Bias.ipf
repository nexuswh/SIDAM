#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3
#pragma ModuleName = SIDAMUtilBias

#ifndef SIDAMshowProc
#pragma hide = 1
#endif

//	Functions for dealing with unevenly spaced biases

//@
//	Set information of unevenly spaced biases
//
//	## Parameters
//	w : wave
//		A 3D wave
//	biasw : wave
//		A 1D numeric wave containing bias values
//
//	## Returns
//	variable
//		* 0: Successfully copied
//		* !0: Error
//@
Function SIDAMSetBias(Wave/Z w, Wave/Z biasw)
	if (!WaveExists(w) || !WaveExists(biasw))
		return 1
	elseif (WaveDims(w) != 3)
		return 2
	elseif (DimSize(w,2) != numpnts(biasw))
		return 3
	elseif (WaveType(biasw) & 0x01)	//	complx
		return 4
	elseif (WaveType(biasw,1) != 1)	//	not numeric
		return 5
	endif

	int i, n = numpnts(biasw)
	for (i = 0; i < n; i++)
		SetDimLabel 2, i, $num2str(biasw[i]), w
	endfor
	return 0
End

//@
//	Return a wave of unevenly-spaced bias values
//
//	## Parameters
//	w : wave
//		A 3D wave having unevenly-spaced bias info
//	dim : int, {1 or 2}
//		1. The returned wave contains unevely spaced biases as they are.
//			This is used as an x wave to display a trace.
//		2. The returned wave contains average two neighboring layers.
//			This is used as an x wave or a y wave to display an image.
//
//	## Returns
//	wave
//		a 1D wave, or a null wave for any error
//@
Function/WAVE SIDAMGetBias(Wave/Z w, int dim)
	if (SIDAMisUnevenlySpacedBias(w) != 1 || dim < 1 || dim > 2)
		return $""
	endif
	int nz = DimSize(w,2)

	Make/N=(nz)/FREE tw = str2num(GetDimLabel(w,2,p))
	if (dim == 1)
		return tw
	endif

	//	dim == 2
	Make/N=(nz+1)/FREE biasw
	biasw[1,nz-1] = (tw[p-1]+tw[p])/2
	biasw[0] = tw[0]*2 - biasw[1]
	biasw[nz] = tw[nz-1]*2 - biasw[nz-1]
	return biasw
End

//@
//	Copy unevevly-spaced bias info from one to another
//
//	## Parameters
//	srcw : wave
//		A source 3D wave
//	destw : wave
//		A destination 3D wave
//
//	## Returns
//	variable
//		* 0: Successfully copied
//		* 1: Error
//@
Function SIDAMCopyBias(Wave/Z srcw, Wave/Z destw)
	if (SIDAMisUnevenlySpacedBias(srcw) != 1 || DimSize(srcw,2)!=DimSize(destw,2))
		return 1
	endif
	int i, nz = DimSize(srcw,2)
	for (i = 0; i < nz; i++)
		SetDimLabel 2, i, $GetDimLabel(srcw, 2, i), destw
	endfor
	return 0
End

//@
//	Return if a 3D wave has unevenly-spaced biases info
//
//	## Parameters
//	w : wave
//		A 3D wave
//
//	## Returns
//	variable
//		* 0: False
//		* 1: True
//		* -1: Error
//@
Function SIDAMisUnevenlySpacedBias(Wave/Z w)
	if (!WaveExists(w))
		return -1
	elseif (WaveDims(w) != 3)
		return 0
	endif
	Make/N=(DimSize(w,2))/FREE tw = numtype(str2num(GetDimlabel(w,2,p)))
	return WaveMax(tw) == 0	//	true if all labels are numeric
End

//@
//	Extension of `ScaleToIndex()` that includes unevenly-spaced bias
//
//	## Parameters
//	w : wave
//		The input wave
//	value : int
//		A scaled coordinate value
//	dim : int {0 -- 3}
//		Specify the dimension.
//		* 0: Rows
//		* 1: Columns
//		* 2: Layers
//		* 3: Chunks
//
//	## Returns
//	variable
//		The index value
//@
Function SIDAMScaleToIndex(Wave/Z w, Variable value, int dim)
	if (!WaveExists(w))
		return nan
	elseif (dim < 0 || dim > 3)
		return nan
	endif

	if (dim == 2 && SIDAMisUnevenlySpacedBias(w))
		//	search index corresponding to the nearest value
		Make/N=(DimSize(w,2))/FREE dw = abs(str2num(GetDimLabel(w,2,p))-value), iw = p
		Sort dw, iw
		return iw[0]
	else
		return ScaleToIndex(w,value,dim)
	endif
End

//@
//	Extension of `IndexToScale()` that includes unevenly-spaced bias
//
//	## Parameters
//	w : wave
//		The input wave
//	index : int
//		An index number
//	dim : int {0 -- 3}
//		Specify the dimension.
//		* 0: Rows
//		* 1: Columns
//		* 2: Layers
//		* 3: Chunks
//
//	## Returns
//	variable
//		The scaled coordinate value
//@
Function SIDAMIndexToScale(Wave w, int index, int dim)
	if (!WaveExists(w))
		return nan
	elseif (dim < 0 || dim > 3)
		return nan
	endif

	if (dim == 2 && SIDAMisUnevenlySpacedBias(w))
		return str2num(GetDimLabel(w,dim,index))
	else
		return IndexToScale(w,index,dim)
	endif
End
