; $Id$
; Script generated by the HM NIS Edit Script Wizard.

; Compression settings

; enable lzma compression when releasing the final installer
; for now, use normal zlib, as lzma takes a _long_ time
SetCompressor lzma
;SetCompress off

; You probably need to change the paths
; Pack exe-header of installer (not required)
!packhdr foinsttemp.exe '"C:\Dokumente und Einstellungen\Dennis\Desktop\UPX" -9 foinsttemp.exe'
; Strip debugging symbols from binaries
!system "C:\Dev-Cpp\bin\strip -sp ..\*.exe"

; Other installer settings

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "FreeOrion"
!define PRODUCT_VERSION "0.1"
!define PRODUCT_PUBLISHER "The FreeOrion Community"
!define PRODUCT_WEB_SITE "http://www.freeorion.org"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\freeorion.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_STARTMENU_REGVAL "NSIS:StartMenuDir"

!define MUI_COMPONENTSPAGE_NODESC ; no descriptions (yet)

BrandingText "${PRODUCT_NAME} ${PRODUCT_VERSION} Installer $$Revision$$ (NSIS v2.0rc4)"
; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\win-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\win-uninstall.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Header\Win.bmp"
!macro CHECKUSER UN
  UserInfo::GetName
  IfErrors Win9x
  Pop $0
;  MessageBox MB_OK $0
  UserInfo::GetAccountType
  Pop $0
  goto NotWin9x
 Win9x:
  ClearErrors
  StrCpy $0 "Admin"
 NotWin9x:
  SetShellVarContext all
  StrCmp $0 "Admin" all_fine
  ; no admin privileges, installation will probably fail, so warn the user
  SetShellVarContext current
  MessageBox MB_YESNO|MB_DEFBUTTON2|MB_ICONEXCLAMATION "You do not have administrator privileges required to perform the ${UN}installation! If you continue, ${UN}install is likely to fail (silently). It is strongy recommended that you abort ${UN}install! Do you still wish to proceed?" IDYES all_fine
  ; User decided to abort
  Abort
 all_fine:
  StrCmp $SMPROGRAMS "" 0 no_bug
  ; a strange bug...
  MessageBox MB_OK|MB_ICONSTOP "I'm unable to determine the startmenu-folder, sorry. THIS IS A KNOWN BUG. If you can reproduce it, please post information to the FreeOrion Forum (www.artclusta.com/bb). Quitting. (Try to rename the installer, sometimes it works, don't ask me why)"
  Quit
 no_bug:
!macroend

Function .onInit
  !insertmacro CHECKUSER ""
FunctionEnd

; the same applies to the uninstaller
Function un.onInit
  !insertmacro CHECKUSER "un"
FunctionEnd

;IMHO, it's better to start with the license instead of the Welcome page
; License page
!insertmacro MUI_PAGE_LICENSE "gpl.rtf"

; Welcome page
!insertmacro MUI_PAGE_WELCOME

; Components page
!insertmacro MUI_PAGE_COMPONENTS

; Directory page
var SOURCEDIR
!insertmacro MUI_PAGE_DIRECTORY

; This will only be shown if "Install Source" is selected
!define MUI_PAGE_CUSTOMFUNCTION_PRE CheckIfSource
!define MUI_DIRECTORYPAGE_TEXT_TOP "Setup will install the source code of ${PRODUCT_NAME} ${PRODUCT_VERSION} in the following folder. To install in a different folder, click Browse and select another folder. Click Next to continue."
!define MUI_DIRECTORYPAGE_TEXT_DESTINATION "Install source code to"
!define MUI_DIRECTORYPAGE_VARIABLE $SOURCEDIR
!insertmacro MUI_PAGE_DIRECTORY

; Start menu page
var ICONS_GROUP
;!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "FreeOrion"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_STARTMENU_REGVAL}"
!insertmacro MUI_PAGE_STARTMENU Application $ICONS_GROUP

; Instfiles page
!insertmacro MUI_PAGE_INSTFILES

; Finish page
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_FINISHPAGE_RUN "$INSTDIR\freeorion.exe"
!insertmacro MUI_PAGE_FINISH

; -------------------------------------------------
; Uninstaller pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!define MUI_UNFINISHPAGE_NOAUTOCLOSE
!insertmacro MUI_UNPAGE_FINISH

; Language files
!insertmacro MUI_LANGUAGE "English"

; Reserve files
;!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

; Languages

;Function .onInit
;  !insertmacro MUI_LANGDLL_DISPLAY
;FunctionEnd



