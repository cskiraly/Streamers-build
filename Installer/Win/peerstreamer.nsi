!define PRODUCT_NAME "PeerStreamer"
;!define PRODUCT_VERSION should be defined externally with /D or -D
!define DESCRIPTION "A peer-to-peer video streaming client"
;!define COMPANYNAME "University of Trento and EIT"
!define PRODUCT_PUBLISHER "PeerStreamer"
!define PRODUCT_WEB_SITE "http://peerstreamer.org"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define SOURCE_PATH "..\..\PeerStreamer\"
!define EXECUTABLE "chunker_player.exe"
!define SETUP_BITMAP "peerstreamer.bmp"

; MUI 1.67 compatible ------
!include MUI2.nsh

!define MUI_ABORTWARNING
!define MUI_ABORTWARNING_CANCEL_DEFAULT
 
!define MUI_UNABORTWARNING
!define MUI_UNABORTWARNING_CANCEL_DEFAULT

;!define MUI_HEADERIMAGE

; MUI Settings
!define MUI_ICON "eit-napa.ico"
!define MUI_UNICON "uneit-napa.ico"
!define MUI_STARTMENU_WRITE_BEGIN "${SETUP_BITMAP}"

; Name of our application
Name "${PRODUCT_NAME}"
; The file to write
OutFile "PeerStreamerInstaller-${PRODUCT_VERSION}.exe"

; Set the default Installation Directory
InstallDir "$PROGRAMFILES\${PRODUCT_PUBLISHER}"
XPStyle on
ShowInstDetails show
ShowUnInstDetails show

InstallDirRegKey HKLM "Software\${PRODUCT_PUBLISHER}" ""

;Request application privileges for Windows Vista
RequestExecutionLevel user

;!define MUI_ABORTWARNING

RequestExecutionLevel admin

Var StartMenuFolder

; ----------------------------------------------------------------------------------
; *************************** SECTION FOR INSTALLING *******************************
; ----------------------------------------------------------------------------------
; Welcome page
!define MUI_HEADERIMAGE_BITMAP "${SETUP_BITMAP}"
!define MUI_HEADERIMAGE_BITMAP_NOSTRETCH
!define MUI_WELCOMEFINISHPAGE_BITMAP "${SETUP_BITMAP}"
!define MUI_WELCOMEFINISHPAGE_BITMAP_NOSTRETCH
!define MUI_WELCOMEPAGE_TITLE "Installer for ${PRODUCT_NAME} ${PRODUCT_VERSION}"
!define MUI_WELCOMEPAGE_TITLE_3LINES # Extra space for the title area
!define MUI_WELCOMEPAGE_TEXT "PeerStreamer the open source P2P video client."
; License page
!insertmacro MUI_PAGE_WELCOME
LicenseData "license.rtf"
!insertmacro MUI_PAGE_LICENSE "license.txt"   ; text file with license terms
; Components
;!insertmacro MUI_PAGE_COMPONENTS
;!define MUI_LICENSEPAGE_BGCOLOR  "/windows"
;!define MUI_COMPONENTSPAGE_NODESC
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Menu
!define MUI_STARTMENUPAGE
;Start Menu Folder Page Configuration
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKLM"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\${PRODUCT_PUBLISHER}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_PUBLISHER}"

!insertmacro MUI_PAGE_STARTMENU "Application" $StartMenuFolder
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
;!define MUI_FINISHPAGE_NOAUTOCLOSE	# ShowInstDetails
# Finish Page Settings
;!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\readme.txt"  ; readme.txt file for user
;!define MUI_FINISHPAGE_SHOWREADME_NOTCHECED
# Run Program Settings
!define MUI_FINISHPAGE_RUN "$INSTDIR\${EXECUTABLE}"
!define MUI_FINISHPAGE_RUN_NOTCHECED
!define MUI_FINISHPAGE_NOREBOOTSUPPORT
!define MUI_FINISHPAGE_RUN_TEXT "Start ${PRODUCT_NAME}"
!define MUI_FINISHPAGE_LINK "Visit the ${PRODUCT_NAME} site for news, FAQ's and support"
!define MUI_FINISHPAGE_LINK_LOCATION "${PRODUCT_WEB_SITE}"
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "${PRODUCT_PUBLISHER}"
!insertmacro MUI_PAGE_FINISH

; Set the text which prompts the user to enter the installation directory
DirText "Please choose a directory to which you'd like to install ${PRODUCT_NAME}."

; ----------------------------------------------------------------------------------
; *************************** SECTION FOR UNINSTALLING *******************************
; ----------------------------------------------------------------------------------
; Uninstaller pages
	# unistall welcome pageStart Menu Settings
!define MUI_HEADERIMAGE_UNBITMAP "${SETUP_BITMAP}"
!define MUI_HEADERIMAGE_UNBITMAP_NOSTRETCH
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "${SETUP_BITMAP}"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP_NOSTRETCH
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
;!define MUI_UNFINISHPAGE_NOAUTOCLOSE
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
File "${MUI_ICON}"
File "${MUI_UNICON}"

WriteUninstaller $INSTDIR\Uninstall.exe

