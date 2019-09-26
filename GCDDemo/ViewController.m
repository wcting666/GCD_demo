//
//  ViewController.m
//  GCDDemo
//
//  Created by Wcting on 2019/9/3.
//  Copyright © 2019年 EJIAJX_wct. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    int numberTicket;
    dispatch_semaphore_t semaphoreTicket;
    NSThread *threadBJ;
    NSThread *threadSH;
    NSLock *lock;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
////        NSData* data = [NSData dataWithContentsOfURL: kLatestKivaLoansURL];
//        [self performSelectorOnMainThread:@selector(fetchedDate) withObject:self waitUntilDone:YES];
////        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
//    });

//    NSLog(@"thread:%@",[NSThread currentThread]);
    //GCD 同步方法 死锁
//    [self gcdBadThread];

    //gcd 同步方法
//    [self gcdSync];
    //gcd 异步方法
//    [self gcdAsync];
    //gcd 异步方法开辟新线程
//    [self gcdAsyncNewThread];
    //gcd 新队列
//    [self gcdNewQueue];
    
//    [self gcdQueueGroup];
    /*
        //创建串行队列DISPATCH_QUEUE_SERIAL，注意dispatch_get_main_queue()s也是串行队列
    dispatch_queue_t aqueue = dispatch_queue_create("aqueue", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(aqueue, ^{
        NSLog(@"这种情况会发生死锁:%@",[NSThread currentThread]);
        //任务1
        dispatch_sync(aqueue, ^{
            NSLog(@"任务1:%@",[NSThread currentThread]);
        });
        //任务2
        NSLog(@"任务2:%@",[NSThread currentThread]);
    });*/

//    dispatch_queue_t queueCT = dispatch_queue_create("", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_apply(6, queueCT, ^(size_t index) {
//        NSLog(@"----%zd------%@",index,[NSThread currentThread]);
//    });

//    [self semophoreSync];
//    [self userSemaphoreSaleTicketSafe];
//    [self newThread];
//    [self threadSaleTicketSafe];
//    [self addOperationQueue];
    [self operationSaleTicketSafe];
    
    // 创建观察者
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        NSLog(@"监听到RunLoop发生改变---%zd",activity);
    });
    
    // 添加观察者到当前RunLoop中
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    
    // 释放observer，最后添加完需要释放掉
    CFRelease(observer);
    
    UIImageView *imag = [[UIImageView alloc] init];
    [imag performSelector:@selector(setImage:) withObject:[UIImage imageNamed:@""] afterDelay:1.0 inModes:@[NSDefaultRunLoopMode]];
}

//死锁
- (void)gcdBadThread
{
    //在主线程主队列下
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"这种情况是死锁");
    });
    
    //在主线程主队列下，在串行队列queue下添加同步任务
    dispatch_queue_t queue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(queue, ^{
    NSLog(@"这种情况不会发生死锁，因为此处任务是在一个新的队列里");
    });
    
}


- (void)newThread
{
    //创建新线程
    [NSThread detachNewThreadSelector:@selector(newThreadAction) toTarget:self withObject:nil];
}

- (void)newThreadAction
{
    NSLog(@"新线程:%@",[NSThread currentThread]);
    /*
     在新线程里同步添加任务到主队列，这种情况不会发生死锁；
     因为这时候newThreadAction方法在新线程里，不在主线程，现在主线程是畅通的，会直接指向同步追加到主线程的任务，不会死锁。
     */
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"main线程:%@",[NSThread currentThread]);
        NSLog(@"这种情况不会发生死锁");
    });
    
}

- (void)gcdSync
{
    //dispatch_sync同步执行
    NSLog(@"--任务1:%@",[NSThread currentThread]);
    dispatch_queue_t queue = dispatch_queue_create("ctqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(queue, ^{
        NSLog(@"任务1:%@",[NSThread currentThread]);
    });
    NSLog(@"任务2");
}

