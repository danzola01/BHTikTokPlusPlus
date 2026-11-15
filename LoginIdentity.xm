#import <Foundation/Foundation.h>
#import <objc/runtime.h>

// TikTok reads its API identity through this helper. Personal signing can change
// the installed bundle ID even when the input IPA retains the original ID.
// Keep this adjustment local to TikTok's helper, leaving NSBundle and signing
// entitlements untouched. This is an on-device compatibility trial.
%group LoginIdentity
%hook TTInstallSandBoxHelper
+ (NSString *)bundleIdentifier {
    return @"com.zhiliaoapp.musically";
}
%end
%end

%ctor {
    Class helper = objc_getClass("TTInstallSandBoxHelper");
    Method method = helper ? class_getClassMethod(helper, @selector(bundleIdentifier)) : NULL;
    char returnType[32] = {0};
    if (method) {
        method_getReturnType(method, returnType, sizeof(returnType));
    }
    // Do not add a selector or hook a changed signature on unsupported versions.
    if (method && method_getNumberOfArguments(method) == 2 && returnType[0] == '@') {
        %init(LoginIdentity);
    }
}
