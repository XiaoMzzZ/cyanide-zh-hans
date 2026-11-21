//
//  TendiesViewController.m
//  Cyanide
//
//  Settings → Lara → Tendies Wallpapers. Pick .tendies files and they are
//  installed right away (tweaks/tendies.m); the wallpapers Cyanide added are
//  listed and can be removed one by one (swipe) or all at once.
//

#import "TendiesViewController.h"
#import "SettingsViewController.h"
#import "tweaks/tendies.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

static NSString * const kTDCredit =
    @"The .tendies format is Nugget's, by leminlimez. Installing follows Nugget and mond by rooootdev.";

typedef NS_ENUM(NSInteger, TDSection) {
    TDSectionActions,
    TDSectionAdded,
    TDSectionCount,
};

@interface TendiesViewController () <UIDocumentPickerDelegate>
@property (nonatomic, copy) NSArray<NSDictionary *> *added;
@property (nonatomic) BOOL busy;
@property (nonatomic, copy) NSString *status;
@end

@implementation TendiesViewController

- (instancetype)init
{
    if ((self = [super initWithStyle:UITableViewStyleInsetGrouped])) self.title = NSLocalizedString(@"Tendies Wallpapers", nil);
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.added = tendies_added();
}

#pragma mark Running

- (void)run:(NSString *)name work:(BOOL (^)(NSString **message))work done:(void (^)(BOOL ok, NSString *message))done
{
    if (self.busy) return;
    self.busy = YES;
    self.status = [name stringByAppendingString:@"…"];
    [self.tableView reloadData];
    __weak typeof(self) weakSelf = self;
    settings_kernel_file_tool_async("Tendies", NO, work, ^(BOOL ok, NSString *message) {
        typeof(self) me = weakSelf;
        if (!me) return;
        me.busy = NO;
        me.added = tendies_added();
        if ([message isEqualToString:kSettingsFullExploitRequiredMessage]) {
            me.status = kSettingsNoKernelAccessHint;
            [me.tableView reloadData];
            settings_tool_needs_exploit(me, me.tableView, NSLocalizedString(@"Tendies Wallpapers", nil), ^{
                [weakSelf run:name work:work done:done];
            });
            return;
        }
        me.status = ok ? message : (message ?: NSLocalizedString(@"It didn't work. Check the log.", nil));
        if (done) done(ok, message);
        [me.tableView reloadData];
    });
}

- (void)pickFiles
{
    if (self.busy) return;
    // .tendies has no registered type; it is a zip, so any data file is offered.
    UIDocumentPickerViewController *picker =
        [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[ UTTypeZIP, UTTypeData ] asCopy:YES];
    picker.allowsMultipleSelection = YES;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
    if (urls.count == 0) return;
    NSArray<NSURL *> *files = [urls copy];
    __block NSUInteger count = 0;
    __weak typeof(self) weakSelf = self;
    [self run:NSLocalizedString(@"Installing", nil) work:^BOOL(NSString **message) {
        BOOL ok = tendies_install(files, &count, message);
        for (NSURL *url in files) [NSFileManager.defaultManager removeItemAtURL:url error:nil];  // our picked copies
        return ok;
    } done:^(BOOL ok, NSString *message) {
        typeof(self) me = weakSelf;
        if (!ok || !me) return;
        NSString *body = [NSString stringWithFormat:
            NSLocalizedString(@"%lu wallpaper%@ added. Long-press the Lock Screen, tap +, and pick it from the gallery (Collections, or Photos for video wallpapers).%@", nil),
            (unsigned long)count, count == 1 ? @"" : @"s",
            message.length ? [@"\n\n" stringByAppendingString:message] : @""];
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Wallpapers Installed", nil) message:body
                                                             preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil]];
        [me presentViewController:ac animated:YES completion:nil];
    }];
}

- (void)removePaths:(NSArray<NSString *> *)paths title:(NSString *)title
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title
        message:NSLocalizedString(@"Removes the wallpaper from the gallery and restarts PosterBoard. If it is your current Lock Screen, choose another one first. Apple's wallpapers aren't touched.", nil)
        preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    __weak typeof(self) weakSelf = self;
    [ac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Remove", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) {
        [weakSelf run:NSLocalizedString(@"Removing", nil) work:^BOOL(NSString **message) {
            return tendies_remove(paths, message);
        } done:nil];
    }]];
    [self presentViewController:ac animated:YES completion:nil];
}

#pragma mark Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return TDSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == TDSectionActions) return self.added.count ? 2 : 1;
    return self.added.count ? (NSInteger)self.added.count : 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section == TDSectionAdded ? NSLocalizedString(@"Added by Cyanide", nil) : nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == TDSectionActions) {
        NSString *help = NSLocalizedString(@"Adds .tendies wallpapers to the Lock Screen wallpaper gallery. PosterBoard restarts afterwards, so the Lock Screen may flash. Install a few at a time: PosterBoard gets slow with many custom wallpapers.", nil);
        return self.status.length ? [NSString stringWithFormat:@"%@\n\n%@", self.status, help] : help;
    }
    return self.added.count ? [NSLocalizedString(@"Swipe a wallpaper to remove it.\n\n", nil) stringByAppendingString:NSLocalizedString(kTDCredit, nil)] : NSLocalizedString(kTDCredit, nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    UIListContentConfiguration *c = cell.defaultContentConfiguration;
    if (indexPath.section == TDSectionActions) {
        BOOL import = indexPath.row == 0;
        c.text = import ? NSLocalizedString(@"Install .tendies Files…", nil) : NSLocalizedString(@"Remove All Added", nil);
        c.image = [UIImage systemImageNamed:import ? @"square.and.arrow.down" : @"trash"];
        c.textProperties.color = self.busy ? UIColor.secondaryLabelColor
                                           : (import ? self.view.tintColor : UIColor.systemRedColor);
        c.imageProperties.tintColor = c.textProperties.color;
    } else if (self.added.count == 0) {
        c.text = NSLocalizedString(@"None yet", nil);
        c.textProperties.color = UIColor.secondaryLabelColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        NSDictionary *item = self.added[indexPath.row];
        c.text = item[@"name"];
        NSDate *date = item[@"date"];
        if ([date isKindOfClass:NSDate.class])
            c.secondaryText = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle
                                                             timeStyle:NSDateFormatterShortStyle];
        c.image = [UIImage systemImageNamed:@"photo.on.rectangle"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.contentConfiguration = c;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section != TDSectionActions || self.busy) return;
    if (indexPath.row == 0) {
        [self pickFiles];
    } else {
        [self removePaths:nil title:[NSString stringWithFormat:NSLocalizedString(@"Remove %lu Wallpaper%@?", nil),
                                     (unsigned long)self.added.count, self.added.count == 1 ? @"" : @"s"]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == TDSectionAdded && self.added.count > 0 && !self.busy;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete || ![self tableView:tableView canEditRowAtIndexPath:indexPath]) return;
    NSDictionary *item = self.added[indexPath.row];
    [self removePaths:@[item[@"path"]] title:[NSString stringWithFormat:NSLocalizedString(@"Remove “%@”?", nil), item[@"name"]]];
}

@end
