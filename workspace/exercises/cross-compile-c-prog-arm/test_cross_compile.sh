#!/bin/bash
# Test script for ARM cross-compilation
echo "=== ARM Cross-Compilation Test ==="
echo

# Test 1: Check if ARM cross-compiler is available
echo "1. Checking ARM cross-compiler..."
if command -v arm-linux-gnueabi-gcc &> /dev/null; then
    echo "✓ ARM cross-compiler found"
    arm-linux-gnueabi-gcc --version | head -1
else
    echo "✗ ARM cross-compiler not found"
    exit 1
fi
echo

# Test 2: Check if source file exists
echo "2. Checking source file..."
if [ -f "hello_arm.c" ]; then
    echo "✓ Source file hello_arm.c exists"
else
    echo "✗ Source file hello_arm.c not found"
    exit 1
fi
echo

# Test 3: Compile the program
echo "3. Compiling for ARM..."
arm-linux-gnueabi-gcc hello_arm.c -o hello_arm
if [ $? -eq 0 ]; then
    echo "✓ Compilation successful"
else
    echo "✗ Compilation failed"
    exit 1
fi
echo

# Test 4: Check file type
echo "4. Checking file type..."
file hello_arm
echo

# Test 5: Static compilation
echo "5. Compiling static version..."
arm-linux-gnueabi-gcc -static hello_arm.c -o hello_arm_static
if [ $? -eq 0 ]; then
    echo "✓ Static compilation successful"
else
    echo "✗ Static compilation failed"
fi
echo

# Test 6: Run with QEMU user mode
echo "6. Testing with QEMU user mode..."
if command -v qemu-arm-static &> /dev/null; then
    echo "✓ qemu-arm-static found"
    echo "Output of hello_arm_static:"
    qemu-arm-static hello_arm_static
else
    echo "✗ qemu-arm-static not found"
fi
echo

echo "=== Test completed ==="
