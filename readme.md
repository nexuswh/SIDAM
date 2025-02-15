# SIDAM

*SIDAM* (**S**pectroscopic **I**maging **D**ata **A**nalysis **M**acro) is
a software for data analysis of spectroscopic imaging scanning tunneling
microscopy / scanning tunneling spectroscopy. Compared with other software
for SPM data analysis such as WSxM, SPIP, or Gwyddion, SIDAM is developed
especially for handling 3D data (x, y, and energy).

Frequently used basic features:

- Flexible interactive viewers (see also [gif movies](#Gif-movies))
- Background subtraction
- Fourier analysis
  - Fourier transform
  - Fourier filter
  - Symmetrize Fourier transform
- Correlation
- Histogram
- Work function

*SIDAM* is written in Igor Pro, so you can fully use the powerful functions and
visualization of Igor Pro to analyse your data and make figures. Moreover, SIDAM
is designed for both GUI and CLI. You can do everything from the menus and do not
have to remember commands. However, you can also do the same things by calling
commands, making it easy to repeat analyses and incorporate *SIDAM* functions
into your scripts. All commands are [documented](https://yuksk.github.io/SIDAM/commands/).
## Requirement

Igor Pro 8 or later is required. Igor Pro 9 is recommended to use full features.

## Getting started

### Install

After cloning or downloading the macro files, copy them to the designated folders.

    SIDAM/
    ├ LICENSE
    ├ readme.md
    ├ docs/
    ├ script/
    └ src/
        ├ SIDAM.ipf -> Copy to Igor Procedures
        └ SIDAM/    -> Copy to User Procedures

Copy `src/SIDAM.ipf` and `src/SIDAM` to the Igor Procedures folder and the
User Procedures folder, respectively. If you don't know where the folders are,
choose *Menubar > Help > Show Igor Pro User Files* in Igor Pro.

Instead of copying the file and folder, you can also make shortcuts or
symbolic links of them in the designated folders. This would be useful for
updating SIDAM in future if you clone the files.

### Launch SIDAM
Lanuch Igor Pro, choose *Menubar > Macros > SIDAM* in Igor Pro, and you will
find a new menu item *SIDAM* in the menu bar. If Igor Pro is already running,
you need to restart it after installing SIDAM.

### Load data file
Choose *Menubar > SIDAM > Load Data... > from a File...*. Alternatively,
you can drag and drop data files into the window of Igor Pro.
Supported files are Nanonis files (.dat, .sxm, .3ds, .nsp).

### Show data
Choose a wave(s) you want to show in the Data Browser and
choose *Menubar > SIDAM > Display... > Display Selected Waves*.
Alternatively, you can press F3 after choosing a wave(s) you want to show in
the Data Browser.

### Subsequent analysis
Right-click the control bar shown in a window and you will find menu items of
analysis available for the data shown in the window.

## Gif movies

### Color tables
More than 200 color tables imported from outside and made originally.

<img src="https://raw.githubusercontent.com/yuksk/SIDAM/main/docs/assets/images/color.png" width="441px" height="262px" alt="autorange">

### Auto color range adjustment
The color range is adjusted to statistical values such as 3&#963; below and above the average of the shown image.

<img src="https://raw.githubusercontent.com/yuksk/SIDAM/main/docs/assets/images/autorange.gif" width="179px" height="160px" alt="autorange">

### Spectrum viewer
Interactive viewer of a spectrum or specta.
Positions of spectra can be acquired from any image, e.g., a simultaneous topograph.

<img src="https://raw.githubusercontent.com/yuksk/SIDAM/main/docs/assets/images/spectrum.gif" width="382px" height="160px" alt="spectrum">

<img src="https://raw.githubusercontent.com/yuksk/SIDAM/main/docs/assets/images/linespectra.gif" width="290px" height="289px" alt="linespectra">

### Line profile
Line profiles for 2D and 3D waves.
Both of waterfall and intensity plots are available for 3D waves.

<img src="https://raw.githubusercontent.com/yuksk/SIDAM/main/docs/assets/images/lineprofile.gif" width="290px" height="160px" alt="lineprofile">

### Synchronize layer, axis range, cursor
Synchronize the layer index, ranges of axes, and cursor positions of multiple images.

<img src="https://raw.githubusercontent.com/yuksk/SIDAM/main/docs/assets/images/synclayer.gif" width="253px" height="160px" alt="synclayer">  
<img src="https://raw.githubusercontent.com/yuksk/SIDAM/main/docs/assets/images/syncaxisrange.gif" width="255px" height="160px" alt="syncaxisrange">  
<img src="https://raw.githubusercontent.com/yuksk/SIDAM/main/docs/assets/images/synccursor.gif" width="253px" height="160px" alt="synccursor">

### Position recorder
Record positions you click in a wave. For example, if you click at impurities, the dimension of resultant wave gives the number of impurities.

<img src="https://raw.githubusercontent.com/yuksk/SIDAM/main/docs/assets/images/position_recorder.gif" width="249px" height="149px" alt="synclayer">


Data: BiTeI, https://doi.org/10.1103/PhysRevB.91.245312

## Document
https://yuksk.github.io/SIDAM/
