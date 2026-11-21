//
//  daemon_catalog.m
//

#import "daemon_catalog.h"

@interface CYDaemonGroup ()
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, copy) NSArray<NSString *> *labels;
@property (nonatomic, copy) NSString *caution;
@property (nonatomic) BOOL advanced;
@end

@implementation CYDaemonGroup
@end

static CYDaemonGroup *group(NSString *identifier, NSString *title, NSString *symbol, NSString *summary,
                            NSString *caution, NSArray<NSString *> *labels)
{
    CYDaemonGroup *g = [CYDaemonGroup new];
    g.identifier = identifier;
    g.title = title;
    g.symbol = symbol;
    g.summary = summary;
    g.caution = caution;
    g.labels = labels;
    return g;
}

static CYDaemonGroup *advanced(NSString *identifier, NSString *title, NSString *symbol, NSString *summary,
                               NSString *caution, NSArray<NSString *> *labels)
{
    CYDaemonGroup *g = group(identifier, title, symbol, summary, caution, labels);
    g.advanced = YES;
    return g;
}

NSArray<CYDaemonGroup *> *daemon_catalog_groups(void)
{
    static NSArray<CYDaemonGroup *> *groups;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        groups = @[
            group(@"ota", NSLocalizedString(@"Software Updates", nil), @"arrow.down.circle",
                  NSLocalizedString(@"iOS stops checking for and downloading updates. Same switch as OTA Updates.", nil), nil,
                  @[ @"com.apple.mobile.softwareupdated", @"com.apple.OTATaskingAgent",
                     @"com.apple.softwareupdateservicesd", @"com.apple.mobile.NRDUpdated" ]),
            group(@"usage", NSLocalizedString(@"Usage Tracking", nil), @"chart.bar",
                  NSLocalizedString(@"Stops collecting app usage statistics.", nil), nil,
                  @[ @"com.apple.UsageTrackingAgent" ]),
            group(@"screentime", NSLocalizedString(@"Screen Time", nil), @"hourglass",
                  NSLocalizedString(@"Screen Time limits, Ask to Buy and Family Sharing requests stop working.", nil), nil,
                  @[ @"com.apple.ScreenTimeAgent", @"com.apple.familycircled",
                     @"com.apple.familynotification", @"com.apple.asktod" ]),
            group(@"gamecenter", NSLocalizedString(@"Game Center", nil), @"gamecontroller",
                  NSLocalizedString(@"Game Center sign-in, achievements and leaderboards stop working.", nil), nil,
                  @[ @"com.apple.gamed" ]),
            group(@"tips", NSLocalizedString(@"Tips App", nil), @"lightbulb",
                  NSLocalizedString(@"No more Tips notifications.", nil), nil,
                  @[ @"com.apple.tipsd" ]),
            group(@"followup", NSLocalizedString(@"Setup Suggestions", nil), @"exclamationmark.bubble",
                  NSLocalizedString(@"Removes Settings suggestions such as “Finish setting up your iPhone”.", nil), nil,
                  @[ @"com.apple.followupd" ]),
            group(@"wapi", NSLocalizedString(@"Chinese WLAN (WAPI)", nil), @"wifi",
                  NSLocalizedString(@"WAPI networks, used mainly in China, can no longer be joined.", nil), nil,
                  @[ @"com.apple.wifi.wapic" ]),
            group(@"vpn", NSLocalizedString(@"IPsec VPN", nil), @"lock.shield",
                  NSLocalizedString(@"The built-in IPsec (IKEv1) VPN stops working. VPN apps are not affected.", nil), nil,
                  @[ @"com.apple.racoon" ]),
            group(@"assistivetouch", NSLocalizedString(@"AssistiveTouch", nil), @"circle.circle",
                  NSLocalizedString(@"The AssistiveTouch button stops working.", nil), nil,
                  @[ @"com.apple.assistivetouchd" ]),
            group(@"hotspot", NSLocalizedString(@"Personal Hotspot", nil), @"personalhotspot",
                  NSLocalizedString(@"Sharing your cellular connection stops working.", nil), nil,
                  @[ @"com.apple.MobileInternetSharing" ]),
            group(@"watchface", NSLocalizedString(@"Watch Face Sync", nil), @"applewatch",
                  NSLocalizedString(@"Apple Watch faces no longer sync from this iPhone.", nil), nil,
                  @[ @"com.apple.nanotimekitcompaniond" ]),
            group(@"musiccloud", NSLocalizedString(@"Music Cloud Library", nil), @"music.note",
                  NSLocalizedString(@"Apple Music / iTunes cloud library sync stops.", nil), nil,
                  @[ @"com.apple.itunescloudd" ]),
            advanced(@"diagnostics", NSLocalizedString(@"Diagnostics", nil), @"stethoscope",
                  NSLocalizedString(@"Hardware and performance diagnostics stop, including sysdiagnose.", nil), nil,
                  @[ @"com.apple.diagnosticd", @"com.apple.diagnosticextensionsd",
                     @"com.apple.diagnosticservicesd", @"com.apple.diagnosticspushd",
                     @"com.apple.symptomsd-diag", @"com.apple.sysdiagnose",
                     @"com.apple.sysdiagnose_helper" ]),
            advanced(@"crashreports", NSLocalizedString(@"Logs & Crash Reports", nil), @"doc.text.magnifyingglass",
                  NSLocalizedString(@"System logging and crash reports stop.", nil),
                  NSLocalizedString(@"Panic and crash logs are no longer saved, so a reboot from a failed run can't be diagnosed. Turn this back on before reporting a bug.", nil),
                  @[ @"com.apple.ReportCrash", @"com.apple.ReportMemoryException", @"com.apple.OTACrashCopier",
                     @"com.apple.analyticsd", @"com.apple.wifianalyticsd", @"com.apple.aslmanager",
                     @"com.apple.coresymbolicationd", @"com.apple.crash_mover",
                     @"com.apple.crashreportcopymobile", @"com.apple.DumpBasebandCrash",
                     @"com.apple.DumpPanic", @"com.apple.logd", @"com.apple.logd_helper",
                     @"com.apple.logd_reporter", @"com.apple.hangreporter", @"com.apple.hangtracerd",
                     @"com.apple.spindump", @"com.apple.tailspind", @"com.apple.rtcreportingd",
                     @"com.apple.syslogd", @"com.apple.signpost.signpost_reporter",
                     @"com.apple.pluginkit.pkreporter", @"com.apple.ProxiedCrashCopier.ProxyingDevice", @"com.apple.ReportSystemMemory" ]),
            advanced(@"spotlight", NSLocalizedString(@"Spotlight", nil), @"magnifyingglass",
                  NSLocalizedString(@"Searching from the Home Screen and in apps stops working.", nil),
                  NSLocalizedString(@"Spotlight search, app search and Siri Suggestions stop working.", nil),
                  @[ @"com.apple.searchd", @"com.apple.corespotlightservice",
                     @"com.apple.spotlightknowledged", @"com.apple.spotlightknowledged.updater",
                     @"com.apple.spotlight.IndexAgent" ]),
            advanced(@"siri", NSLocalizedString(@"Siri & Dictation", nil), @"waveform",
                  NSLocalizedString(@"Siri, Voice Control and dictation stop working.", nil),
                  NSLocalizedString(@"Siri, “Hey Siri”, Voice Control and keyboard dictation stop working.", nil),
                  @[ @"com.apple.assistant_service", @"com.apple.assistantd", @"com.apple.voiced" ]),
            advanced(@"health", NSLocalizedString(@"HealthKit", nil), @"heart",
                  NSLocalizedString(@"The Health app and apps that use health data stop getting updates.", nil),
                  NSLocalizedString(@"Health data stops being recorded and synced, including from Apple Watch.", nil),
                  @[ @"com.apple.healthd" ]),
            advanced(@"wallet", NSLocalizedString(@"Wallet", nil), @"wallet.pass",
                  NSLocalizedString(@"Wallet passes and Apple Pay stop working.", nil),
                  NSLocalizedString(@"Apple Pay, transit cards, car keys and all Wallet passes stop working.", nil),
                  @[ @"com.apple.passd" ]),
            advanced(@"location", NSLocalizedString(@"Location Services", nil), @"location",
                  NSLocalizedString(@"GPS and everything that needs your location stops working.", nil),
                  NSLocalizedString(@"Maps, Find My, Weather, location-based reminders and Cyanide's Location Services toggle stop working.", nil),
                  @[ @"com.apple.locationd" ]),
            advanced(@"thermal", NSLocalizedString(@"Thermal Monitor", nil), @"thermometer.medium",
                  NSLocalizedString(@"iOS stops lowering performance when the device gets warm.", nil),
                  NSLocalizedString(@"Without thermalmonitord iOS no longer throttles when hot. The device can get very warm under load; the hardware still shuts down at critical temperatures.", nil),
                  @[ @"com.apple.thermalmonitord" ]),
        ];
    });
    return groups;
}