- (void)gcdAsync
{
    //dispatch_async异步执行
//    NSLog(@"--任务1:%@",[NSThread currentThread]);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"任务1:%@",[NSThread currentThread]);
//    });
//    NSLog(@"任务2");
    
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncConcurrent---begin");
    
    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_async(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_async(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    NSLog(@"asyncConcurrent---end");
}

- (void)gcdAsyncNewThread
{
    //注意这时候异步方法下的全局队列会开辟新线程  priority:DISPATCH_QUEUE_PRIORITY_HIGH,队列优先级是hight，所以会比gcdAsync先执行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"async new thread:%@",[NSThread currentThread]);
        for (int i = 0; i < 5; i ++) {
            NSLog(@"--------newThread:%d",i);
        }
    });
    
    dispatch_async(dispatch_queue_create("tgg", DISPATCH_QUEUE_CONCURRENT), ^{
        NSLog(@"async new thread2:%@",[NSThread currentThread]);
        for (int i = 0; i < 5; i ++) {
            NSLog(@"--------newThread2:%d",i);
        }
    });
}

- (void)gcdNewQueue
{
    //这个优先级高于DISPATCH_QUEUE_PRIORITY_HIGH
    dispatch_queue_t queue = dispatch_queue_create("myqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"myqueue:%@",[NSThread currentThread]);
        for (int i = 0; i < 5; i ++) {
            NSLog(@"--------newQueue:%d",i);
        }
    });
    
    dispatch_async(queue, ^{
        NSLog(@"myqueue2:%@",[NSThread currentThread]);
        for (int i = 0; i < 5; i ++) {
            NSLog(@"--------newQueue2:%d",i);
        }
    });
    
    dispatch_async(queue, ^{
        NSLog(@"myqueue3:%@",[NSThread currentThread]);
        for (int i = 0; i < 5; i ++) {
            NSLog(@"--------newQueue3:%d",i);
        }
    });
}

- (void)gcdQueueGroup
{
    dispatch_queue_t queue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        NSLog(@"1");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"2");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"3");
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_group_async(group, queue, ^{
        NSLog(@"4");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"5");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"6");
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
}

- (void)fetchedDate
{
    NSLog(@"执行完成-----");
}

/**
 * 线程间通信
 */
- (void)communication {
    // 获取全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 获取主队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    dispatch_async(queue, ^{
        // 异步追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        
        // 回到主线程
        dispatch_async(mainQueue, ^{
            // 追加在主线程中执行的任务
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        });
    });
}


- (void)semophoreSync
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_queue_create("semaphoreQueue", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"start-----%@",[NSThread currentThread]);
    __block int number = 0;
    dispatch_async(queue, ^{
       
        NSLog(@"执行异步方法:%@",[NSThread currentThread]);
        number = 100;
        dispatch_semaphore_signal(semaphore);//
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"end---%d____%@",number,[NSThread currentThread]);
}

/*
 Dispatch Semaphore 线程安全和线程同步（为线程加锁）
 线程安全：如果你的代码所在的进程中有多个线程在同时运行，而这些线程可能会同时运行这段代码。
 如果每次运行结果和单线程运行的结果是一样的，而且其他的变量的值也和预期的是一样的，就是线程安全的。
 */

/*
 举例说明semaphore实现线程锁，保证线程安全
 场景：总共有 50 张火车票，有两个售卖火车票的窗口，一个是北京火车票售卖窗口，另一个是上海火车票售卖窗口。两个窗口同时售卖火车票，卖完为止。
 */
