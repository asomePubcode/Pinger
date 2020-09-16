//
//  ViewController.m
//  Pinger
//
//  Created by 廖亚雄 on 2020/9/16.
//

#import "ViewController.h"
#import "SimplePing.h"
#import "LDSRouterInfo.h"
@interface ViewController ()<SimplePingDelegate>
{
    SimplePing *pinger;dispatch_source_t timer;
}
@end

@implementation ViewController
dispatch_source_t timer;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDictionary *router = [LDSRouterInfo getRouterInfo];
    pinger = [[SimplePing alloc] initWithHostName:router[@"ip"]];
    pinger.delegate = self;
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        [self->pinger start];
    });
    dispatch_resume(timer);
    
}
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
    if (timer) {
        return;
    }
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        [pinger sendPingWithData:nil];
    });
    dispatch_resume(timer);
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    NSLog(@"可以使用局域网");
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error {
    if (error.code == 65) {//no route to host
        NSLog(@"不可以使用局域网");
    }
}

@end