; MUI end ------


Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "FreeOrion-Setup.exe"
InstallDir "$PROGRAMFILES\FreeOrion"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails hide
ShowUnInstDetails hide
AllowRootDirInstall true

Section "Required files" SecRequired
  SectionIn RO ; this can't be deselected
  SetOutPath "$INSTDIR"
  SetOverwrite on
  File /r "C:\CVS-export\FreeOrion\default" ; we don't want the CVS directory included, so use an 'export'ed Repository
  File "..\zlib.dll"
  File "..\SDL_mixer.dll"
  File "..\SDL.dll"
  File "..\ilut.dll"
  File "..\ilu.dll"
  File "..\GiGiSDL.dll"
  File "..\GiGiNet.dll"
  File "..\GiGi.dll"
  File "..\freetype-6.dll"
  File "..\freeoriond.exe"
  File "..\freeorionca.exe"
  File "..\freeorion.exe"
  File "..\devil.dll"
  File "..\Vera.ttf"
  File /oname="License.Vera.txt" "..\License.Vera"
SectionEnd

Section /o "Source Code" SecInstallSource
  SetOutPath "$SOURCEDIR"
  File /r "C:\CVS-export\FreeOrion\*.*"
SectionEnd

Section -AdditionalIcons
  WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
  WriteIniStr "$INSTDIR\FreeOrion Forums.url" "InternetShortcut" "URL" "http://www.artclusta.com/bb"
  SetOutPath "$INSTDIR" ; otherwise Shortcuts might have SOURCEDIR as working directory
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    CreateDirectory "$SMPROGRAMS\$ICONS_GROUP"
    CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
    CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\FreeOrion Forums.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
    CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk" "$INSTDIR\uninst.exe"
    CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\FreeOrion dedicated server.lnk" "$INSTDIR\freeoriond.exe"
    CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\FreeOrion.lnk" "$INSTDIR\freeorion.exe"
  !insertmacro MUI_STARTMENU_WRITE_END
  CreateShortCut "$DESKTOP\FreeOrion.lnk" "$INSTDIR\freeorion.exe"
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\freeoriond.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\freeoriond.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "${PRODUCT_STARTMENU_REGVAL}" "$ICONS_GROUP"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLUpdateInfo" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
  WriteRegDword ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "NoModify" 0x0000001
  WriteRegDword ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "NoRepair" 0x0000001
SectionEnd

; Section descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecRequired} ""
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Section Uninstall
  ReadRegStr $ICONS_GROUP ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "${PRODUCT_STARTMENU_REGVAL}"
  Delete "$INSTDIR\${PRODUCT_NAME}.url"
  Delete "$INSTDIR\uninst.exe"
  Delete "$INSTDIR\Vera.ttf"
  Delete "$INSTDIR\License.Vera.txt"
  Delete "$INSTDIR\devil.dll"
  Delete "$INSTDIR\freeorion.exe"
  Delete "$INSTDIR\freeorionca.exe"
  Delete "$INSTDIR\freeoriond.exe"
  Delete "$INSTDIR\freetype-6.dll"
  Delete "$INSTDIR\GiGi.dll"
  Delete "$INSTDIR\GiGiNet.dll"
  Delete "$INSTDIR\GiGiSDL.dll"
  Delete "$INSTDIR\ilu.dll"
  Delete "$INSTDIR\ilut.dll"
  Delete "$INSTDIR\SDL.dll"
  Delete "$INSTDIR\SDL_mixer.dll"
  Delete "$INSTDIR\zlib.dll"
  Delete "$INSTDIR\*.log"
  RMDir /r "$INSTDIR\default"
  Delete "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk"
  Delete "$SMPROGRAMS\$ICONS_GROUP\Website.lnk"
  Delete "$DESKTOP\FreeOrion.lnk"
  Delete "$SMPROGRAMS\$ICONS_GROUP\FreeOrion.lnk"
  Delete "$SMPROGRAMS\$ICONS_GROUP\FreeOrion dedicated server.lnk"

  RMDir "$SMPROGRAMS\$ICONS_GROUP"
  RMDir /r "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose false
SectionEnd

; === Custom Pages and other functions ===

; This function checks whether the user wants to install the source code, and aborts if he does not.
Function CheckIfSource
  StrCpy $SOURCEDIR "$INSTDIR\Source"
  SectionGetFlags "${SecInstallSource}" $0
  IntOp $0 $0 & 1
  IntCmp $0 1 +2 ; if section is activated, do not abort
  Abort
FunctionEnd
