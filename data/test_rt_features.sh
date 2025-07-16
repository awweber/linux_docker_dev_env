#!/bin/bash
# Test-Skript für PREEMPT_RT Features
# Testet verschiedene Real-Time Eigenschaften des Kernels

set -e

echo "=== PREEMPT_RT Kernel Test Suite ==="
echo "Datum: $(date)"
echo "Kernel: $(uname -a)"
echo ""

# Test 1: RT-Feature Verfügbarkeit
echo "=== Test 1: RT-Feature Verfügbarkeit ==="
if [ -f /sys/kernel/realtime ]; then
    RT_STATUS=$(cat /sys/kernel/realtime)
    echo "✓ /sys/kernel/realtime: $RT_STATUS"
    if [ "$RT_STATUS" = "1" ]; then
        echo "✓ PREEMPT_RT ist aktiv"
    else
        echo "✗ PREEMPT_RT ist nicht aktiv"
    fi
else
    echo "✗ /sys/kernel/realtime nicht gefunden"
fi

# Test 2: RT-Scheduler Parameter
echo ""
echo "=== Test 2: RT-Scheduler Parameter ==="
if [ -f /proc/sys/kernel/sched_rt_runtime_us ]; then
    echo "✓ RT Runtime: $(cat /proc/sys/kernel/sched_rt_runtime_us) µs"
else
    echo "✗ RT Runtime Parameter nicht gefunden"
fi

if [ -f /proc/sys/kernel/sched_rt_period_us ]; then
    echo "✓ RT Period: $(cat /proc/sys/kernel/sched_rt_period_us) µs"
else
    echo "✗ RT Period Parameter nicht gefunden"
fi

# Test 3: High-Resolution Timer
echo ""
echo "=== Test 3: High-Resolution Timer ==="
if [ -f /proc/timer_list ]; then
    if grep -q "hres_active.*1" /proc/timer_list; then
        echo "✓ High-Resolution Timer ist aktiv"
    else
        echo "✗ High-Resolution Timer ist nicht aktiv"
    fi
else
    echo "✗ /proc/timer_list nicht gefunden"
fi

# Test 4: NO_HZ (Tickless) Modus
echo ""
echo "=== Test 4: NO_HZ (Tickless) Modus ==="
if [ -f /sys/kernel/debug/tracing/trace ]; then
    echo "✓ Tracing-System verfügbar"
    found_tick_event=false
    for f in /sys/kernel/debug/tracing/events/timer/*tick*; do
        if [ -e "$f" ]; then
            found_tick_event=true
            break
        fi
    done
    if [ "$found_tick_event" = true ]; then
        echo "✓ Timer-Events verfügbar"
    fi
else
    echo "! Tracing-System nicht verfügbar (Debug-FS nicht gemountet?)"
fi

# Test 5: RT-Mutexes
echo ""
echo "=== Test 5: RT-Mutex Status ==="
if [ -f /proc/locks ]; then
    echo "✓ Lock-Informationen verfügbar"
    LOCK_COUNT=$(wc -l < /proc/locks)
    echo "  Aktuelle Locks: $LOCK_COUNT"
else
    echo "✗ /proc/locks nicht gefunden"
fi

# Test 6: Preemption-Zähler
echo ""
echo "=== Test 6: Preemption-Statistiken ==="
if [ -d /proc/sys/kernel ]; then
    echo "✓ Kernel-Statistiken verfügbar:"
    
    # Voluntary Context Switches
    if [ -f /proc/stat ]; then
        echo "  Context Switches: $(grep ctxt /proc/stat | awk '{print $2}')"
    fi
    
    # Interrupts
    if [ -f /proc/interrupts ]; then
        echo "  Interrupts: $(grep -c ":" /proc/interrupts) verschiedene"
    fi
else
    echo "✗ Kernel-Statistiken nicht verfügbar"
fi

# Test 7: CPU-Affinität und Isolation
echo ""
echo "=== Test 7: CPU-Konfiguration ==="
echo "CPU-Kerne: $(nproc)"
echo "Online CPUs: $(cat /sys/devices/system/cpu/online)"
echo "Isolierte CPUs: $(cat /sys/devices/system/cpu/isolated 2>/dev/null || echo 'keine')"

# Test 8: RT-Threads
echo ""
echo "=== Test 8: RT-Kernel-Threads ==="
if command -v ps >/dev/null 2>&1; then
    echo "RT-Threads (migration, watchdog, etc.):"
    ps aux | grep -E "\[.*rt\]|\[migration\]|\[watchdog\]" | head -10
else
    echo "! ps-Kommando nicht verfügbar"
fi

# Test 9: Memory-Locking
echo ""
echo "=== Test 9: Memory-Locking Support ==="
if [ -f /proc/meminfo ]; then
    echo "Speicher-Informationen:"
    grep -E "MemTotal|MemFree|Mlocked" /proc/meminfo
else
    echo "✗ Memory-Informationen nicht verfügbar"
fi

# Test 10: RT-Prioritäten
echo ""
echo "=== Test 10: RT-Prioritäten ==="
if [ -f /proc/sys/kernel/sched_rt_runtime_us ]; then
    RT_RUNTIME=$(cat /proc/sys/kernel/sched_rt_runtime_us)
    RT_PERIOD=$(cat /proc/sys/kernel/sched_rt_period_us)
    RT_RATIO=$(echo "scale=2; $RT_RUNTIME * 100 / $RT_PERIOD" | bc 2>/dev/null || echo "N/A")
    echo "RT-Scheduling-Ratio: $RT_RATIO%"
else
    echo "✗ RT-Prioritäten-Informationen nicht verfügbar"
fi

echo ""
echo "=== Zusammenfassung ==="
echo "Test abgeschlossen um: $(date)"
echo ""
echo "Für detaillierte RT-Performance-Tests verwenden Sie:"
echo "- cyclictest -t1 -p 80 -n -i 10000 -l 10000"
echo "- hwlatdetect --duration=30"
echo "- rteval --duration=300"
echo ""
echo "Für Live-Monitoring:"
echo "- watch -n 1 'cat /proc/interrupts'"
echo "- watch -n 1 'cat /proc/stat | grep ctxt'"
