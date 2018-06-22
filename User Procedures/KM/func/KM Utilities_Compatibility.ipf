#pragma TextEncoding = "Shift_JIS"
#pragma rtGlobals=3	
#pragma ModuleName= KMBackwardCompatibility

#ifndef KMshowProcedures
#pragma hide = 1
#endif

//******************************************************************************
//	����݊����̐ݒ�
//******************************************************************************
Function KMBackwardCompatibility()
	//	Igor 6 ���� 7 �ւ̕ύX�ŁA���̈�����ύX����
	changeAngstromStr(root:)
End


//	Igor 6 ���� 7 �ւ̕ύX�ɂƂ��Ȃ��Adfr �ȉ��ɂ���S�ẴE�G�[�u�ɂ��āA�P�ʂ� � �ł���悤�Ȃ��̂� \u00c5 �ɕύX����
Static Function changeAngstromStr(DFREF dfr)

	int i, n, dim
	
	for (i = 0, n = CountObjectsDFR(dfr, 4); i < n; i++)
		changeAngstromStr(dfr:$GetIndexedObjNameDFR(dfr, 4, i))
	endfor
	
	for (i = 0, n = CountObjectsDFR(dfr, 1); i < n; i++)
		Wave/SDFR=dfr w = $GetIndexedObjNameDFR(dfr, 1, i)
		for (dim = -1; dim <= 3; dim++)
			changeUnitStr(w, dim)
		endfor
	endfor
End

Static Function changeUnitStr(Wave w, int dim)
	String oldUnit = "�"
	String newUnit = "\u00c5"
	String unit = WaveUnits(w,dim)
	
	if (CmpStr(ConvertTextEncoding(unit,4,1,3,0), oldUnit) && CmpStr(unit, oldUnit))
		return 0
	endif
	
	SetWaveTextEncoding 1,2, w
	switch (dim)
		case -1:
			Setscale d, WaveMin(w), WaveMax(w), newUnit, w
			break
		case 0:
			Setscale/P x DimOffset(w,0), DimDelta(w,0), newUnit, w
			break
		case 1:
			Setscale/P y DimOffset(w,1), DimDelta(w,1), newUnit, w
			break
		case 2:
			Setscale/P z DimOffset(w,2), DimDelta(w,2), newUnit, w
			break
		case 3:
			Setscale/P t DimOffset(w,3), DimDelta(w,3), newUnit, w
			break
	endswitch
	
	return 1
End
