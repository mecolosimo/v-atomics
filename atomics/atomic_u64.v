
// Copyright (c) 2025 Marc E. Colosimo. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file
module atomics

import sync

pub struct AtomicU64 {
mut:
	ptr		C.atomic_uintptr_t
	mutex	sync.Mutex
}

pub fn new_atomic_u64(init_value u64) AtomicU64 {
	mut m := sync.new_mutex()
	mut a := AtomicU64 {
		mutex:	m
	}
	C.atomic_store_u64(&a.ptr, init_value)
	return a
}

// Unconditionally sets to the given value.
@[inline]
pub fn (mut a AtomicU64) set(new_value u64) {
	C.atomic_store_u64(&a.ptr, new_value)
}

@[inline]
pub fn (a AtomicU64) get() u64 {
	return C.atomic_load_u64(&a.ptr)
}

// Atomically sets to the given value and returns the previous value.
@[inline]
pub fn (mut a AtomicU64) get_and_set(new_value u64) u64 {
	a.mutex.lock()
	defer {
		a.mutex.unlock()
	}
	old_value := C.atomic_load_u64(&a.ptr)
	C.atomic_store_u64(&a.ptr, new_value)
	return old_value
}

// compare_and_set Atomically sets the value to the given updated value if the current value == the expected value.
@[inline]
pub fn (mut a AtomicU64) compare_and_set(expect u64, update u64) bool {
	return C.atomic_compare_exchange_strong_u64(&a.ptr, &expect, update)
}

// weak_compare_and_set Used to atomically compare and exchange values in a way that may fail spuriously.
// often used in lock-free data structure.
@[inline]
pub fn (mut a AtomicU64) weak_compare_and_set(expect u64, update u64) bool {
	return C.atomic_compare_exchange_weak_u64(&a.ptr, &expect, update)
}