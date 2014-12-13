#import <Cedar.h>
#import <Foundation/Foundation.h>

// Compiling tests as an executable allows for easy
// instrumentation for finding leaks / performance problems.
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        return CDRRunSpecs();
    }
}
