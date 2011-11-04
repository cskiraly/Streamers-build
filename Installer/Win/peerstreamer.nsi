!define PRODUCT_NAME "PeerStreamer"
;!define PRODUCT_VERSION should be defined externally with /D or -D
!define PRODUCT_PUBLISHER "PeerStreamer"
!define PRODUCT_WEB_SITE "http://peerstreamer.org"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define SOURCE_PATH "..\..\PeerStreamer\"
!define EXECUTABLE "chunker_player.exe"
!define PROGICON "peerstreamer.ico"
!define PROGUNICON "unpeerstreamer.ico"
!define SETUP_BITMAP "napalogo_small.bmp"

; MUI 1.67 compatible ------
!include MUI2.nsh

; MUI Settings
!define MUI_ICON "${PROGICON}"
!define MUI_UNICON "${PROGUNICON}"  ; define uninstall icon to appear in Add/Remove Programs
!define MUI_STARTMENU_WRITE_BEGIN "${SETUP_BITMAP}"

; Name of our application
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
; The file to write
OutFile "PeerStreamerInstaller-${PRODUCT_VERSION}.exe"

; Set the default Installation Directory
InstallDir "$PROGRAMFILES\${PRODUCT_PUBLISHER}"
XPStyle on
ShowInstDetails show
ShowUnInstDetails show

InstallDirRegKey HKLM "Software\PeerStreamer" ""

;Request application privileges for Windows Vista
RequestExecutionLevel user

;!define MUI_ABORTWARNING

RequestExecutionLevel admin

Var StartMenuFolder

!define MUI_ABORTWARNING

; ----------------------------------------------------------------------------------
; *************************** SECTION FOR INSTALLING *******************************
; ----------------------------------------------------------------------------------
; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
;!insertmacro MUI_PAGE_LICENSE "../../license.txt"   ; text file with license terms
;!insertmacro MUI_PAGE_COMPONENTS
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Menu
;!define MUI_STARTMENUPAGE
;Start Menu Folder Page Configuration
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKLM"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\${PRODUCT_NAME}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_NAME}"

!insertmacro MUI_PAGE_STARTMENU "Application" $StartMenuFolder
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
# Finish Page Settings
;!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\readme.txt"  ; readme.txt file for user
;!define MUI_FINISHPAGE_SHOWREADME_NOTCHECED
# Run Program Settings
!define MUI_FINISHPAGE_RUN "$INSTDIR\${EXECUTABLE}"
!define MUI_FINISHPAGE_RUN_NOTCHECED
!define MUI_FINISHPAGE_NOREBOOTSUPPORT
!insertmacro MUI_PAGE_FINISH
# Start Menu Settings
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "${PRODUCT_PUBLISHER}\${PRODUCT_NAME}"

;!define MUI_WELCOMEFINISHPAGE_BITMAP "${SETUP_BITMAP}"
!define MUI_WELCOMEFINISHPAGE_BITMAP_NOSTRETCH
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "${SETUP_BITMAP}"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP_NOSTRETCH

; Set the text which prompts the user to enter the installation directory
DirText "Please choose a directory to which you'd like to install this application."

; ----------------------------------------------------------------------------------
; *************************** SECTION FOR UNINSTALLING *******************************
; ----------------------------------------------------------------------------------
; Uninstaller pages
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

; Languages
!define MUI_LANGLL_ALLLANGUAGES
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "Italian"
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "German"
!insertmacro MUI_LANGUAGE "Polish"
!insertmacro MUI_LANGUAGE "Hungarian"

Function .onInit
!insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

;LangString MYVAR1 ${LANG_ENGLISH} "A test section."
;LangString MYVAR1 ${LANG_HUNGARIAN} "Teszt szekció"

Section "Install" ; A "useful" name is not needed as we are not installing separate components

; Set output path to the installation directory. Also sets the working
; directory for shortcuts
SetOutPath $INSTDIR

File /r ${SOURCE_PATH}\*.*
File "${PROGICON}"
File "${PROGUNICON}"

WriteUninstaller $INSTDIR\Uninstall.exe

; //////// CREATE REGISTRY KEYS FOR ADD/REMOVE PROGRAMS IN CONTROL PANEL /////////
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PeerStreamer" "DisplayName"\
"Peerstreamer -- P2P video streaming client"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PeerStreamer" "UninstallString" \
"$INSTDIR\Uninstall.exe"
; //////////////////////// END CREATING REGISTRY KEYS ////////////////////////////

!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
; ///////////////// CREATE SHORT CUTS //////////////////////////////////////

CreateDirectory "$SMPROGRAMS\${PRODUCT_PUBLISHER}"
## Links

;SetShellVarContext all
CreateShortCut "$SMPROGRAMS\${PRODUCT_PUBLISHER}\${PRODUCT_NAME}.lnk" "$INSTDIR\${EXECUTABLE}" "" "$INSTDIR\${PROGICON}" 0
CreateShortCut "$SMPROGRAMS\${PRODUCT_PUBLISHER}\Uninstall PeerStreamer.lnk" "$INSTDIR\Uninstall.exe"
;CreateShortCut "$SMPROGRAMS\${PRODUCT_PUBLISHER}\README.lnk" "$INSTDIR\README.txt"
CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\${EXECUTABLE}" "" "$INSTDIR\${PROGICON}" 0
WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"


!insertmacro MUI_STARTMENU_WRITE_END
; ///////////////// END CREATING SHORTCUTS ////////////////////////////////// 

;MessageBox MB_OK "Welcome to NEM 2011 and enjoy the Streaming!"
SectionEnd

; ----------------------------------------------------------------------------------
; ************************** SECTION FOR UNINSTALLING ******************************
; ---------------------------------------------------------------------------------- 
Section "Uninstall"
; remove all the files and folders
RMDir /r "$INSTDIR"

;!insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
; now remove all the startmenu links
Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
Delete "$SMPROGRAMS\${PRODUCT_PUBLISHER}\${PRODUCT_NAME}.lnk"
Delete "$SMPROGRAMS\${PRODUCT_PUBLISHER}\Uninstall PeerStreamer.lnk"
;Delete "$SMPROGRAMS\${PRODUCT_PUBLISHER}\README.lnk"
RMDir /r "$SMPROGRAMS\${PRODUCT_PUBLISHER}"

; Now delete registry keys
DeleteRegKey  /ifempty HKLM "Software\PeerStreamer"
DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\PeerStreamer"

SectionEnd
