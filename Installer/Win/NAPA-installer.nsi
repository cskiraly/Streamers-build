!include MUI2.nsh


Name "Napa-Wine"
OutFile "WineStreamerInstaller1.0.exe"

;Default installation folder
InstallDir "$PROGRAMFILES\NAPA-WINE"
InstallDirRegKey HKLM "Software\NAPA-WINE" ""

;Request application privileges for Windows Vista
RequestExecutionLevel user

!define MUI_ABORTWARNING

RequestExecutionLevel admin


Function .onInit

!insertmacro MUI_LANGDLL_DISPLAY

FunctionEnd

!define MUI_WELCOMEFINISHPAGE_BITMAP "NapaWine.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "NapaWine.bmp"


!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "WineStreamerLicense.rtf"
!insertmacro MUI_PAGE_DIRECTORY
Var StartMenuFolder

;Start Menu Folder Page Configuration
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKLM" 
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\NAPA-WINE" 
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "NAPA-WINE"
!insertmacro MUI_PAGE_STARTMENU "Application" $StartMenuFolder

!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH


; Languages
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "Italian"
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "German"
!insertmacro MUI_LANGUAGE "Polish"
!insertmacro MUI_LANGUAGE "Hungarian"

LangString MYVAR1 ${LANG_ENGLISH} "A test section."
LangString MYVAR1 ${LANG_HUNGARIAN} "Teszt szekció"


# default section start
section
 
# define output path
setOutPath $INSTDIR
 
# specify file to go in output path
File /r WineStreamer\*.*

 
# define uninstaller name
writeUninstaller $INSTDIR\uninstaller.exe

!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    
;Create shortcuts
CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
CreateShortCut "$SMPROGRAMS\$StartMenuFolder\WineStreamer.lnk" "$INSTDIR\runme.bat"
CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk" "$INSTDIR\uninstaller.exe"
  
!insertmacro MUI_STARTMENU_WRITE_END

WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\WineStreamer" \
                 "DisplayName" "NAPA-WINE WineStreamer -- P2P video streaming client"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\WineStreamer" \
                 "UninstallString" "$\"$INSTDIR\uninstaller.exe$\""
 
# default section end
sectionEnd
 
# create a section to define what the uninstaller does.
# the section will always be named "Uninstall"
section "Uninstall"
 
# Always delete uninstaller first
delete $INSTDIR\uninstaller.exe

DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\WineStreamer"

 
# now delete installed files
RMDir /r "$INSTDIR"

!insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder

Delete "$SMPROGRAMS\$StartMenuFolder\WineStreamer.lnk"
Delete "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk"
RMDir "$SMPROGRAMS\$StartMenuFolder"
 
sectionEnd