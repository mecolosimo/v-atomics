
// Copyright (c) 2025 Marc E. Colosimo. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file
module atomics

import sync

pub struct AtomicU16 {
mut:
	ptr		C.atomic_uintptr_t
	mutex	sync.Mutex
}

pub fn new_atomic_u16(init_value u16) AtomicU16 {
	mut m := sync.new_mutex()
	mut a := AtomicU16 {
		mutex:	m
	}
	C.atomic_store_u16(&a.ptr, init_value)
	return a
}

// Unconditionally sets to the given value.
@[inline]
pub fn (mut a AtomicU16) set(new_value u16) {
	C.atomic_store_u16(&a.ptr, new_value)
}

@[inline]
pub fn (a AtomicU16) get() u16 {
	return C.atomic_load_u16(&a.ptr)
}

// Atomically sets to the given value and returns the previous value.
@[inline]
pub fn (mut a AtomicU16) get_and_set(new_value u16) u16 {
	a.mutex.lock()
	defer {
		a.mutex.unlock()
	}
	old_value := C.atomic_load_u16(&a.ptr)
	C.atomic_store_u16(&a.ptr, new_value)
	return old_value
}

// compare_and_set Atomically sets the value to the given updated value if the current value == the expected value.
@[inline]
pub fn (mut a AtomicU16) compare_and_set(expect u16, update u16) bool {
	return C.atomic_compare_exchange_strong_u16(&a.ptr, &expect, update)
}

// weak_compare_and_set Used to atomically compare and exchange values in a way that may fail spuriously.
// often used in lock-free data structure.
@[inline]
pub fn (mut a AtomicU16) weak_compare_and_set(expect u16, update u16) bool {
	return C.atomic_compare_exchange_weak_u16(&a.ptr, &expect, update)
}