- (void)userSemaphoreSaleTicketSafe
{
    semaphoreTicket = dispatch_semaphore_create(1);
    numberTicket = 50;
    
    //queueBj代表北京火车站
    dispatch_queue_t queueBJ = dispatch_queue_create("queueBJ", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    //queueSH代表上海火车站
    dispatch_queue_t queueSH = dispatch_queue_create("queueBJ", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    
    dispatch_async(queueBJ, ^{
        [self saleTicketSafe];
    });
    
    dispatch_async(queueSH, ^{
        [self saleTicketSafe];
    });
    

}

- (void)saleTicketSafe
{
    while (1) {
        //加锁
        dispatch_semaphore_wait(semaphoreTicket, DISPATCH_TIME_FOREVER);
        if (numberTicket > 0) {
            numberTicket --;
            NSLog(@"卖票站台:%@ 火车票剩余数量:%d",[NSThread currentThread],numberTicket);
        }else{
            NSLog(@"所有火车票均卖完");
            //解锁
            dispatch_semaphore_signal(semaphoreTicket);
            break;
        }
        //当前线程卖完票，解锁
        dispatch_semaphore_signal(semaphoreTicket);
    }
}

/*
 线程状态转换说明
 执行threadBJ = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicketSafeThread) object:nil];后
 threadBJ会被加入到内存中；
 执行[threadBJ start]后，threadBJ被加入到可调度线程池，该线程状态为就绪状态。
 当CPU调度threadBJ，threaBJ为运行状态；
 此时线程池中还有其他线程，如果cpu调度其他线程，则threaBJ回到就绪状态；
 如果cpu在运行threadBJ对象时，执行了sleep或者等待同步锁，则threadBJ变为阻塞状态。sleep到时或者得到同步锁，解除阻塞状态变为就绪状态；
 如果CPU在运行当前线程对象时，线程任务结束或者异常强制退出，线程结束dead。
 
 */
- (void)threadSaleTicketSafe
{
    numberTicket = 50;
    threadBJ = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicketSafeThread) object:nil];
    threadBJ.name = @"北京火车站";
    
    threadSH = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicketSafeThread) object:nil];
    threadSH.name = @"上海火车站";
    
    [threadBJ start];
    [threadSH start];
}

- (void)saleTicketSafeThread
{
    while (1) {
        @synchronized (self) {
            if (numberTicket > 0) {
                numberTicket --;
                NSLog(@"窗口:%@，剩余：%d",[NSThread currentThread].name,numberTicket);
//                [NSThread sleepForTimeInterval:0.2];
            }else{
                NSLog(@"票已售罄");
                break;
            }
        }
    }
}



#pragma mark NSOperation&NSOperationQueue
- (void)addOperationQueue
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;//最大并发操作数设置为1，使queue串行执行operation

    //直接添加操作operation
    [queue addOperationWithBlock:^{
        NSLog(@"operation1:%@",[NSThread currentThread]);
    }];
    //创建操作对象operation再添加到queue上
    NSInvocationOperation *invocationOpreation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(invocationOperationAction) object:nil];
    
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"blockOperation:%@",[NSThread currentThread]);
    }];
    
    [blockOperation addExecutionBlock:^{
       NSLog(@"blockOperationExcution:%@",[NSThread currentThread]);
    }];
//    [invocationOpreation addDependency:blockOperation];//让invocationOperation依赖blockOperation
    
    [queue addOperation:invocationOpreation];//添加invocaOperation到queue
    [queue addOperation:blockOperation];//添加blockOperation到queue
}

- (void)invocationOperationAction
{
    NSLog(@"invocationOperation:%@",[NSThread currentThread]);
}


- (void)operationSaleTicketSafe
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    numberTicket = 50;
    lock = [[NSLock alloc] init];
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        [self saleTicketSafeOperation];
    }];
    
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        [self saleTicketSafeOperation];
    }];
    
    [queue addOperation:operation1];
    [queue addOperation:operation2];
   
}

- (void)saleTicketSafeOperation
{
    while (1) {
        [lock lock];
        if (numberTicket > 0) {
            numberTicket --;
            NSLog(@"窗口:%@ 剩余:%d",[NSThread currentThread],numberTicket);
            [NSThread sleepForTimeInterval:0.2];
        }
        [lock unlock];
        if (numberTicket <=0) {
            NSLog(@"票已售罄");
            break;
        }
    }
}

@end