; //////// CREATE REGISTRY KEYS FOR ADD/REMOVE PROGRAMS IN CONTROL PANEL /////////
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_PUBLISHER}" "DisplayName"\
"${PRODUCT_NAME} - ${DESCRIPTION}"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_PUBLISHER}" "UninstallString" \
"$INSTDIR\Uninstall.exe"
; //////////////////////// END CREATING REGISTRY KEYS ////////////////////////////

!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
; ///////////////// CREATE SHORT CUTS //////////////////////////////////////
CreateDirectory "$SMPROGRAMS\${PRODUCT_PUBLISHER}"
## Links
CreateShortCut "$SMPROGRAMS\${PRODUCT_PUBLISHER}\${PRODUCT_NAME}.lnk" "$INSTDIR\${EXECUTABLE}" "" "$INSTDIR\${MUI_ICON}" 0
CreateShortCut "$SMPROGRAMS\${PRODUCT_PUBLISHER}\Uninstall ${PRODUCT_NAME}.lnk" "$INSTDIR\Uninstall.exe"
;CreateShortCut "$SMPROGRAMS\${PRODUCT_PUBLISHER}\README.lnk" "$INSTDIR\README.txt"
;CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url" "URL" ""
WriteINIStr "$SMPROGRAMS\${PRODUCT_PUBLISHER}\${PRODUCT_NAME}.URL" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
;CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.URL" "URL" "http://peerstreamer.org"

;CreateDirectory "$DESKTOP\${PRODUCT_PUBLISHER}"
;CreateShortCut "$DESKTOP\${PRODUCT_PUBLISHER}\${PRODUCT_NAME}.lnk" "$INSTDIR\${EXECUTABLE}" "" "$INSTDIR\${MUI_ICON}" 0
;CreateShortCut "$DESKTOP\${PRODUCT_PUBLISHER}\${PRODUCT_NAME}.lnk" "$INSTDIR\${EXECUTABLE}" ""

!insertmacro MUI_STARTMENU_WRITE_END
; ///////////////// END CREATING SHORTCUTS ////////////////////////////////// 

;MessageBox MB_OK "Welcome to NEM 2011 and enjoy the Streaming!"
SectionEnd

; ----------------------------------------------------------------------------------
; ************************** SECTION FOR UNINSTALLING ******************************
; ---------------------------------------------------------------------------------- 
Section "Uninstall"
;	SetShellVarContext all
	Delete "$INSTDIR\uninstall.exe"
	; remove all the files and folders
	Delete "$INSTDIR\channels.conf"
	Delete "$INSTDIR\chunker.conf"
	Delete "$INSTDIR\chunker_player.exe"
	Delete "$INSTDIR\chunker_streamer.exe"
	Delete "$INSTDIR\icons\audio_off.png"
	Delete "$INSTDIR\icons\audio_on.png"
	Delete "$INSTDIR\icons\down_16.png"
	Delete "$INSTDIR\icons\fullscreen32.png"
	Delete "$INSTDIR\icons\green_led.png"
	Delete "$INSTDIR\icons\nofullscreen32.png"
	Delete "$INSTDIR\icons\red_led.png"
	Delete "$INSTDIR\icons\up_16.png"
	Delete "$INSTDIR\icons\yellow_led.png"
	Delete "$INSTDIR\icons"
	RMDir "$INSTDIR\icons"
	Delete "$INSTDIR\mainfont.ttf"
	Delete "$INSTDIR\napalogo_small.bmp"
	Delete "$INSTDIR\peer_exec_name.conf"
	Delete "$INSTDIR\README"
	Delete "$INSTDIR\stats_font.ttf"
	Delete "$INSTDIR\streamer-ml-monl-chunkstream-static.exe"
	Delete "$INSTDIR\peerstreamer.bmp"
	Delete "$INSTDIR\licence.txt"
	Delete "$INSTDIR\eit-napa.ico"
	Delete "$INSTDIR\uneit-napa.ico"
	Delete "$INSTDIR\stderr.txt"
	Delete "$INSTDIR\stdout.txt"
	Delete $INSTDIR
;	RMDir /r "$INSTDIR"
;	RMDir "$INSTDIR"
	Delete "$EXEDIR\uninstall.exe"
	Delete "$EXEDIR\streamer-ml-monl-chunkstream-static.exe"
	Delete "$EXEDIR\chunker_player.exe"
	Delete "$EXEDIR\chunker_streamer.exe"
	Delete "$EXEDIR"
;	Delete "$EXEDIR/*.exe"
;	RMDir /r "$EXEDIR"	
	RMDir "$INSTDIR"
	
	;!insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
	; now remove all the startmenu links
	Delete "$SMPROGRAMS\${PRODUCT_PUBLISHER}\${PRODUCT_NAME}.URL"
	Delete "$SMPROGRAMS\${PRODUCT_PUBLISHER}\${PRODUCT_NAME}.lnk"
	Delete "$SMPROGRAMS\${PRODUCT_PUBLISHER}\Uninstall ${PRODUCT_NAME}.lnk"
	Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
	RMDir  "$SMPROGRAMS\${PRODUCT_PUBLISHER}"

	;RMDir /REBOOTOK $SMPROGRAMS\$StartMenuFolder
	;RMDir /REBOOTOK $INSTDIR
	
	; Now delete registry keys
	DeleteRegKey  /ifempty HKLM "Software\${PRODUCT_PUBLISHER}"
	DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_PUBLISHER}"

SectionEnd
