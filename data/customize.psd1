<#
    customize.psd1 - Declarative customize settings (toggles & dropdowns),
    transcribed from optimizerDuck (GPLv3, (C) itsfatduck).
    Toggle: has On / Off operation lists. Dropdown: has Choices (Label + Ops).
#>
@{
  Settings = @(

    # ===================== Desktop =====================
    @{ Category='Desktop'; Name='Show This PC Icon'; Kind='Toggle'; Condition='none'
       Desc='Show or hide the This PC icon on the desktop.'
       On =@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'; Name='{20D04FE0-3AEA-1069-A2D8-08002B30309D}'; Value=0; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'; Name='{20D04FE0-3AEA-1069-A2D8-08002B30309D}'; Value=1; Kind='DWord'} )
    }
    @{ Category='Desktop'; Name='Show Recycle Bin Icon'; Kind='Toggle'; Condition='none'
       Desc='Show or hide the Recycle Bin icon on the desktop.'
       On =@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'; Name='{645FF040-5081-101B-9F08-00AA002F954E}'; Value=0; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'; Name='{645FF040-5081-101B-9F08-00AA002F954E}'; Value=1; Kind='DWord'} )
    }
    @{ Category='Desktop'; Name='Show User Files Icon'; Kind='Toggle'; Condition='none'
       Desc='Show or hide your user profile folder icon on the desktop.'
       On =@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'; Name='{59031a47-3f72-44a7-89c5-5595fe6b30ee}'; Value=0; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'; Name='{59031a47-3f72-44a7-89c5-5595fe6b30ee}'; Value=1; Kind='DWord'} )
    }
    @{ Category='Desktop'; Name='Show Network Icon'; Kind='Toggle'; Condition='none'
       Desc='Show or hide the Network icon on the desktop.'
       On =@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'; Name='{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}'; Value=0; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'; Name='{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}'; Value=1; Kind='DWord'} )
    }
    @{ Category='Desktop'; Name='Show Control Panel Icon'; Kind='Toggle'; Condition='none'
       Desc='Show or hide the Control Panel icon on the desktop.'
       On =@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'; Name='{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}'; Value=0; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'; Name='{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}'; Value=1; Kind='DWord'} )
    }
    @{ Category='Desktop'; Name='Show Desktop Icons (master)'; Kind='Toggle'; Condition='none'
       Desc='Master toggle to show or hide ALL desktop icons at once.'
       On =@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='HideIcons'; Value=0; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='HideIcons'; Value=1; Kind='DWord'} )
    }
    @{ Category='Desktop'; Name='Shortcut Overlay Arrow'; Kind='Toggle'; Condition='none'
       Desc='Show or hide the small arrow overlay drawn on shortcut icons.'
       On =@( @{Type='ShortcutArrow'; On=$true} )
       Off=@( @{Type='ShortcutArrow'; On=$false} )
    }

    # ===================== Gaming =====================
    @{ Category='Gaming'; Name='Game Mode'; Kind='Toggle'; Condition='none'
       Desc='Windows Game Mode: prioritises the foreground game and pauses some background work.'
       On =@(
         @{Type='Reg'; Path='HKCU\Software\Microsoft\GameBar'; Name='AllowAutoGameMode'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\GameBar'; Name='AutoGameModeEnabled'; Value=1; Kind='DWord'}
       )
       Off=@(
         @{Type='Reg'; Path='HKCU\Software\Microsoft\GameBar'; Name='AllowAutoGameMode'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\GameBar'; Name='AutoGameModeEnabled'; Value=0; Kind='DWord'}
       )
    }
    @{ Category='Gaming'; Name='Xbox Game Bar'; Kind='Toggle'; Condition='none'
       Desc='The Xbox Game Bar overlay opened with Win+G (capture, performance, widgets).'
       On =@(
         @{Type='Reg'; Path='HKCU\System\GameConfigStore'; Name='GameBarEnabled'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\GameBar'; Name='ShowStartupPanel'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\GameBar'; Name='UseNexusForGameBarEnabled'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\GameBar'; Name='GamePanelStartupTipIndex'; Value=3; Kind='DWord'}
       )
       Off=@(
         @{Type='Reg'; Path='HKCU\System\GameConfigStore'; Name='GameBarEnabled'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\GameBar'; Name='ShowStartupPanel'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\GameBar'; Name='UseNexusForGameBarEnabled'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\GameBar'; Name='GamePanelStartupTipIndex'; Value=0; Kind='DWord'}
       )
    }
    @{ Category='Gaming'; Name='Background Recording (GameDVR)'; Kind='Toggle'; Condition='none'
       Desc='GameDVR background recording. Turning it off frees resources and can reduce stutter.'
       On =@(
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name='AppCaptureEnabled'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name='HistoricalCaptureEnabled'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\System\GameConfigStore'; Name='GameDVR_Enabled'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\System\GameConfigStore'; Name='GameDVR_HistoricalCaptureEnabled'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR'; Name='AllowGameDVR'; Value=1; Kind='DWord'}
       )
       Off=@(
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name='AppCaptureEnabled'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name='HistoricalCaptureEnabled'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\System\GameConfigStore'; Name='GameDVR_Enabled'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\System\GameConfigStore'; Name='GameDVR_HistoricalCaptureEnabled'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR'; Name='AllowGameDVR'; Value=0; Kind='DWord'}
       )
    }
    @{ Category='Gaming'; Name='Mouse Acceleration'; Kind='Toggle'; Condition='none'
       Desc='Pointer precision (mouse acceleration). Off gives 1:1 movement, preferred for gaming/aim.'
       On =@(
         @{Type='Reg'; Path='HKCU\Control Panel\Mouse'; Name='MouseSpeed'; Value='1'; Kind='String'}
         @{Type='Reg'; Path='HKCU\Control Panel\Mouse'; Name='MouseThreshold1'; Value='6'; Kind='String'}
         @{Type='Reg'; Path='HKCU\Control Panel\Mouse'; Name='MouseThreshold2'; Value='10'; Kind='String'}
       )
       Off=@(
         @{Type='Reg'; Path='HKCU\Control Panel\Mouse'; Name='MouseSpeed'; Value='0'; Kind='String'}
         @{Type='Reg'; Path='HKCU\Control Panel\Mouse'; Name='MouseThreshold1'; Value='0'; Kind='String'}
         @{Type='Reg'; Path='HKCU\Control Panel\Mouse'; Name='MouseThreshold2'; Value='0'; Kind='String'}
       )
    }
    @{ Category='Gaming'; Name='Fullscreen Optimizations'; Kind='Toggle'; Condition='none'
       Desc='Windows fullscreen optimizations (hybrid borderless fullscreen). Off forces true exclusive fullscreen.'
       On =@(
         @{Type='Reg'; Path='HKCU\System\GameConfigStore'; Name='GameDVR_DXGIHonorFSEWindowsCompatible'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\System\GameConfigStore'; Name='GameDVR_FSEBehavior'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\System\GameConfigStore'; Name='GameDVR_FSEBehaviorMode'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\System\GameConfigStore'; Name='GameDVR_HonorUserFSEBehaviorMode'; Value=0; Kind='DWord'}
       )
       Off=@(
         @{Type='Reg'; Path='HKCU\System\GameConfigStore'; Name='GameDVR_DXGIHonorFSEWindowsCompatible'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\System\GameConfigStore'; Name='GameDVR_FSEBehavior'; Value=2; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\System\GameConfigStore'; Name='GameDVR_FSEBehaviorMode'; Value=2; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\System\GameConfigStore'; Name='GameDVR_HonorUserFSEBehaviorMode'; Value=1; Kind='DWord'}
       )
    }
    @{ Category='Gaming'; Name='Hardware-Accelerated GPU Scheduling'; Kind='Toggle'; Condition='none'
       Desc='HAGS: lets the GPU manage its own memory scheduling. May reduce latency on supported GPUs.'
       On =@( @{Type='Reg'; Path='HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers'; Name='HwSchMode'; Value=2; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers'; Name='HwSchMode'; Value=1; Kind='DWord'} )
    }
    @{ Category='Gaming'; Name='DLSS Indicator'; Kind='Dropdown'; Condition='NvidiaGpuCondition'
       Desc='The NVIDIA DLSS on-screen overlay indicator (shows when DLSS is active).'
       Choices=@(
         @{Label='Off';         Ops=@( @{Type='Reg'; Path='HKLM\SOFTWARE\NVIDIA Corporation\Global\NGXCore'; Name='ShowDlssIndicator'; Value=0;    Kind='DWord'} )}
         @{Label='DebugOnly';   Ops=@( @{Type='Reg'; Path='HKLM\SOFTWARE\NVIDIA Corporation\Global\NGXCore'; Name='ShowDlssIndicator'; Value=1;    Kind='DWord'} )}
         @{Label='AllVersions'; Ops=@( @{Type='Reg'; Path='HKLM\SOFTWARE\NVIDIA Corporation\Global\NGXCore'; Name='ShowDlssIndicator'; Value=1024; Kind='DWord'} )}
       )
    }

    # ===================== Preferences =====================
    @{ Category='Preferences'; Name='Taskbar Alignment'; Kind='Dropdown'; Condition='Windows11Condition'
       Desc='Align taskbar icons to the center (default) or the left (Windows 11).'
       Choices=@(
         @{Label='Center'; Ops=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='TaskbarAl'; Value=1; Kind='DWord'} )}
         @{Label='Left';   Ops=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='TaskbarAl'; Value=0; Kind='DWord'} )}
       )
    }
    @{ Category='Preferences'; Name='Combine Taskbar Buttons'; Kind='Dropdown'; Condition='none'
       Desc='When taskbar buttons of the same app group together: always, only when the bar is full, or never.'
       Choices=@(
         @{Label='Always';   Ops=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='TaskbarGlomLevel'; Value=0; Kind='DWord'}, @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='MMTaskbarGlomLevel'; Value=0; Kind='DWord'} )}
         @{Label='WhenFull'; Ops=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='TaskbarGlomLevel'; Value=1; Kind='DWord'}, @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='MMTaskbarGlomLevel'; Value=1; Kind='DWord'} )}
         @{Label='Never';    Ops=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='TaskbarGlomLevel'; Value=2; Kind='DWord'}, @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='MMTaskbarGlomLevel'; Value=2; Kind='DWord'} )}
       )
    }
    @{ Category='Preferences'; Name='Taskbar Widgets'; Kind='Toggle'; Condition='Windows11Condition'
       Desc='The Widgets (weather/news) button on the taskbar (Windows 11).'
       On =@(
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='TaskbarDa'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds'; Name='EnableFeeds'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Dsh'; Name='AllowNewsAndInterests'; Value=1; Kind='DWord'}
       )
       Off=@(
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='TaskbarDa'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds'; Name='EnableFeeds'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Dsh'; Name='AllowNewsAndInterests'; Value=0; Kind='DWord'}
       )
    }
    @{ Category='Preferences'; Name='Task View Button'; Kind='Toggle'; Condition='none'
       Desc='The Task View (virtual desktops) button on the taskbar.'
       On =@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='ShowTaskViewButton'; Value=1; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='ShowTaskViewButton'; Value=0; Kind='DWord'} )
    }
    @{ Category='Preferences'; Name='Taskbar End Task'; Kind='Toggle'; Condition='Windows11Condition'
       Desc='Add an "End Task" option to the taskbar right-click menu (Windows 11).'
       On =@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings'; Name='TaskbarEndTask'; Value=1; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings'; Name='TaskbarEndTask'; Value=0; Kind='DWord'} )
    }
    @{ Category='Preferences'; Name='Dark Mode'; Kind='Toggle'; Condition='none'
       Desc='Switch Windows apps and the system UI between dark and light themes.'
       On =@(
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'; Name='AppsUseLightTheme'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'; Name='SystemUsesLightTheme'; Value=0; Kind='DWord'}
       )
       Off=@(
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'; Name='AppsUseLightTheme'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'; Name='SystemUsesLightTheme'; Value=1; Kind='DWord'}
       )
    }
    @{ Category='Preferences'; Name='Explorer Sync Notifications'; Kind='Toggle'; Condition='none'
       Desc='OneDrive / sync-provider promotional notifications shown inside File Explorer.'
       On =@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='ShowSyncProviderNotifications'; Value=1; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='ShowSyncProviderNotifications'; Value=0; Kind='DWord'} )
    }
    @{ Category='Preferences'; Name='System Suggestions'; Kind='Toggle'; Condition='none'
       Desc='Windows tips, tricks and suggestions shown in Settings and Start.'
       On =@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name='SystemPaneSuggestionsEnabled'; Value=1; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name='SystemPaneSuggestionsEnabled'; Value=0; Kind='DWord'} )
    }
    @{ Category='Preferences'; Name='Toast Notifications'; Kind='Toggle'; Condition='none'
       Desc='Pop-up (toast) notifications from apps and Windows.'
       On =@(
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications'; Name='ToastEnabled'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications'; Name='LockScreenToastEnabled'; Value=1; Kind='DWord'}
       )
       Off=@(
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications'; Name='ToastEnabled'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications'; Name='LockScreenToastEnabled'; Value=0; Kind='DWord'}
       )
    }
    @{ Category='Preferences'; Name='Explorer Compact Mode'; Kind='Toggle'; Condition='Windows11Condition'
       Desc='Tighter row spacing in File Explorer (Windows 11 compact view).'
       On =@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='UseCompactMode'; Value=1; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='UseCompactMode'; Value=0; Kind='DWord'} )
    }
    @{ Category='Preferences'; Name='Snap Assist Flyout'; Kind='Toggle'; Condition='Windows11Condition'
       Desc='The Snap layouts flyout that appears when you hover/maximize a window (Windows 11).'
       On =@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='EnableSnapAssistFlyout'; Value=1; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='EnableSnapAssistFlyout'; Value=0; Kind='DWord'} )
    }
    @{ Category='Preferences'; Name='Explorer Item Checkboxes'; Kind='Toggle'; Condition='none'
       Desc='Selection check boxes shown on items in File Explorer.'
       On =@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='AutoCheckSelect'; Value=1; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='AutoCheckSelect'; Value=0; Kind='DWord'} )
    }
    @{ Category='Preferences'; Name='Show File Extensions'; Kind='Toggle'; Condition='none'
       Desc='Show known file name extensions (e.g. .txt, .exe) in File Explorer.'
       On =@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='HideFileExt'; Value=0; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='HideFileExt'; Value=1; Kind='DWord'} )
    }
    @{ Category='Preferences'; Name='Show Hidden Files'; Kind='Toggle'; Condition='none'
       Desc='Show hidden files and folders in File Explorer.'
       On =@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='Hidden'; Value=1; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='Hidden'; Value=2; Kind='DWord'} )
    }
    @{ Category='Preferences'; Name='Clipboard History'; Kind='Toggle'; Condition='none'
       Desc='Windows clipboard history (Win+V) that stores multiple copied items.'
       On =@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Clipboard'; Name='EnableClipboardHistory'; Value=1; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Clipboard'; Name='EnableClipboardHistory'; Value=0; Kind='DWord'} )
    }
    @{ Category='Preferences'; Name='Window Shake (Aero Shake)'; Kind='Toggle'; Condition='none'
       Desc='Aero Shake: shaking a window title bar minimizes all other windows.'
       On =@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='DisallowShaking'; Value=0; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='DisallowShaking'; Value=1; Kind='DWord'} )
    }
    @{ Category='Preferences'; Name='Show Seconds in System Clock'; Kind='Toggle'; Condition='none'
       Desc='Show seconds on the taskbar clock (uses slightly more power/CPU).'
       On =@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='ShowSecondsInSystemClock'; Value=1; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='ShowSecondsInSystemClock'; Value=0; Kind='DWord'} )
    }
    @{ Category='Preferences'; Name='Explorer Launch Target'; Kind='Dropdown'; Condition='none'
       Desc='What File Explorer opens to when launched: This PC or Quick Access.'
       Choices=@(
         @{Label='ThisPc';      Ops=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='LaunchTo'; Value=1; Kind='DWord'} )}
         @{Label='QuickAccess'; Ops=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='LaunchTo'; Value=2; Kind='DWord'} )}
       )
    }
    @{ Category='Preferences'; Name='Bing / Web Search'; Kind='Toggle'; Condition='none'
       Desc='Bing web results and suggestions in Start menu / taskbar search.'
       On =@(
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Search'; Name='BingSearchEnabled'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Policies\Microsoft\Windows\Explorer'; Name='DisableSearchBoxSuggestions'; Value=0; Kind='DWord'}
       )
       Off=@(
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Search'; Name='BingSearchEnabled'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Policies\Microsoft\Windows\Explorer'; Name='DisableSearchBoxSuggestions'; Value=1; Kind='DWord'}
       )
    }
    @{ Category='Preferences'; Name='Classic Context Menu'; Kind='Toggle'; Condition='none'
       Desc='Use the Windows 10 classic right-click menu instead of the trimmed Windows 11 one.'
       On =@( @{Type='Reg'; Path='HKCU\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'; Name=''; Value=''; Kind='String'} )
       Off=@( @{Type='RegDeleteTree'; Path='HKCU\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}'} )
    }
    @{ Category='Preferences'; Name='Taskbar Search Box'; Kind='Dropdown'; Condition='none'
       Desc='How the taskbar search appears: hidden, icon only, icon + label, or a full search box.'
       Choices=@(
         @{Label='Hidden';       Ops=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Search'; Name='SearchboxTaskbarMode'; Value=0; Kind='DWord'} )}
         @{Label='Icon';         Ops=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Search'; Name='SearchboxTaskbarMode'; Value=1; Kind='DWord'} )}
         @{Label='IconAndLabel'; Ops=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Search'; Name='SearchboxTaskbarMode'; Value=2; Kind='DWord'} )}
         @{Label='SearchBox';    Ops=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Search'; Name='SearchboxTaskbarMode'; Value=3; Kind='DWord'} )}
       )
    }
    @{ Category='Preferences'; Name='Taskbar Last Active Click'; Kind='Toggle'; Condition='none'
       Desc='Clicking a grouped taskbar button jumps straight to the last active window of that app.'
       On =@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='LastActiveClick'; Value=1; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='LastActiveClick'; Value=0; Kind='DWord'} )
    }

    # ===================== System Features =====================
    @{ Category='System Features'; Name='Num Lock on Boot'; Kind='Toggle'; Condition='none'
       Desc='Turn Num Lock on automatically at startup and the sign-in screen.'
       On =@( @{Type='NumLock'; On=$true} )
       Off=@( @{Type='NumLock'; On=$false} )
    }
    @{ Category='System Features'; Name='Verbose Boot Status'; Kind='Toggle'; Condition='none'
       Desc='Show detailed status messages during startup and shutdown (useful for diagnosing hangs).'
       On =@( @{Type='Reg'; Path='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name='VerboseStatus'; Value=1; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name='VerboseStatus'; Value=0; Kind='DWord'} )
    }
    @{ Category='System Features'; Name='UTC Hardware Clock'; Kind='Toggle'; Condition='none'
       Desc='Treat the hardware (BIOS) clock as UTC. Helps when dual-booting with Linux.'
       On =@( @{Type='Reg'; Path='HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation'; Name='RealTimeIsUniversal'; Value=1; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation'; Name='RealTimeIsUniversal'; Value=0; Kind='DWord'} )
    }
    @{ Category='System Features'; Name='Disable Smart Name Resolution'; Kind='Toggle'; Condition='none'
       Desc='Stop Windows sending DNS queries to all interfaces at once (privacy / DNS-leak hardening).'
       On =@( @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient'; Name='DisableSmartNameResolution'; Value=1; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient'; Name='DisableSmartNameResolution'; Value=0; Kind='DWord'} )
    }
    @{ Category='System Features'; Name='Developer Mode'; Kind='Toggle'; Condition='none'
       Desc='Windows Developer Mode: sideload apps and run unsigned packages without a dev license.'
       On =@( @{Type='Reg'; Path='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'; Name='AllowDevelopmentWithoutDevLicense'; Value=1; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'; Name='AllowDevelopmentWithoutDevLicense'; Value=0; Kind='DWord'} )
    }
    @{ Category='System Features'; Name='Allow All Trusted Apps'; Kind='Toggle'; Condition='none'
       Desc='Allow installing all trusted (sideloaded) app packages.'
       On =@( @{Type='Reg'; Path='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'; Name='AllowAllTrustedApps'; Value=1; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'; Name='AllowAllTrustedApps'; Value=0; Kind='DWord'} )
    }
    @{ Category='System Features'; Name='Long Paths (>260 chars)'; Kind='Toggle'; Condition='none'
       Desc='Enable Win32 long-path support so paths longer than 260 characters work.'
       On =@( @{Type='Reg'; Path='HKLM\SYSTEM\CurrentControlSet\Control\FileSystem'; Name='LongPathsEnabled'; Value=1; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKLM\SYSTEM\CurrentControlSet\Control\FileSystem'; Name='LongPathsEnabled'; Value=0; Kind='DWord'} )
    }
    @{ Category='System Features'; Name='Show Battery Percentage'; Kind='Toggle'; Condition='Windows11Condition'
       Desc='Show the battery percentage next to the taskbar battery icon (Windows 11).'
       On =@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='IsBatteryPercentageEnabled'; Value=1; Kind='DWord'} )
       Off=@( @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='IsBatteryPercentageEnabled'; Value=0; Kind='DWord'} )
    }
  )
}
