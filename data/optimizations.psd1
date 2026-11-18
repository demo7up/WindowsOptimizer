<#
    optimizations.psd1 - Declarative definitions of every optimization,
    transcribed verbatim from optimizerDuck (GPLv3, (C) itsfatduck).
    Each op: Type=Reg|RegDelete|RegDeleteTree|RegGpu|Service|ServiceList|
             SchedTask|Hibernation|UsbPower|PowerPlan|SvcHostSplit
#>
@{
  Optimizations = @(

    # ===================== Security & Privacy =====================
    @{ Category='Security & Privacy'; Name='Disable Telemetry'; Risk='Moderate'; Condition='none'
       Desc='Reduce core Windows telemetry, feedback, app-compat inventory and diagnostic services/tasks.'
       Operations=@(
         @{Type='Reg'; Path='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'; Name='AllowTelemetry'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='AllowTelemetry'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='DoNotShowFeedbackNotifications'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='AllowCommercialDataPipeline'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='AllowDeviceNameInTelemetry'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='MicrosoftEdgeDataOptIn'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\SOFTWARE\Microsoft\Siuf\Rules'; Name='NumberOfSIUFInPeriod'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Policies\Microsoft\Windows\EdgeUI'; Name='DisableMFUTracking'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat'; Name='DisableInventory'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat'; Name='AITEnable'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\SOFTWARE\Policies\Microsoft\Assistance\Client\1.0'; Name='NoExplicitFeedback'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Assistance\Client\1.0'; Name='NoActiveHelp'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy'; Name='HasAccepted'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='Start_TrackProgs'; Value=0; Kind='DWord'}
         @{Type='RegDelete'; Path='HKCU\SOFTWARE\Microsoft\Siuf\Rules'; Name='PeriodInNanoSeconds'}
         @{Type='Service'; Name='DiagTrack'; Startup='Disabled'}
         @{Type='Service'; Name='dmwappushservice'; Startup='Disabled'}
         @{Type='Service'; Name='DcpSvc'; Startup='Disabled'}
         @{Type='Service'; Name='diagnosticshub.standardcollector.service'; Startup='Disabled'}
         @{Type='SchedTask'; Path='\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser'}
         @{Type='SchedTask'; Path='\Microsoft\Windows\Application Experience\ProgramDataUpdater'}
         @{Type='SchedTask'; Path='\Microsoft\Windows\Application Experience\MareBackup'}
         @{Type='SchedTask'; Path='\Microsoft\Windows\Application Experience\StartupAppTask'}
         @{Type='SchedTask'; Path='\Microsoft\Windows\Application Experience\PcaPatchDbTask'}
         @{Type='SchedTask'; Path='\Microsoft\Windows\Autochk\Proxy'}
         @{Type='SchedTask'; Path='\Microsoft\Windows\Customer Experience Improvement Program\Consolidator'}
         @{Type='SchedTask'; Path='\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip'}
         @{Type='SchedTask'; Path='\Microsoft\Windows\Feedback\Siuf\DmClient'}
         @{Type='SchedTask'; Path='\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload'}
       )
    }
    @{ Category='Security & Privacy'; Name='Disable Error Reporting'; Risk='Moderate'; Condition='none'
       Desc='Disable Windows Error Reporting and the Program Compatibility Assistant.'
       Operations=@(
         @{Type='Reg'; Path='HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting'; Name='Disabled'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports'; Name='PreventHandwritingErrorReports'; Value=1; Kind='DWord'}
         @{Type='Service'; Name='WerSvc'; Startup='Disabled'}
         @{Type='Service'; Name='PcaSvc'; Startup='Disabled'}
         @{Type='SchedTask'; Path='\Microsoft\Windows\Windows Error Reporting\QueueReporting'}
         @{Type='SchedTask'; Path='\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector'}
         @{Type='SchedTask'; Path='\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver'}
         @{Type='SchedTask'; Path='\Microsoft\Windows\Diagnosis\Scheduled'}
       )
    }
    @{ Category='Security & Privacy'; Name='Disable Advertising & Suggestions'; Risk='Safe'; Condition='none'
       Desc='Disable advertising ID, consumer features, tailored experiences and system suggestions.'
       Operations=@(
         @{Type='Reg'; Path='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo'; Name='Enabled'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo'; Name='DisabledByGroupPolicy'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy'; Name='TailoredExperiencesWithDiagnosticDataEnabled'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name='DisableTailoredExperiencesWithDiagnosticData'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name='DisableWindowsConsumerFeatures'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name='DisableSoftLanding'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name='DisableThirdPartySuggestions'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement'; Name='ScoobeSystemSettingEnabled'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\SOFTWARE\Microsoft\InputPersonalization'; Name='RestrictImplicitInkCollection'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\SOFTWARE\Microsoft\InputPersonalization'; Name='RestrictImplicitTextCollection'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore'; Name='HarvestContacts'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Control Panel\International\User Profile'; Name='HttpAcceptLanguageOptOut'; Value=1; Kind='DWord'}
       )
    }
    @{ Category='Security & Privacy'; Name='Disable News & Interests'; Risk='Safe'; Condition='none'
       Desc='Disable the News and Interests taskbar feed.'
       Operations=@(
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Dsh'; Name='AllowNewsAndInterests'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds'; Name='ShellFeedsTaskbarViewMode'; Value=0; Kind='DWord'}
       )
    }
    @{ Category='Security & Privacy'; Name='Hide Meet Now Button'; Risk='Safe'; Condition='Windows10Condition'
       Desc='Hide the Meet Now button from the taskbar.'
       Operations=@(
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name='HideSCAMeetNow'; Value=1; Kind='DWord'}
       )
    }
    @{ Category='Security & Privacy'; Name='Disable Activity History'; Risk='Safe'; Condition='none'
       Desc='Disable activity history collection and syncing to the cloud.'
       Operations=@(
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\System'; Name='PublishUserActivities'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\System'; Name='EnableActivityFeed'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\System'; Name='PublishUserActivitiesOnUserConsent'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\System'; Name='UploadUserActivities'; Value=0; Kind='DWord'}
       )
    }
    @{ Category='Security & Privacy'; Name='Disable Location & Sensors'; Risk='Safe'; Condition='none'
       Desc='Disable location tracking, sensors, geolocation service, WiFi Sense and offline maps auto-updates.'
       Operations=@(
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors'; Name='DisableLocation'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors'; Name='DisableSensors'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SYSTEM\Maps'; Name='AutoUpdateEnabled'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}'; Name='SensorPermissionState'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location'; Name='Value'; Value='Deny'; Kind='String'}
         @{Type='Reg'; Path='HKLM\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location'; Name='Value'; Value='Deny'; Kind='String'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Geolocation'; Name='Status'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration'; Name='Status'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting'; Name='Value'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots'; Name='Value'; Value=0; Kind='DWord'}
         @{Type='SchedTask'; Path='\Microsoft\Windows\Maps\MapsUpdateTask'}
       )
    }
    @{ Category='Security & Privacy'; Name='Disable AutoLogger ETW Sessions'; Risk='Moderate'; Condition='none'
       Desc='Disable WMI AutoLogger ETW trace sessions.'
       Operations=@(
         @{Type='Reg'; Path='HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AppModel'; Name='Start'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\Cellcore'; Name='Start'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\CloudExperienceHostOobe'; Name='Start'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DataMarket'; Name='Start'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DiagLog'; Name='Start'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\Diagtrack-Listener'; Name='Start'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\LwtNetLog'; Name='Start'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\SQMLogger'; Name='Start'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\WdiContextLog'; Name='Start'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\WiFiSession'; Name='Start'; Value=0; Kind='DWord'}
       )
    }
    @{ Category='Security & Privacy'; Name='Disable Cortana & Web Search'; Risk='Moderate'; Condition='Windows10Condition'
       Desc='Disable Cortana, cloud search and connected web search.'
       Operations=@(
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name='AllowCortana'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name='AllowCloudSearch'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name='AllowCortanaAboveLock'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name='AllowSearchToUseLocation'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name='ConnectedSearchUseWeb'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Search'; Name='CortanaConsent'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Search'; Name='CortanaConsent2'; Value=0; Kind='DWord'}
       )
    }
    @{ Category='Security & Privacy'; Name='Disable Copilot'; Risk='Moderate'; Condition='Windows11Condition'
       Desc='Disable Windows Copilot via policy, hide the taskbar button, block its shell extension.'
       Operations=@(
         @{Type='Reg'; Path='HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot'; Name='TurnOffWindowsCopilot'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsCopilot'; Name='TurnOffWindowsCopilot'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='ShowCopilotButton'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked'; Name='{CB3B0003-8088-4EDE-8769-8B354AB2FF8C}'; Value=''; Kind='String'}
       )
    }
    @{ Category='Security & Privacy'; Name='Disable Content Delivery Manager'; Risk='Safe'; Condition='none'
       Desc='Disable the Content Delivery Manager and its subscribed-content/suggestion feeds.'
       Operations=@(
         @{Type='Reg'; Path='HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name='ContentDeliveryAllowed'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name='SubscribedContent-338387Enabled'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name='SubscribedContent-338388Enabled'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name='SubscribedContent-338389Enabled'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name='SubscribedContent-353698Enabled'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name='SystemPaneSuggestionsEnabled'; Value=0; Kind='DWord'}
       )
    }
    @{ Category='Security & Privacy'; Name='Disable Find My Device'; Risk='Safe'; Condition='none'
       Desc='Disable Find My Device location tracking.'
       Operations=@(
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\FindMyDevice'; Name='AllowFindMyDevice'; Value=0; Kind='DWord'}
       )
    }
    @{ Category='Security & Privacy'; Name='Disable Delivery Optimization'; Risk='Safe'; Condition='none'
       Desc='Disable peer-to-peer Delivery Optimization download sharing.'
       Operations=@(
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization'; Name='DODownloadMode'; Value=0; Kind='DWord'}
       )
    }

    # ===================== Power Management =====================
    @{ Category='Power Management'; Name='Disable Hibernation & Fast Startup'; Risk='Moderate'; Condition='none'
       Desc='Disable hibernation and Fast Startup (removes hiberfil.sys).'
       Operations=@( @{Type='Hibernation'} )
    }
    @{ Category='Power Management'; Name='Disable USB Power Saving'; Risk='Safe'; Condition='none'
       Desc='Disable USB selective suspend / power saving on all USB devices.'
       Operations=@( @{Type='UsbPower'} )
    }
    @{ Category='Power Management'; Name='Install High-Performance Power Plan'; Risk='Safe'; Condition='none'
       Desc='Import and activate the bundled high-performance power plan.'
       Operations=@( @{Type='PowerPlan'} )
    }
    @{ Category='Power Management'; Name='Disable Power Saving'; Risk='Safe'; Condition='none'
       Desc='Disable USB power-drain recovery and CPU power throttling.'
       Operations=@(
         @{Type='Reg'; Path='HKLM\SYSTEM\CurrentControlSet\Control\USB\AutomaticSurpriseRemoval'; Name='AttemptRecoveryFromUsbPowerDrain'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling'; Name='PowerThrottlingOff'; Value=1; Kind='DWord'}
       )
    }

    # ===================== GPU =====================
    @{ Category='GPU'; Name='AMD: Disable ULPS'; Risk='Safe'; Condition='AmdGpuCondition'
       Desc='Disable AMD Ultra Low Power State.'
       Operations=@( @{Type='RegGpu'; Vendor='Amd'; Name='EnableULPS'; Value=0; Kind='DWord'} )
    }
    @{ Category='GPU'; Name='AMD: Disable Power Gating'; Risk='Moderate'; Condition='AmdGpuCondition'
       Desc='Disable AMD GPU power gating / dynamic P-state.'
       Operations=@(
         @{Type='RegGpu'; Vendor='Amd'; Name='DisablePowerGating'; Value=1; Kind='DWord'}
         @{Type='RegGpu'; Vendor='Amd'; Name='PP_GPUPowerDownEnabled'; Value=0; Kind='DWord'}
         @{Type='RegGpu'; Vendor='Amd'; Name='DisableDynamicPstate'; Value=1; Kind='DWord'}
       )
    }
    @{ Category='GPU'; Name='AMD: Disable Video Clock Gating'; Risk='Moderate'; Condition='AmdGpuCondition'
       Desc='Disable AMD video (VCE/UVD) power and clock gating.'
       Operations=@(
         @{Type='RegGpu'; Vendor='Amd'; Name='DisableVCEPowerGating'; Value=1; Kind='DWord'}
         @{Type='RegGpu'; Vendor='Amd'; Name='DisableVceClockGating'; Value=1; Kind='DWord'}
         @{Type='RegGpu'; Vendor='Amd'; Name='EnableUvdClockGating'; Value=0; Kind='DWord'}
         @{Type='RegGpu'; Vendor='Amd'; Name='EnableVceSwClockGating'; Value=0; Kind='DWord'}
       )
    }
    @{ Category='GPU'; Name='AMD: Disable ASPM'; Risk='Safe'; Condition='AmdGpuCondition'
       Desc='Disable AMD PCIe ASPM (L0s/L1) link power management.'
       Operations=@(
         @{Type='RegGpu'; Vendor='Amd'; Name='EnableAspmL0s'; Value=0; Kind='DWord'}
         @{Type='RegGpu'; Vendor='Amd'; Name='EnableAspmL1'; Value=0; Kind='DWord'}
       )
    }
    @{ Category='GPU'; Name='NVIDIA: Disable Dynamic P-State'; Risk='Safe'; Condition='NvidiaGpuCondition'
       Desc='Disable NVIDIA dynamic P-state.'
       Operations=@( @{Type='RegGpu'; Vendor='Nvidia'; Name='DisableDynamicPstate'; Value=1; Kind='DWord'} )
    }
    @{ Category='GPU'; Name='NVIDIA: Disable Async P-States'; Risk='Moderate'; Condition='NvidiaGpuCondition'
       Desc='Disable NVIDIA asynchronous P-states.'
       Operations=@( @{Type='RegGpu'; Vendor='Nvidia'; Name='DisableASyncPstates'; Value=1; Kind='DWord'} )
    }
    @{ Category='GPU'; Name='Intel: Disable Async Flips'; Risk='Safe'; Condition='IntelGpuCondition'
       Desc='Disable Intel display async flips.'
       Operations=@( @{Type='RegGpu'; Vendor='Intel'; Name='Display1_DisableAsyncFlips'; Value=1; Kind='DWord'} )
    }
    @{ Category='GPU'; Name='Intel: Disable Adaptive V-Sync'; Risk='Safe'; Condition='IntelGpuCondition'
       Desc='Disable Intel adaptive V-Sync.'
       Operations=@( @{Type='RegGpu'; Vendor='Intel'; Name='AdaptiveVsyncEnable'; Value=0; Kind='DWord'} )
    }

    # ===================== Performance =====================
    @{ Category='Performance'; Name='Disable Background Apps'; Risk='Moderate'; Condition='none'
       Desc='Disable background apps globally.'
       Operations=@(
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications'; Name='GlobalUserDisabled'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search'; Name='BackgroundAppGlobalToggle'; Value=0; Kind='DWord'}
       )
    }
    @{ Category='Performance'; Name='Consolidate Service Hosts'; Risk='Moderate'; Condition='none'
       Desc='Raise the svchost split threshold to total RAM so services share fewer host processes.'
       Operations=@( @{Type='SvcHostSplit'} )
    }
    @{ Category='Performance'; Name='Process Priority (Foreground Boost)'; Risk='Safe'; Condition='none'
       Desc='Enable foreground boost (Win32PrioritySeparation = 38).'
       Operations=@(
         @{Type='Reg'; Path='HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl'; Name='Win32PrioritySeparation'; Value=38; Kind='DWord'}
       )
    }
    @{ Category='Performance'; Name='Optimize Multimedia Scheduler'; Risk='Safe'; Condition='none'
       Desc='Tune MMCSS for gaming / low latency.'
       Operations=@(
         @{Type='Reg'; Path='HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'; Name='NoLazyMode'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'; Name='AlwaysOn'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'; Name='NetworkThrottlingIndex'; Value=4294967295; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'; Name='SystemResponsiveness'; Value=10; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'; Name='Priority'; Value=2; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'; Name='Scheduling Category'; Value='High'; Kind='String'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'; Name='SFIO Priority'; Value='High'; Kind='String'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'; Name='GPU Priority'; Value=8; Kind='DWord'}
       )
    }
    @{ Category='Performance'; Name='Keyboard Latency Optimization'; Risk='Safe'; Condition='none'
       Desc='Minimize keyboard repeat delay and maximize repeat speed.'
       Operations=@(
         @{Type='Reg'; Path='HKEY_CURRENT_USER\Control Panel\Keyboard'; Name='KeyboardDelay'; Value='0'; Kind='String'}
         @{Type='Reg'; Path='HKEY_CURRENT_USER\Control Panel\Keyboard'; Name='KeyboardSpeed'; Value='31'; Kind='String'}
       )
    }
    @{ Category='Performance'; Name='Disable Accessibility Keyboard Hotkeys'; Risk='Moderate'; Condition='none'
       Desc='Disable StickyKeys / FilterKeys / ToggleKeys hotkeys.'
       Operations=@(
         @{Type='Reg'; Path='HKEY_CURRENT_USER\Control Panel\Accessibility\StickyKeys'; Name='Flags'; Value='26'; Kind='String'}
         @{Type='Reg'; Path='HKEY_CURRENT_USER\Control Panel\Accessibility\Keyboard Response'; Name='Flags'; Value='2'; Kind='String'}
         @{Type='Reg'; Path='HKEY_CURRENT_USER\Control Panel\Accessibility\ToggleKeys'; Name='Flags'; Value='34'; Kind='String'}
       )
    }
    @{ Category='Performance'; Name='Lift WebDAV File Size Limit'; Risk='Safe'; Condition='none'
       Desc='Lift the WebDAV file size limit to ~4 GB.'
       Operations=@(
         @{Type='Reg'; Path='HKLM\SYSTEM\CurrentControlSet\Services\WebClient\Parameters'; Name='FileSizeLimitInBytes'; Value=4294967295; Kind='DWord'}
       )
    }

    # ===================== User Experience =====================
    @{ Category='User Experience'; Name='Speed Up Explorer & Menus'; Risk='Safe'; Condition='none'
       Desc='Speed up Explorer startup and remove the menu show delay.'
       Operations=@(
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize'; Name='StartupDelayInMSec'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Control Panel\Desktop'; Name='MenuShowDelay'; Value='0'; Kind='String'}
       )
    }
    @{ Category='User Experience'; Name='Disable Visual Effects'; Risk='Safe'; Condition='none'
       Desc='Disable taskbar animations, listview shadows, transparency and Aero Peek.'
       Operations=@(
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='TaskbarAnimations'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='ListviewShadow'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'; Name='EnableTransparency'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Microsoft\Windows\DWM'; Name='EnableAeroPeek'; Value=0; Kind='DWord'}
       )
    }
    @{ Category='User Experience'; Name='Disable Start Menu Web Search'; Risk='Safe'; Condition='none'
       Desc='Disable web search suggestions in the Start Menu.'
       Operations=@(
         @{Type='Reg'; Path='HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer'; Name='DisableSearchBoxSuggestions'; Value=1; Kind='DWord'}
       )
    }
    @{ Category='User Experience'; Name='Hide Start Recommended Section'; Risk='Safe'; Condition='Windows11Condition'
       Desc='Hide the Recommended section in the Start Menu (Windows 11).'
       Operations=@(
         @{Type='Reg'; Path='HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer'; Name='HideRecommendedSection'; Value=1; Kind='DWord'}
       )
    }
    @{ Category='User Experience'; Name='Disable Microsoft 365 Ads in Settings'; Risk='Safe'; Condition='none'
       Desc='Disable Microsoft 365 ads shown in Settings.'
       Operations=@(
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name='DisableConsumerAccountStateContent'; Value=1; Kind='DWord'}
       )
    }
    @{ Category='User Experience'; Name='Maximize Update Pause Limit'; Risk='Safe'; Condition='none'
       Desc='Maximize the Windows Update pause limit.'
       Operations=@(
         @{Type='Reg'; Path='HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'; Name='FlightSettingsMaxPauseDays'; Value=4294967295; Kind='DWord'}
       )
    }

    # ===================== AI =====================
    @{ Category='AI'; Name='Disable Recall'; Risk='Moderate'; Condition='RecallInstalledCondition'
       Desc='Disable Windows Recall AI snapshots.'
       Operations=@(
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'; Name='DisableAIDataAnalysis'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'; Name='AllowRecallEnablement'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'; Name='TurnOffSavingSnapshots'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Policies\Microsoft\Windows\WindowsAI'; Name='DisableAIDataAnalysis'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Policies\Microsoft\Windows\WindowsAI'; Name='TurnOffSavingSnapshots'; Value=1; Kind='DWord'}
       )
    }
    @{ Category='AI'; Name='Disable Click To Do'; Risk='Safe'; Condition='Windows11_24H2OrGreaterCondition'
       Desc='Disable the Click To Do AI overlay (Windows 11 24H2+).'
       Operations=@(
         @{Type='Reg'; Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'; Name='DisableClickToDo'; Value=1; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\Software\Policies\Microsoft\Windows\WindowsAI'; Name='DisableClickToDo'; Value=1; Kind='DWord'}
       )
    }

    # ===================== Bloatware & Services =====================
    @{ Category='Bloatware & Services'; Name='Block Preinstalled Apps'; Risk='Safe'; Condition='none'
       Desc='Block preinstalled / OEM / silent apps via ContentDeliveryManager.'
       Operations=@(
         @{Type='Reg'; Path='HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name='PreInstalledAppsEnabled'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name='PreInstalledAppsEverEnabled'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name='OemPreInstalledAppsEnabled'; Value=0; Kind='DWord'}
         @{Type='Reg'; Path='HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name='SilentInstalledAppsEnabled'; Value=0; Kind='DWord'}
       )
    }
    @{ Category='Bloatware & Services'; Name='Configure Services (batch)'; Risk='Risky'; Condition='none'
       Desc='Reconfigure the startup type of 239 Windows services to a tuned baseline. RISKY - reverts individually.'
       Operations=@( @{Type='ServiceList'} )
    }
  )
}
