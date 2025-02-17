
// Copyright (c) 2025 Marc E. Colosimo. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file
module atomics

import sync

pub struct AtomicU32 {
mut:
	ptr		C.atomic_uintptr_t
	mutex	sync.Mutex
}

pub fn new_atomic_u32(init_value u32) AtomicU32 {
	mut m := sync.new_mutex()
	mut a := AtomicU32 {
		mutex:	m
	}
	C.atomic_store_u32(&a.ptr, init_value)
	return a
}

// Unconditionally sets to the given value.
@[inline]
pub fn (mut a AtomicU32) set(new_value u32) {
	C.atomic_store_u32(&a.ptr, new_value)
}

@[inline]
pub fn (a AtomicU32) get() u32 {
	return C.atomic_load_u32(&a.ptr)
}

// Atomically sets to the given value and returns the previous value.
@[inline]
pub fn (mut a AtomicU32) get_and_set(new_value u32) u32 {
	a.mutex.lock()
	defer {
		a.mutex.unlock()
	}
	old_value := C.atomic_load_u32(&a.ptr)
	C.atomic_store_u32(&a.ptr, new_value)
	return old_value
}

// compare_and_set Atomically sets the value to the given updated value if the current value == the expected value.
@[inline]
pub fn (mut a AtomicU32) compare_and_set(expect u32, update u32) bool {
	return C.atomic_compare_exchange_strong_u32(&a.ptr, &expect, update)
}

// weak_compare_and_set Used to atomically compare and exchange values in a way that may fail spuriously.
// often used in lock-free data structure.
@[inline]
pub fn (mut a AtomicU32) weak_compare_and_set(expect u32, update u32) bool {
	return C.atomic_compare_exchange_weak_u32(&a.ptr, &expect, update)
}