// These labels were in Cyanide's older catalog, but were removed after the
// iOS 17/18 launchd job audit. Keep this list explicit and finite: persisted
// entries for these labels can be recovered, while arbitrary plist keys never
// become an in-app write route.
static NSArray<NSString *> *daemon_catalog_legacy_labels(void)
{
    static NSArray<NSString *> *labels;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        labels = @[
            @"com.apple.atc.atwakeup",
            @"com.apple.wapic",
            @"com.apple.printd",
            @"com.apple.sysdiagnose.darwinos",
            @"com.apple.ReportCrash.Jetsam",
            @"com.apple.logd.admin",
            @"com.apple.logd.events",
            @"com.apple.logd.watchdog",
            @"com.apple.logd_reporter.report_statistics",
            @"com.apple.system.logger",
            @"com.apple.ProxiedCrashCopier",
        ];
    });
    return labels;
}

BOOL daemon_catalog_contains_label(NSString *label)
{
    static NSSet<NSString *> *all;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSMutableSet *s = [NSMutableSet set];
        for (CYDaemonGroup *g in daemon_catalog_groups()) [s addObjectsFromArray:g.labels];
        all = s;
    });
    return [label isKindOfClass:NSString.class] && [all containsObject:label];
}

BOOL daemon_catalog_is_legacy_label(NSString *label)
{
    static NSSet<NSString *> *legacy;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ legacy = [NSSet setWithArray:daemon_catalog_legacy_labels()]; });
    return [label isKindOfClass:NSString.class] && [legacy containsObject:label];
}

BOOL daemon_catalog_change_is_allowed(NSString *label, BOOL disable)
{
    if (daemon_catalog_contains_label(label)) return YES;
    // Legacy rows are recovery-only. In particular, do not let an arbitrary
    // persisted key or a fabricated UI request become a new disabled entry.
    return !disable && daemon_catalog_is_legacy_label(label);
}

CYDaemonGroup *daemon_catalog_legacy_recovery_group(NSDictionary *disabled)
{
    if (![disabled isKindOfClass:NSDictionary.class]) return nil;
    NSMutableArray<NSString *> *present = [NSMutableArray array];
    for (NSString *label in daemon_catalog_legacy_labels()) {
        id value = disabled[label];
        if ([value isKindOfClass:NSNumber.class] && [value boolValue]) [present addObject:label];
    }
    if (!present.count) return nil;
    return advanced(@"legacy-recovery", NSLocalizedString(@"Legacy Disabled Services", nil), @"arrow.uturn.backward.circle",
                    NSLocalizedString(@"Older Cyanide versions could disable these labels. Their job presence is not checked on this OS; switch them on to remove the persisted entry.", nil),
                    nil, present);
}

NSString *daemon_catalog_executable_guess(NSString *label)
{
    static NSDictionary<NSString *, NSString *> *known;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        known = @{
            @"com.apple.ProxiedCrashCopier.ProxyingDevice": @"ProxiedCrashCopier",
            @"com.apple.spotlightknowledged.updater": @"spotlightknowledged",
        };
    });
    return known[label] ?: [label componentsSeparatedByString:@"."].lastObject;
}
